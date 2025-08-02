// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// Interface for interacting with the SharedLiquidityPool
interface ISharedLiquidityPool {
    function deposit(uint256 amount) external;
    function requestWithdrawal(uint256 amount) external;
    function executeWithdrawal() external;
    function getAvailableLiquidity() external view returns (uint256);
}

// StakingProtocol allows users to stake tokens and earn rewards
// It interacts with the SharedLiquidityPool for staking liquidity
contract StakingProtocol is ReentrancyGuard, Pausable, AccessControl {
    using SafeMath for uint256;

    // Role for emergency actions (e.g., withdrawing funds during a pause)
    bytes32 public constant EMERGENCY_ADMIN_ROLE = keccak256("EMERGENCY_ADMIN_ROLE");

    IERC20 public immutable stakingToken; // Token used for staking
    IERC20 public immutable rewardToken; // Token used for rewards
    ISharedLiquidityPool public immutable pool; // Reference to shared liquidity pool
    uint256 public constant REWARD_RATE = 10; // 10% annual reward rate (simplified)
    mapping(address => uint256) public stakedBalance; // Tracks user staked amounts
    mapping(address => uint256) public lastStakedTime; // Tracks last staking action timestamp
    mapping(address => uint256) public accumulatedRewards; // Tracks user accumulated rewards

    // Events for logging critical actions
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);
    event RewardTokensDeposited(address indexed admin, uint256 amount);
    event EmergencyWithdrawn(address indexed admin, uint256 amount);

    // Constructor initializes token and pool addresses, sets up admin roles, and pauses contract
    constructor(address _stakingToken, address _rewardToken, address _pool) {
        require(_stakingToken != address(0), "Invalid staking token"); // Prevent zero address
        require(_rewardToken != address(0), "Invalid reward token"); // Prevent zero address
        require(_pool != address(0), "Invalid pool address"); // Prevent zero address
        stakingToken = IERC20(_stakingToken); // Set staking token
        rewardToken = IERC20(_rewardToken); // Set reward token
        pool = ISharedLiquidityPool(_pool); // Set pool reference
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender); // Grant admin role to deployer
        _setupRole(EMERGENCY_ADMIN_ROLE, msg.sender); // Grant emergency admin role
        _pause(); // Start in paused state
    }

    // Unpauses the contract, enabling staking operations
    // Only callable by DEFAULT_ADMIN_ROLE
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause(); // Trigger unpause state
    }

    // Stakes user tokens into the shared pool
    // Updates rewards and deposits to pool; protected against reentrancy
    function stake(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "Amount must be > 0"); // Prevent zero stakes
        updateRewards(msg.sender); // Calculate and update rewards before state change
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Transfer failed"); // Transfer from user
        stakedBalance[msg.sender] = stakedBalance[msg.sender].add(amount); // Update staked balance
        stakingToken.approve(address(pool), amount); // Approve pool to transfer
        pool.deposit(amount); // Deposit to shared pool
        lastStakedTime[msg.sender] = block.timestamp; // Update staking timestamp
        emit Staked(msg.sender, amount); // Log stake event
    }

    // Unstakes user tokens from the pool
    // Updates rewards and withdraws from pool; protected against reentrancy
    function unstake(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "Amount must be > 0"); // Prevent zero unstakes
        require(stakedBalance[msg.sender] >= amount, "Insufficient staked balance"); // Check staked balance
        require(amount <= pool.getAvailableLiquidity(), "Insufficient liquidity"); // Check pool liquidity
        updateRewards(msg.sender); // Calculate and update rewards
        stakedBalance[msg.sender] = stakedBalance[msg.sender].sub(amount); // Reduce staked balance
        pool.requestWithdrawal(amount); // Request withdrawal from pool
        pool.executeWithdrawal(); // Execute withdrawal (assumes timelock passed)
        require(stakingToken.transfer(msg.sender, amount), "Transfer failed"); // Transfer to user
        emit Unstaked(msg.sender, amount); // Log unstake event
    }

    // Claims accumulated rewards for the user
    // Protected against reentrancy and checks reward balance
    function claimRewards() external whenNotPaused nonReentrant {
        updateRewards(msg.sender); // Calculate and update rewards
        uint256 reward = accumulatedRewards[msg.sender]; // Get accumulated rewards
        require(reward > 0, "No rewards to claim"); // Ensure rewards exist
        require(reward <= rewardToken.balanceOf(address(this)), "Insufficient reward tokens"); // Check reward balance
        accumulatedRewards[msg.sender] = 0; // Clear rewards
        require(rewardToken.transfer(msg.sender, reward), "Transfer failed"); // Transfer rewards to user
        emit RewardsClaimed(msg.sender, reward); // Log claim event
    }

    // Updates a user's rewards based on staked amount and time
    // Internal function called before staking/unstaking/claiming
    function updateRewards(address user) internal {
        if (stakedBalance[user] > 0) { // Only calculate if user has staked tokens
            uint256 timeElapsed = block.timestamp.sub(lastStakedTime[user]); // Time since last update
            uint256 reward = stakedBalance[user].mul(REWARD_RATE).mul(timeElapsed).div(365 days).div(100); // Calculate reward
            accumulatedRewards[user] = accumulatedRewards[user].add(reward); // Update accumulated rewards
        }
        lastStakedTime[user] = block.timestamp; // Update timestamp
    }

    // Deposits reward tokens to fund the reward pool
    // Only callable by DEFAULT_ADMIN_ROLE; protected against reentrancy
    function depositRewardTokens(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        require(amount > 0, "Amount must be > 0"); // Prevent zero deposits
        require(rewardToken.transferFrom(msg.sender, address(this), amount), "Transfer failed"); // Transfer from admin
        emit RewardTokensDeposited(msg.sender, amount); // Log deposit event
    }

    // Allows emergency admin to withdraw reward tokens when paused
    // Protected against reentrancy
    function emergencyWithdraw(uint256 amount) external onlyRole(EMERGENCY_ADMIN_ROLE) whenPaused nonReentrant {
        require(amount > 0 && amount <= rewardToken.balanceOf(address(this)), "Invalid amount"); // Validate amount
        require(rewardToken.transfer(msg.sender, amount), "Transfer failed"); // Transfer to admin
        emit EmergencyWithdrawn(msg.sender, amount); // Log emergency withdrawal
    }

    // Returns the pending rewards for a user
    function getPendingRewards(address user) public view returns (uint256) {
        if (stakedBalance[user] == 0) return accumulatedRewards[user]; // Return accumulated if no stake
        uint256 timeElapsed = block.timestamp.sub(lastStakedTime[user]); // Time since last update
        uint256 reward = stakedBalance[user].mul(REWARD_RATE).mul(timeElapsed).div(365 days).div(100); // Calculate reward
        return accumulatedRewards[user].add(reward); // Return total pending rewards
    }
}
