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

// LendingProtocol allows users to deposit tokens, borrow against collateral, and repay loans
// It interacts with the SharedLiquidityPool for liquidity management
contract LendingProtocol is ReentrancyGuard, Pausable, AccessControl {
    using SafeMath for uint256;

    // Role for emergency actions (e.g., withdrawing funds during a pause)
    bytes32 public constant EMERGENCY_ADMIN_ROLE = keccak256("EMERGENCY_ADMIN_ROLE");

    IERC20 public immutable token; // ERC20 token used for lending (immutable for gas efficiency)
    ISharedLiquidityPool public immutable pool; // Reference to shared liquidity pool
    uint256 public constant INTEREST_RATE = 5; // 5% interest rate per loan
    uint256 public constant LOAN_TO_VALUE = 75; // 75% loan-to-value ratio
    mapping(address => uint256) public balances; // Tracks user deposits
    mapping(address => uint256) public loans; // Tracks user loans
    mapping(address => uint256) public loanTimestamps; // Tracks when loans were taken for interest calculation

    // Events for logging critical actions
    event Deposited(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount);
    event Repaid(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event EmergencyWithdrawn(address indexed admin, uint256 amount);

    // Constructor initializes token and pool addresses, sets up admin roles, and pauses contract
    constructor(address _token, address _pool) {
        require(_token != address(0), "Invalid token address"); // Prevent zero address
        require(_pool != address(0), "Invalid pool address"); // Prevent zero address
        token = IERC20(_token); // Set ERC20 token
        pool = ISharedLiquidityPool(_pool); // Set pool reference
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender); // Grant admin role to deployer
        _setupRole(EMERGENCY_ADMIN_ROLE, msg.sender); // Grant emergency admin role
        _pause(); // Start in paused state
    }

    // Unpauses the contract, enabling lending operations
    // Only callable by DEFAULT_ADMIN_ROLE
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause(); // Trigger unpause state
    }

    // Deposits user tokens into the shared pool
    // Protected against reentrancy and only callable when not paused
    function deposit(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "Amount must be > 0"); // Prevent zero deposits
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed"); // Transfer tokens from user
        balances[msg.sender] = balances[msg.sender].add(amount); // Update user balance
        token.approve(address(pool), amount); // Approve pool to transfer tokens
        pool.deposit(amount); // Deposit to shared pool
        emit Deposited(msg.sender, amount); // Log deposit event
    }

    // Allows users to borrow tokens against their collateral
    // Checks LTV ratio and pool liquidity; protected against reentrancy
    function borrow(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "Amount must be > 0"); // Prevent zero borrows
        uint256 maxLoan = balances[msg.sender].mul(LOAN_TO_VALUE).div(100); // Calculate max loan based on LTV
        require(amount <= maxLoan, "Exceeds max loan"); // Ensure loan is within LTV
        require(amount <= pool.getAvailableLiquidity(), "Insufficient liquidity"); // Check pool liquidity
        loans[msg.sender] = loans[msg.sender].add(amount); // Record loan
        loanTimestamps[msg.sender] = block.timestamp; // Update loan timestamp
        pool.requestWithdrawal(amount); // Request withdrawal from pool
        pool.executeWithdrawal(); // Execute withdrawal (assumes timelock passed; separate in production)
        require(token.transfer(msg.sender, amount), "Transfer failed"); // Transfer tokens to user
        emit Borrowed(msg.sender, amount); // Log borrow event
    }

    // Repays a loan with interest
    // Protected against reentrancy and only callable when not paused
    function repay(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "Amount must be > 0"); // Prevent zero repayments
        require(loans[msg.sender] >= amount, "Invalid loan amount"); // Ensure sufficient loan balance
        uint256 interest = amount.mul(INTEREST_RATE).div(100); // Calculate 5% interest
        uint256 totalRepayment = amount.add(interest); // Total repayment amount
        require(token.transferFrom(msg.sender, address(this), totalRepayment), "Transfer failed"); // Transfer from user
        loans[msg.sender] = loans[msg.sender].sub(amount); // Reduce loan balance
        loanTimestamps[msg.sender] = block.timestamp; // Update timestamp
        token.approve(address(pool), totalRepayment); // Approve pool to transfer
        pool.deposit(totalRepayment); // Deposit repayment to pool
        emit Repaid(msg.sender, amount); // Log repayment event
    }

    // Withdraws user deposits from the pool
    // Requires no outstanding loans; protected against reentrancy
    function withdraw(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "Amount must be > 0"); // Prevent zero withdrawals
        require(balances[msg.sender] >= amount, "Insufficient balance"); // Check user balance
        require(loans[msg.sender] == 0, "Repay loan first"); // Ensure no outstanding loans
        require(amount <= pool.getAvailableLiquidity(), "Insufficient liquidity"); // Check pool liquidity
        balances[msg.sender] = balances[msg.sender].sub(amount); // Reduce user balance
        pool.requestWithdrawal(amount); // Request withdrawal from pool
        pool.executeWithdrawal(); // Execute withdrawal (assumes timelock passed)
        require(token.transfer(msg.sender, amount), "Transfer failed"); // Transfer tokens to user
        emit Withdrawn(msg.sender, amount); // Log withdrawal event
    }

    // Allows emergency admin to withdraw tokens when paused
    // Protected against reentrancy
    function emergencyWithdraw(uint256 amount) external onlyRole(EMERGENCY_ADMIN_ROLE) whenPaused nonReentrant {
        require(amount > 0 && amount <= token.balanceOf(address(this)), "Invalid amount"); // Validate amount
        require(token.transfer(msg.sender, amount), "Transfer failed"); // Transfer to admin
        emit EmergencyWithdrawn(msg.sender, amount); // Log emergency withdrawal
    }

    // Returns the maximum loan amount a user can borrow based on their collateral
    function getMaxLoan(address user) public view returns (uint256) {
        return balances[user].mul(LOAN_TO_VALUE).div(100); // Calculate based on LTV
    }
}
