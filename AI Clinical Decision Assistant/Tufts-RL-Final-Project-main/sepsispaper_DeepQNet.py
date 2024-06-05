# Import necessary libraries
import numpy as np  # For numerical operations and handling arrays
import torch  # Main PyTorch library for tensor operations and automatic differentiation
import torch.nn as nn  # PyTorch's neural network library
import torch.optim  # Library for optimization algorithms
import torch.nn.functional as F  # Library for various activation functions and utilities
import copy  # For creating deep copies of objects

# Set the computation device to CPU
device = 'cpu'

class DistributionalDQN(nn.Module):
    ''' Neural network model for calculating Q-values using separate pathways for state value and 
    action advantage. Integrates fully connected layers and ReLU activations. '''
    def __init__(self, state_dim, n_actions):
        super(DistributionalDQN, self).__init__()
        # Define a sequential model for convolutional operations (here linear and ReLU layers)
        self.conv = nn.Sequential(
            nn.Linear(state_dim, 128),  # First linear layer from input dimension to 128
            nn.ReLU(),  # Rectified Linear Unit activation function
            nn.Linear(128, 128),  # Second linear layer, 128 to 128
            nn.ReLU(),  # ReLU activation function
        )
        # Define a sequential model for value function approximation
        self.fc_val = nn.Sequential(
            nn.Linear(128, 256),  # Linear layer from 128 to 256
            nn.ReLU(),  # ReLU activation function
            nn.Linear(256, 1)  # Linear layer from 256 to 1 (value output)
        )
        # Define a sequential model for advantage function approximation
        self.fc_adv = nn.Sequential(
            nn.Linear(128, 256),  # Linear layer from 128 to 256
            nn.ReLU(),  # ReLU activation function
            nn.Linear(256, n_actions)  # Linear layer from 256 to number of actions (advantage output)
        )

    def forward(self, state):
        # Forward pass through the network
        conv_out = self.conv(state)  # Pass state through conv layers
        val = self.fc_val(conv_out)  # Compute value
        adv = self.fc_adv(conv_out)  # Compute advantage
        # Combine value and advantage to get final Q-value, adjusting for mean advantage
        return val + adv - adv.mean(dim=1, keepdim=True)

class Dist_DQN(object):
    ''' Main class to manage the Distributional DQN operations, including initializing the network,
    setting up the optimizer, and defining training procedures. 
    
    Changed num_actions to 40 for the nitroglycerin bins from 0 to 200'''
    def __init__(self, state_dim=37, num_actions=40, device='cpu', gamma=0.999, tau=0.1):
        self.device = device  # Set computation device
        self.Q = DistributionalDQN(state_dim, num_actions).to(device)  # Initialize Q-network
        self.Q_target = copy.deepcopy(self.Q)  # Create a target Q-network as a deep copy of Q
        self.tau = tau  # Parameter for target network update
        self.gamma = gamma  # Discount factor for future rewards
        self.num_actions = num_actions  # Number of possible actions
        self.optimizer = torch.optim.Adam(self.Q.parameters(), lr=0.0001)  # Optimizer for training

    def train(self, batches, epoch):
        ''' Train the network using batches of data, compute losses, perform backpropagation, and 
        update network parameters. Log training progress and periodically update the target network. 
        Replaced SOFAS with BPCHANGES to reflect our project'''
        # Unpack the batch of data
        (state, next_state, action, next_action, reward, done, bloc_num, BPCHANGES, ADMINHOUR) = batches #SOFAS) = batches
        batch_s = 128  # Batch size for training
        uids = np.unique(bloc_num)  # Get unique identifiers from batch
        num_batch = uids.shape[0] // batch_s  # Determine number of batches
        record_loss = []  # List to record loss values
        sum_q_loss = 0  # Variable to sum Q loss
        Batch = 0  # Batch counter
        for batch_idx in range(num_batch + 1):  # Loop over batches
            # Select batch of unique identifiers
            batch_uids = uids[batch_idx * batch_s: (batch_idx + 1) * batch_s]
            batch_user = np.isin(bloc_num, batch_uids)
            # Select data for users in the current batch
            state_user = state[batch_user, :]
            next_state_user = next_state[batch_user, :]
            action_user = action[batch_user]
            next_action_user = next_action[batch_user]
            reward_user = reward[batch_user]
            done_user = done[batch_user]
            BPCHANGES_user = BPCHANGES[batch_user]
            ADMINHOUR_user = ADMINHOUR[batch_user]
            # Create a batch for training
            batch = (state_user, next_state_user, action_user, next_action_user, reward_user, done_user, BPCHANGES_user, ADMINHOUR_user)
            # Compute loss for the current batch
            loss = self.compute_loss(batch)
            sum_q_loss += loss.item() # Add the current loss to the total loss
            self.optimizer.zero_grad() # Reset gradients to zero
            loss.backward() # Perform backpropagation
            self.optimizer.step() # Update model parameters
            # Log training progress
            if Batch % 25 == 0:
                print('Epoch :', epoch, 'Batch :', Batch, 'Average Loss :', sum_q_loss / (Batch + 1))
                record_loss1 = sum_q_loss / (Batch + 1)
                record_loss.append(record_loss1)
            # Periodically update the target network
            if Batch % 100 == 0:
                self.polyak_target_update()
            Batch += 1  # Increment batch counter
        return record_loss  # Return recorded losses for monitoring

    def polyak_target_update(self):
        ''' Softly update the target network parameters using Polyak averaging to stabilize the learning process. '''
        for param, target_param in zip(self.Q.parameters(), self.Q_target.parameters()):
            target_param.data.copy_(param.data)  # Copy parameters from Q to Q_target
    
    def compute_loss(self, batch):
        ''' Compute the loss for a batch using the modified Bellman equation that includes distributional 
        Q-values and integrates human clinical expertise based on the SOFA score to adjust Q-values for treatment decisions.
        SOFA was replaced with BPCHANGE for the percentage difference in blood pressure reading'''
        state, next_state, action, next_action, reward, done, BPCHANGE, ADMINHOUR = batch #SOFA = batch
        gamma = 0.99  # Discount factor for future rewards
        end_multiplier = 1 - done  # Indicator for non-terminal states
        batch_size = state.shape[0]
        range_batch = torch.arange(batch_size).long().to(device)
        # Predict Q-values for the current states
        log_Q_dist_prediction = self.Q(state)
        log_Q_dist_prediction1 = log_Q_dist_prediction[range_batch, action]
        # Predict Q-values for next states
        q_eval4nex = self.Q(next_state)
        max_eval_next = torch.argmax(q_eval4nex, dim=1)
        with torch.no_grad():
            Q_dist_target = self.Q_target(next_state)
            Q_target = Q_dist_target.clone().detach()
        # Compute target Q-values
        Q_dist_eval = Q_dist_target[range_batch, max_eval_next]
        max_target_next = torch.argmax(Q_dist_target, dim=1)
        Q_dist_tar = Q_dist_target[range_batch, max_target_next]
        Q_target_pro = F.softmax(Q_target)
        pro1 = Q_target_pro[range_batch, max_eval_next]
        pro2 = Q_target_pro[range_batch, max_target_next]
    
        ### Page 3 equation 1
        Q_dist_star = (pro1 / (pro1 + pro2)) * Q_dist_eval + (pro2 / (pro1 + pro2)) * Q_dist_tar
        
        ### log_Q_experience represents the Q-value function for clinical expertise
        log_Q_experience = Q_dist_target[range_batch, next_action.squeeze(1)]
    
        ### Page 3 Equations 6 and 7 to chose Q based on clinical expertise from SOFA score
        ### Old equation: Q_experi = torch.where(SOFA < 4, log_Q_experience, Q_dist_star)
        ### Modified the old equation to use clinical experience for a blood pressure change that is still below 20%
        ### 
        condition = (BPCHANGE < 20) & (ADMINHOUR == 1)
        Q_experi = torch.where(condition, log_Q_experience, Q_dist_star)
    
        ### Page 3 Equation 5 ###
        targetQ1 = reward + (gamma * Q_experi * end_multiplier)
        
        # Compute and return loss
        return nn.SmoothL1Loss()(targetQ1, log_Q_dist_prediction1)
    
    def get_action(self, state):
        ''' Compute Q-values for a given state using the trained network and select the action with the highest Q-value. '''
        with torch.no_grad():  # Do not compute gradients
            batch_size = state.shape[0]
            Q_dist = self.Q(state)  # Predict Q-values
            a_star = torch.argmax(Q_dist, dim=1)  # Choose the action with the highest Q-value
            return a_star  # Return the selected action

