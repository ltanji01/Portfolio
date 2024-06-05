import torch  # Importing the PyTorch library
import numpy as np  # Importing the NumPy library
import warnings  # Importing the warnings library to manage warnings
import torch.nn.functional as F  # Importing the functional API of PyTorch for neural network operations

warnings.filterwarnings("ignore")  # Disabling warnings for cleaner output
device = 'cpu'  # Specifying the device for computation as CPU

# Define a function to perform evaluation on a model
def do_eval(model, batchs, batch_size=128):
    # Unpack batch data
    (state, next_state, action, next_action, reward, done) = batchs
    # Compute Q values for current states using the model
    Q_value = model.Q(state)
    # Select the action with the highest Q value
    agent_actions = torch.argmax(Q_value, dim=1)
    # Physician actions are directly taken from batch data
    phy_actions = action
    # Apply softmax to Q values to get probabilities
    Q_value_pro1 = F.softmax(Q_value)
    # Get the indices of the maximum probability actions
    Q_value_pro_ind = torch.argmax(Q_value_pro1, dim=1)
    # Create indices for gathering Q values
    Q_value_pro_ind1 = range(len(Q_value_pro_ind))
    # Gather the probabilities of chosen actions
    Q_value_pro = Q_value_pro1[Q_value_pro_ind1, Q_value_pro_ind]
    # Return several metrics from the evaluation
    return Q_value, agent_actions, phy_actions, Q_value_pro

# Define a function to perform testing with the model
def do_test(model, Xtest, actionbloctest, bloctest, Y24, BPCHANGE, reward_value, beta): #Y90, SOFA, reward_value, beta):
    # Determine the maximum block number in the test data
    bloc_max = max(bloctest)  # The maximum is only 20 stages
    # Calculate reward adjustment matrix
    r = np.array([reward_value, -reward_value]).reshape(1, -1)
    # Adjust rewards based on the Y90 values
    # r2 = r * (2 * (1 - Y90.reshape(-1, 1)) - 1)
    r2 = r * (2 * (1 - Y24.reshape(-1, 1)) - 1)
    # Flatten the array for easier use
    R3 = r2[:, 0]
    # Normalize the rewards
    R4 = (R3 + reward_value) / (2 * reward_value)
    # Initialize state variables from test data
    RNNstate = Xtest
    print('####  Generating Test Set Trajectories  ####')
    # Determine the size of each state in the state matrix
    statesize = int(RNNstate.shape[1])
    # Preallocate space for the arrays that will store the state transitions
    states = np.zeros((np.floor(RNNstate.shape[0]).astype('int64'), statesize))
    actions = np.zeros((np.floor(RNNstate.shape[0]).astype('int64'), 1), dtype=int)
    next_actions = np.zeros((np.floor(RNNstate.shape[0]).astype('int64'), 1), dtype=int)
    rewards = np.zeros((np.floor(RNNstate.shape[0]).astype('int64'), 1))
    next_states = np.zeros((np.floor(RNNstate.shape[0]).astype('int64'), statesize))
    done_flags = np.zeros((np.floor(RNNstate.shape[0]).astype('int64'), 1))
    bloc_num = np.zeros((np.floor(RNNstate.shape[0]).astype('int64'), 1))
    blocnum1 = 1
    c = 0  # Counter for the number of processed states

    bloc_num_reward = 0  # Variable to track the cumulative reward for the block
    for i in range(RNNstate.shape[0] - 1):  # Loop through each row
        states[c] = RNNstate[i, :]  # Store the state
        actions[c] = actionbloctest[i]  # Store the action
        bloc_num[c] = blocnum1  # Track the block number
        if (bloctest[i + 1] == 1):  # Check if it's the end of the trace for this patient
            next_states1 = np.zeros(statesize)  # Set next state to zero if it's the end
            next_actions1 = -1  # Indicate no next action
            done_flags1 = 1  # Set done flag to true
            blocnum1 = blocnum1 + 1  # Increment block number
            bloc_num_reward += 1  # Increment reward count for this block
            
            # reward1 = -beta[0] * (SOFA[i]) + R3[i]  # Calculate reward for this transition
            reward1 = -beta[0] * (BPCHANGE[i]) + R3[i]  # Calculate reward for this transition
            
            bloc_num_reward = 0  # Reset block reward count
        else:
            next_states1 = RNNstate[i + 1, :]  # Otherwise, set next state to the following row's state
            next_actions1 = actionbloctest[i + 1]  # Set next action accordingly
            done_flags1 = 0  # Set done flag to false
            blocnum1 = blocnum1  # Keep the same block number
            
            # reward1 = -beta[1] * (SOFA[i + 1] - SOFA[i])  # Calculate the reward for this transition
            reward1 = -beta[1] * (BPCHANGE[i + 1] - BPCHANGE[i])  # Calculate the reward for this transition
            
            bloc_num_reward += 1  # Increment reward count for this block
        next_states[c] = next_states1  # Store the next state
        next_actions[c] = next_actions1  # Store the next action
        rewards[c] = reward1  # Store the reward
        done_flags[c] = done_flags1  # Store the done flag
        c = c + 1  # Increment the counter
    # Set up the final state, action, etc., after the loop
    states[c] = RNNstate[c, :]
    actions[c] = actionbloctest[c]
    bloc_num[c] = blocnum1

    next_states1 = np.zeros(statesize)  # Set final next state to zero
    next_actions1 = -1  # Indicate no next action for the final state
    done_flags1 = 1  # Set done flag for the final state
    blocnum1 = blocnum1 + 1  # Increment block number for the final state
    bloc_num_reward += 1  # Increment reward count for the final block
    
    # reward1 = -beta[0] * (SOFA[c]) + R3[c]  # Calculate final reward
    reward1 = -beta[0] * (BPCHANGE[c]) + R3[c]  # Calculate final reward

    bloc_num_reward = 0  # Reset reward count for the final block
    next_states[c] = next_states1  # Store the final next state
    next_actions[c] = next_actions1  # Store the final next action
    rewards[c] = reward1  # Store the final reward
    done_flags[c] = done_flags1  # Store the final done flag
    c = c + 1  # Increment counter for the final setup
    # Trim arrays to the actual number of states processed
    bloc_num = bloc_num[:c, :]
    states = states[: c, :]
    next_states = next_states[: c, :]
    actions = actions[: c, :]
    next_actions = next_actions[: c, :]
    rewards = rewards[: c, :]
    done_flags = done_flags[: c, :]
    
    bloc_num = np.squeeze(bloc_num)  # Remove single-dimensional entries from bloc_num
    actions = np.squeeze(actions)  # Remove single-dimensional entries from actions
    rewards = np.squeeze(rewards)  # Remove single-dimensional entries from rewards
    done_flags = np.squeeze(done_flags)  # Remove single-dimensional entries from done_flags
    
    # Convert numpy format to tensor format
    batch_size = states.shape[0]
    state = torch.FloatTensor(states).to(device)  # Convert states to float tensor and move to the specified device
    next_state = torch.FloatTensor(next_states).to(device)  # Convert next states to float tensor and move to the specified device
    action = torch.LongTensor(actions).to(device)  # Convert actions to long tensor and move to the specified device
    next_action = torch.LongTensor(next_actions).to(device)  # Convert next actions to long tensor and move to the specified device
    reward = torch.FloatTensor(rewards).to(device)  # Convert rewards to float tensor and move to the specified device
    done = torch.FloatTensor(done_flags).to(device)  # Convert done flags to float tensor and move to the specified device
    bloc_num = torch.FloatTensor(bloc_num).to(device)  # Convert bloc_num to float tensor and move to the specified device
    batchs = (state, next_state, action, next_action, reward, done, bloc_num)  # Recompile all tensors into a new batch
    
    rec_phys_q = []  # Initialize list to record physician Q values
    rec_agent_q = []  # Initialize list to record agent Q values
    rec_agent_q_pro = []  # Initialize list to record agent Q probabilities
    rec_phys_a = []  # Initialize list to record physician actions
    rec_agent_a = []  # Initialize list to record agent actions
    rec_sur = []  # Initialize list to record survival rates
    rec_reward_user = []  # Initialize list to record user rewards
    batch_s = 128  # Set batch size for processing
    uids = np.unique(bloc_num)  # Get unique block numbers
    num_batch = uids.shape[0] // batch_s  # Calculate number of batches
    for batch_idx in range(num_batch + 1):
        batch_uids = uids[batch_idx * batch_s: (batch_idx + 1) * batch_s]  # Select uids for the current batch
        batch_user = np.isin(bloc_num, batch_uids)  # Find the indices of the current batch in bloc_num
        state_user = state[batch_user, :]  # Get states for the current batch
        next_state_user = next_state[batch_user, :]  # Get next states for the current batch
        action_user = action[batch_user]  # Get actions for the current batch
        next_action_user = next_action[batch_user]  # Get next actions for the current batch
        reward_user = reward[batch_user]  # Get rewards for the current batch
        done_user = done[batch_user]  # Get done flags for the current batch
        
        # sur_Y90 = Y90[batch_user]  # Get survival rates for the current batch
        sur_Y24 = Y24[batch_user]  # Get survival rates for the current batch
    
        batch = (state_user, next_state_user, action_user, next_action_user, reward_user, done_user)  # Recompile the batch with data for the current batch
        q_output, agent_actions, phys_actions, Q_value_pro = do_eval(model, batch)  # Evaluate the model on the current batch
    
        q_output_len = range(len(q_output))  # Create a range object for indexing q_output
        agent_q = q_output[q_output_len, agent_actions]  # Get agent Q values for the current batch
        phys_q = q_output[q_output_len, phys_actions]  # Get physical Q values for the current batch
    
        rec_agent_q.extend(agent_q.detach().numpy())  # Record agent Q values
        rec_agent_q_pro.extend(Q_value_pro.detach().numpy())  # Record agent Q probabilities
    
        rec_phys_q.extend(phys_q.detach().numpy())  # Record physical Q values
        rec_agent_a.extend(agent_actions.detach().numpy())  # Record agent actions
        rec_phys_a.extend(phys_actions.detach().numpy())  # Record physician actions
        
        # rec_sur.extend(sur_Y90)  # Record survival rates
        rec_sur.extend(sur_Y24)  # Record survival rates
        
        rec_reward_user.extend(reward_user.detach().numpy())  # Record rewards
    
    np.save('Q_values/survival_rate.npy', rec_sur)  # Save survival rates to file
    np.save('Q_values/agent_Q.npy', rec_agent_q)  # Save agent Q values to file
    np.save('Q_values/physician_Q.npy', rec_phys_q)  # Save physician Q values to file
    np.save('Q_values/reward.npy', rec_reward_user)  # Save rewards to file
    
    np.save('Q_values/agent_actions.npy', rec_agent_a)  # Save agent actions to file
    np.save('Q_values/physician_actions.npy', rec_phys_a)  # Save physician actions to file
    
    np.save('Q_values/agent_q_pro.npy', rec_agent_q_pro)  # Save agent Q probabilities to file
