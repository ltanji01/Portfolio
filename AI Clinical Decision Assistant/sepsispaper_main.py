"""
This main file sets up and runs the Distributional Deep Q-Network (D3QN) enhanced with human expertise for
optimal sepsis treatment policy. The process includes data preparation, training, evaluation, and testing phases.
"""
import time
import pickle
import numpy as np
import os
import pandas as pd

import torch.optim
from sepsispaper_DeepQNet import Dist_DQN
from sepsispaper_evaluate import do_eval, do_test
import matplotlib.pyplot as plt

device = 'cpu'

# ===========================Small Functions===============================
from scipy.stats import zscore, rankdata


def my_zscore(x):
    """Perform z-score normalization and return the normalized data, mean, and standard deviation."""
    return zscore(x, ddof=1), np.mean(x, axis=0), np.std(x, axis=0, ddof=1)


if __name__ == '__main__':
    start = time.perf_counter()
    
    ### Change the following .pkl file to the query results file from bigquery
    filename = 'final_cohort_data_edited.csv'
    
    # Current working directory
    current_working_directory = os.getcwd()
    
    # Complete path to the file in the current working directory
    file_path = os.path.join(current_working_directory, filename)
    
    MIMICtable = pd.read_csv(file_path)

    #####################Model Parameter Settings##############################
    # Model parameter settings, these relate to the "Parameters" input of the algorithm
    num_epoch = 101  # Number of training loops, relates to algorithm step 4 where m < M
    gamma = 0.99  # Discount factor for future rewards, relates to parameter γ
    beta1 = 0  # Penalty parameter, relates to β_s in the algorithm
    beta2 = 0.6  # Another penalty parameter, possibly β_T in the algorithm
    beta3 = 0.3  # Additional parameter, usage not explicitly defined in the algorithm
    ncv = 5  # Number of cross-validation runs, not directly related to algorithm steps
    
    #nra = 5  # Not directly related to the algorithm steps, without further context
    nra = 40 # nra has been changed to 40 since we plan to use 40 bins for nitroglycerin doses from 0 - 200
    
    lr = 1e-5  # Learning rate for gradient descent, relates to δ in step 10 of the algorithm
    reward_value = 24  # Setting of a reward value, could relate to step 2 where the state reward r is computed
    beta = [beta1, beta2, beta3]  # Beta values collection, usage not explicitly defined
    icustayidlist = MIMICtable['subject_id']  # Extracting patient IDs, input preparation step
    icuuniqueids = np.unique(icustayidlist)  # Getting unique patient IDs, input preparation step
    
    reformat5 = MIMICtable.values.copy()
    print('####  Generating State  ####')

    ''' -----------------------Selected Features=37--------------------------------
    These need to be changed still based on the results of the queryh for hypertensive patients!!!
    The current thought is to replace SOFA score as a reward with the percent difference in BP
    SOFA can then be used as a feature'''
    
    colnorm = ['heartrate', 'sysbp', 'diasbp', 'meanbp', 'resprate', 'tempc', 'spo2', 'glucose']
    ##8 indicators
    collog = ['subject_id', 'timepoint', 'icustay_id', 'hadm_id', 'charttime', 'Dose', 'sysbp_pct_change', 'diasbp_pct_change', 'avg_bp_pct_change']

    # Identify indices of columns in MIMICtable to be normalized based on column names specified in colnorm.
    colnorm = np.where(np.isin(MIMICtable.columns, colnorm))[0]
    # Identify indices of columns in MIMICtable to apply log transformation, based on column names in collog.
    collog = np.where(np.isin(MIMICtable.columns, collog))[0]
    
    # Scale the specified columns of reformat5 by standard z-score normalization for columns in colnorm,
    # and log transformation followed by z-score normalization for columns in collog.
    # Concatenates the results horizontally to form the scaled MIMIC dataset.
    scaleMIMIC = np.concatenate([zscore(reformat5[:, colnorm], ddof=1),
                                 zscore(np.log(0.1 + reformat5[:, collog]), ddof=1)], axis=1)
    
    # Load the training, validation, and test sets from their respective .npy files.
    train = np.load('dataset/train.npy')
    validate = np.load('dataset/validation.npy')
    test = np.load('dataset/test.npy')
    
    # Select the rows from scaled MIMIC data for validation based on indices,
    # and also retrieve the block number and patient ID for each validation entry.
    Xvalidate = scaleMIMIC[validate, :]
    blocsvalidate = reformat5[validate, 0]  # Block number for validation entries.
    ptidvalidate = reformat5[validate, 1]   # Patient ID for validation entries.
    
    # Similar selection for training and test sets from the scaled MIMIC data,
    # including block number and patient ID for each entry in these sets.
    Xtrain = scaleMIMIC[train, :]
    Xtest = scaleMIMIC[test, :]
    blocstrain = reformat5[train, 0]  # Block number for training entries, can act as a serial number.
    bloctest = reformat5[test, 0]     # Block number for test entries.
    ptidtrain = reformat5[train, 1]   # Patient ID for training entries.
    ptidtest = reformat5[test, 1]     # Patient ID for test entries.

    # *************************
    RNNstate = Xtrain  # ***

    print('####  Generating Action  ####')
    ''' Use only the unique actions presented in the dataset for the Dose column'''
    
    actionbloc = np.unique(MIMICtable['Dose'])
    
    # Map the unique action combinations back to the train, validate, and test sets.
    actionbloctrain = actionbloc[train]
    actionblocvalidate = actionbloc[validate]
    actionbloctest = actionbloc[test]
    
    # =================Rewards============================
    print('####  Generating Rewards  ####')
    ''' Specify the column index for the outcome of interest (e.g., patient survival at 90 days).
    We should probably re-do this so that our final reward is a new boolean feature column that states whether
    or not the patient had a normal blood pressure after 24/48 hours. Y24/48 would be appropriate'''
    
    outcome = 17
    # Extract outcomes for the training data subset, indicating negative or positive results.
    # Y90 = reformat5[train, outcome]
    Y24 = reformat5[train, outcome]
    
    # Define reward values for positive and negative outcomes.
    r = np.array([reward_value, -reward_value]).reshape(1, -1)
    # Calculate rewards for each outcome in Y90. The calculation transforms binary outcomes into rewards,
    # with positive outcomes mapped to negative rewards and vice versa, to encourage desirable outcomes.
    # r2 = r * (2 * (1 - Y90.reshape(-1, 1)) - 1)
    r2 = r * (2 * (1 - Y24.reshape(-1, 1)) - 1)
    
    # -----Prepare Reward Function-----------------------------
    # Extract SOFA scores for the training data, representing a measure of organ failure.
    # SOFA scores might be used in the state representation or to modulate rewards.
    #SOFA = reformat5[train, 57]  # ***
    BPCHANGE = reformat5[train, 17]
    
    # Extract the calculated rewards for further processing.
    R3 = r2[:, 0]
    # Normalize the rewards to a [0, 1] scale, facilitating the model's interpretation and learning.
    # This step adjusts the reward scale to be consistent across different environments or data segments.
    R4 = (R3 + reward_value) / (2 * reward_value)
    
    # Initialize a counter or condition variable, possibly for use in subsequent logic.
    c = 0
    # Determine the maximum block number in the training data, potentially indicating the duration of the dataset
    # in terms of time intervals or stages in a patient's hospital stay.
    bloc_max = max(blocstrain)

    
    # ================Construct State & Next State Sequences, Generate Policy Trajectories=================================
    # Print the number of states available from the RNN state representation to understand the dataset size.
    print(RNNstate.shape[0])
    
    # Announce the start of trajectory generation, crucial for creating the sequences of states and actions for RL training.
    print('####  Generating Trajectories  ####')
    # Determine the size of the state space from the RNN state representation.
    statesize = int(RNNstate.shape[1])

    # Preallocate arrays with 20% more space than the number of states to account for potential expansion during processing.
    # These arrays will hold the states, actions, next actions, rewards, next states, done flags, and block numbers.
    states = np.zeros((np.floor(RNNstate.shape[0] * 1.2).astype('int64'), statesize))
    actions = np.zeros((np.floor(RNNstate.shape[0] * 1.2).astype('int64'), 1), dtype=int)
    next_actions = np.zeros((np.floor(RNNstate.shape[0] * 1.2).astype('int64'), 1), dtype=int)
    rewards = np.zeros((np.floor(RNNstate.shape[0] * 1.2).astype('int64'), 1))
    next_states = np.zeros((np.floor(RNNstate.shape[0] * 1.2).astype('int64'), statesize))
    done_flags = np.zeros((np.floor(RNNstate.shape[0] * 1.2).astype('int64'), 1))
    bloc_num = np.zeros((np.floor(RNNstate.shape[0] * 1.2).astype('int64'), 1))
    blocnum1 = 1  # Initialize block number counter for tracking individual patient sequences.
    
    bloc_num_reward = 0  # Initialize a counter for rewards associated with block numbers.
    # Iterate over each state in the RNN state representation except the last to generate sequences.
    for i in range(RNNstate.shape[0] - 1):
        states[c] = RNNstate[i, :]  # Assign the current state.
        actions[c] = actionbloctrain[i]  # Assign the action taken in the current state.
        bloc_num[c] = blocnum1  # Record the current block (patient episode) number.
        # Check if the next state marks the beginning of a new patient episode.
        if (blocstrain[i + 1] == 1):
            next_states[c] = np.zeros(statesize)  # Set the next state to zeros to indicate episode termination.
            next_actions[c] = -1  # Indicate no action for terminal states.
            done_flags[c] = 1  # Mark this as the end of an episode.
            blocnum1 += 1  # Increment the block number for the next patient episode.
            bloc_num_reward += 1
            # rewards[c] = -beta1 * SOFA[i] + R3[i]  # Calculate the reward for terminal states.
            rewards[c] = -beta1 * BPCHANGE[i] + R3[i]  # Calculate the reward for terminal states.
            bloc_num_reward = 0
        else:
            # For non-terminal states, assign the next state and action.
            next_states[c] = RNNstate[i + 1, :]
            next_actions[c] = actionbloctrain[i + 1]
            done_flags[c] = 0  # Mark as not the end of an episode.
            # reward1 = -beta2 * (SOFA[i + 1] - SOFA[i])  # Calculate reward based on change in SOFA score.
            reward1 = -beta2 * (BPCHANGE[i + 1] - BPCHANGE[i])  # Calculate reward based on change in BP.
            bloc_num_reward += 1
        rewards[c] = reward1  # Assign the calculated reward.
        c += 1  # Increment the index for arrays.
    
    # Handle the last state separately since it doesn't have a subsequent state in the sequence.
    states[c] = RNNstate[c, :]
    actions[c] = actionbloctrain[c]
    bloc_num[c] = blocnum1
    next_states[c] = np.zeros(statesize)  # No next state for the last state.
    next_actions[c] = -1  # No next action for the last state.
    done_flags[c] = 1  # Mark the last state as the end of an episode.
    blocnum1 += 1  # Prepare for potentially another block number, even if not used here.
    bloc_num_reward += 1
    # rewards[c] = -beta1 * SOFA[c] + R3[c]  # Calculate the reward for the last state.
    rewards[c] = -beta1 * BPCHANGE[c] + R3[c]  # Calculate the reward for the last state.
    
    # Reset counters and indices for potentially unused space in the preallocated arrays.
    bloc_num_reward = 0
    c += 1  # Adjust the counter to include the last state in the sequence.
    
    # Trim arrays to the actual size used based on the counter c, removing unused preallocated space.
    bloc_num = bloc_num[:c, :]
    states = states[:c, :]
    next_states = next_states[:c, :]
    actions = actions[:c, :]
    next_actions = next_actions[:c, :]
    rewards = rewards[:c, :]
    done_flags = done_flags[:c, :]

    # Squeeze the arrays to remove unnecessary dimensions.
    bloc_num = np.squeeze(bloc_num)
    actions = np.squeeze(actions)
    rewards = np.squeeze(rewards)
    done_flags = np.squeeze(done_flags)
    
    # Prepare the batch size based on the number of states processed.
    batch_size = states.shape[0]

    # Convert arrays to PyTorch tensors and transfer them to the designated computing device (CPU).
    state = torch.FloatTensor(states).to(device)
    next_state = torch.FloatTensor(next_states).to(device)
    action = torch.LongTensor(actions).to(device)
    next_action = torch.LongTensor(next_actions).to(device)
    reward = torch.FloatTensor(rewards).to(device)
    done = torch.FloatTensor(done_flags).to(device)
    # SOFAS = torch.LongTensor(SOFA).to(device)
    BPCHANGES = torch.LongTensor(BPCHANGE).to(device)
    
    # Bundle the tensors into a single tuple to pass to the training routine of the model.
    batches = (state, next_state, action, next_action, reward, done, bloc_num, BPCHANGES) #SOFAS)

    
    # =================Training Model, Main Loop==================
    # Y90_validate = reformat5[validate, outcome]  # Not directly related to the algorithm steps. Preparation for validation.
    # SOFA_validate = reformat5[validate, 57]  # Not directly related to the algorithm steps. Preparation for validation.
    Y24_validate = reformat5[validate, outcome]  # Not directly related to the algorithm steps. Preparation for validation.
    BPCHANGE_validate = reformat5[validate, 17]  # Not directly related to the algorithm steps. Preparation for validation.
    model = Dist_DQN()  # Step 1: Initialize network weights (random main network weights $\omega$, target network weights $\omega-$).
    record_loss_z = []  # Setup for recording training loss over epochs.
    record_phys_q = []  # Setup for recording Q values related to physician (clinician) actions.
    record_agent_q = []  # Setup for recording Q values related to agent actions.
    for epoch in range(num_epoch):  # Start of training loop; corresponds to the outer loop (while $m < M$).
        record = model.train(batches, epoch)  # Steps 6-10: Train the model using selected trajectories and compute total loss.
        record_loss_z.append(record)  # Logging the loss.
        if epoch % 50 == 0:  # Conditional update not explicitly mentioned but aligns with updating target network weights periodically.
            torch.save({
                'Q_state_dict': model.Q.state_dict(),
                'Q_target_state_dict': model.Q_target.state_dict(),
            }, 'model\dist_noW{}.pt'.format(epoch))  # Saving the model weights; related to Step 12: Update target Q net.
        record_a = np.array(record_loss_z)  # Converting loss records for analysis.
        record_b = np.sum(record_a, axis=1)  # Summing losses; not directly mentioned in the algorithm.
    
        # -------------Validation Set, Evaluation------------------------------
        # The following block prepares the validation set and evaluates the model on it, which is not explicitly covered in the algorithm steps but is a common practice for assessing model performance.
        batch_s = ptidvalidate  # Preparation for validation; selecting patient IDs.
        uids = np.unique(bloc_num)  # Identifying unique patient encounters or time blocks.
        batch_uids = range(1, len(batch_s) + 1)  # Creating a range of unique identifiers for batching.
        batch_user = np.isin(bloc_num, batch_uids)  # Filtering data for validation set.
        state_user = state[batch_user, :]  # Extracting states for validation.
        next_state_user = next_state[batch_user, :]  # Extracting next states for validation.
        action_user = action[batch_user]  # Extracting actions for validation.
        next_action_user = next_action[batch_user]  # Extracting next actions for validation.
        reward_user = reward[batch_user]  # Extracting rewards for validation.
        done_user = done[batch_user]  # Extracting done flags for validation.
        batch = (state_user, next_state_user, action_user, next_action_user, reward_user, done_user)  # Assembling the validation batch.
    
        q_output, agent_actions, phys_actions, Q_value_pro = do_eval(model, batch)  # Evaluating the model on the validation set.
    
        q_output_len = range(len(q_output))  # Preparing for analysis of Q values.
        agent_q = q_output[:, agent_actions]  # Extracting Q values for agent-selected actions.
        phys_q = q_output[:, phys_actions]  # Extracting Q values for physician (clinician)-selected actions.
    
        print('mean agent Q:', torch.mean(agent_q))  # Logging the mean Q value for agent actions.
        print('mean phys Q:', torch.mean(phys_q))  # Logging the mean Q value for physician actions.
        record_phys_q.append(torch.mean(phys_q))  # Recording mean physician Q value.
        record_agent_q.append(torch.mean(agent_q))  # Recording mean agent Q value.
    
        print('agent_actions：', agent_actions)  # Logging agent actions.
        print('phys_actions：', phys_actions)  # Logging physician actions.


    # ===========Plotting=============================
    x_length_list = list(range(len(record_b)))
    plt.figure()
    plt.title('Training')
    plt.xlabel("epoch")
    plt.ylabel("loss")
    plt.plot(x_length_list, record_b)
    np.save('validation_set/loss.npy', record_b)
    agent_length_list = list(range(len(record_agent_q)))
    plt.figure()
    plt.title('Training')
    plt.xlabel("epoch")
    plt.ylabel("mean Q value")
    plt.plot(agent_length_list, record_agent_q, label='record_agent_q')
    np.save('validation_set/mean_agent_q.npy', record_agent_q)
    phys_length_list = list(range(len(record_phys_q)))
    np.save('validation_set/mean_phys_q.npy', record_phys_q)

    # =================Test Set, Evaluation================================================================
    # Y90_test = reformat5[test, outcome]  # Extracting outcome variables for the test set; preparation for model evaluation.
    # SOFA_test = reformat5[test, 57]  # Extracting SOFA scores for the test set; another preparation step for model evaluation.
    Y24_test = reformat5[test, outcome]  # Extracting outcome variables for the test set; preparation for model evaluation.
    BPCHANGE_test = reformat5[test, 17]  # Extracting SOFA scores for the test set; another preparation step for model evaluation.
    # do_test(model, Xtest, actionbloctest, bloctest, Y90_test, SOFA_test, reward_value, beta)  # Evaluating the model on the test set using predefined metrics.
    do_test(model, Xtest, actionbloctest, bloctest, Y24_test, BPCHANGE_test, reward_value, beta)  # Evaluating the model on the test set using predefined metrics.
    
    elapsed = (time.perf_counter() - start)  # Calculating the total elapsed time since 'start' (presumably the beginning of the entire process, including model training).
    print("Time used:", elapsed)  # Printing the total time used for execution to the console.
    plt.show()  # Displaying any plots that have been created during the process; this might include performance metrics or other visual evaluations.


    
