// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// SharedLiquidityPool manages a single liquidity pool for LendingProtocol and StakingProtocol.
// It holds ERC20 tokens and allows authorized protocols to deposit and withdraw funds securely.
contract SharedLiquidityPool is ReentrancyGuard, Pausable, AccessControl {
    using SafeMath for uint256;

    // Role identifiers for access control
    bytes32 public constant PROTOCOL_ROLE = keccak256("PROTOCOL_ROLE"); // Role for authorized protocols
    bytes32 public constant EMERGENCY_ADMIN_ROLE = keccak256("EMERGENCY_ADMIN_ROLE"); // Role for emergency actions

    IERC20 public immutable token; // The ERC20 token used for the liquidity pool (immutable for gas efficiency)
    uint256 public totalLiquidity; // Tracks total tokens in the pool
    address public timelock; // Address of timelock contract or admin for delayed withdrawals
    uint256 public constant TIMELOCK_DELAY = 2 days; // Delay for withdrawals to prevent instant draining
    mapping(address => uint256) public pendingWithdrawals; // Tracks pending withdrawal amounts per protocol
    mapping(address => uint256) public withdrawalTimestamps; // Tracks when withdrawals can be executed

    // Events for logging critical actions
    event LiquidityAdded(address indexed protocol, uint256 amount);
    event LiquidityRemoved(address indexed protocol, uint256 amount);
    event WithdrawalRequested(address indexed protocol, uint256 amount, uint256 unlockTime);
    event WithdrawalExecuted(address indexed protocol, uint256 amount);
    event EmergencyWithdrawn(address indexed admin, uint256 amount);

    // Constructor initializes token address and timelock, sets up admin roles, and pauses contract
    constructor(address _token, address _timelock) {
        require(_token != address(0), "Invalid token address"); // Prevent zero address
        require(_timelock != address(0), "Invalid timelock address"); // Prevent zero address
        token = IERC20(_token); // Set the ERC20 token for the pool
        timelock = _timelock; // Set timelock address for withdrawal delays
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender); // Grant admin role to deployer
        _setupRole(EMERGENCY_ADMIN_ROLE, msg.sender); // Grant emergency admin role to deployer
        _pause(); // Start in paused state until protocols are set
    }

    // Modifier to restrict functions to only authorized protocols
    modifier onlyProtocol() {
        require(hasRole(PROTOCOL_ROLE, msg.sender), "Only protocol"); // Ensure caller has PROTOCOL_ROLE
        _;
    }

    // Sets authorized protocol addresses (lending and staking) and unpauses the contract
    // Only callable by DEFAULT_ADMIN_ROLE when paused
    function setProtocols(address _lendingProtocol, address _stakingProtocol) external onlyRole(DEFAULT_ADMIN_ROLE) whenPaused {
        require(_lendingProtocol != address(0) && _stakingProtocol != address(0), "Invalid address"); // Prevent zero addresses
        _setupRole(PROTOCOL_ROLE, _lendingProtocol); // Grant role to lending protocol
        _setupRole(PROTOCOL_ROLE, _stakingProtocol); // Grant role to staking protocol
        _unpause(); // Enable contract operations after setting protocols
    }

    // Deposits tokens from a protocol into the shared pool
    // Protected against reentrancy and only callable when not paused
    function deposit(uint256 amount) external onlyProtocol whenNotPaused nonReentrant {
        require(amount > 0, "Amount must be > 0"); // Prevent zero deposits
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed"); // Transfer tokens from protocol
        totalLiquidity = totalLiquidity.add(amount); // Update total liquidity
        emit LiquidityAdded(msg.sender, amount); // Log deposit event
    }

    // Requests a withdrawal from the pool, enforcing a timelock delay
    // Protected against reentrancy and only callable when not paused
    function requestWithdrawal(uint256 amount) external onlyProtocol whenNotPaused nonReentrant {
        require(amount > 0, "Amount must be > 0"); // Prevent zero withdrawals
        require(totalLiquidity >= amount, "Insufficient liquidity"); // Ensure pool has enough tokens
        pendingWithdrawals[msg.sender] = pendingWithdrawals[msg.sender].add(amount); // Record pending withdrawal
        withdrawalTimestamps[msg.sender] = block.timestamp.add(TIMELOCK_DELAY); // Set unlock time
        totalLiquidity = totalLiquidity.sub(amount); // Deduct from available liquidity
        emit WithdrawalRequested(msg.sender, amount, withdrawalTimestamps[msg.sender]); // Log request
    }

    // Executes a pending withdrawal after the timelock delay
    // Protected against reentrancy and only callable when not paused
    function executeWithdrawal() external onlyProtocol whenNotPaused nonReentrant {
        uint256 amount = pendingWithdrawals[msg.sender]; // Get pending amount
        require(amount > 0, "No pending withdrawal"); // Ensure there is a pending withdrawal
        require(block.timestamp >= withdrawalTimestamps[msg.sender], "Timelock not expired"); // Check timelock
        pendingWithdrawals[msg.sender] = 0; // Clear pending withdrawal
        withdrawalTimestamps[msg.sender] = 0; // Clear timestamp
        require(token.transfer(msg.sender, amount), "Transfer failed"); // Transfer tokens to protocol
        emit WithdrawalExecuted(msg.sender, amount); // Log execution
    }

    // Allows emergency admin to withdraw tokens when paused (e.g., in case of a security breach)
    // Protected against reentrancy
    function emergencyWithdraw(uint256 amount) external onlyRole(EMERGENCY_ADMIN_ROLE) whenPaused nonReentrant {
        require(amount > 0 && amount <= token.balanceOf(address(this)), "Invalid amount"); // Validate amount
        require(token.transfer(msg.sender, amount), "Transfer failed"); // Transfer tokens to admin
        emit EmergencyWithdrawn(msg.sender, amount); // Log emergency withdrawal
    }

    // Pauses the contract, disabling deposits and withdrawals
    // Only callable by DEFAULT_ADMIN_ROLE
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause(); // Trigger pause state
    }

    // Unpauses the contract, enabling normal operations
    // Only callable by DEFAULT_ADMIN_ROLE
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause(); // Trigger unpause state
    }

    // Returns the current available liquidity in the pool
    function getAvailableLiquidity() external view returns (uint256) {
        return totalLiquidity; // Return total liquidity
    }
}
