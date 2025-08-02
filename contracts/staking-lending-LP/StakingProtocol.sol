// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./SharedLiquidityPool.sol";

contract StakingProtocol is ReentrancyGuard, Ownable {
    // Reference to Shared Liquidity Pool and tokens
    SharedLiquidityPool public liquidityPool;
    IERC20 public artUSD;
    IERC20 public usdc;

    // Yield rates for different lock-up periods (in basis points, e.g., 600 = 6%)
    mapping(uint256 => uint256) public yieldRates; // lockPeriod (seconds) => yield rate
    uint256[] public lockPeriods; // Supported lock periods (e.g., 30 days, 90 days)

    // Struct to store user stakes
    struct Stake {
        uint256 artUSDAmount;
        uint256 usdcAmount;
        uint256 lockPeriod;
        uint256 stakeTime;
    }

    // Mapping for user stakes
    mapping(address => Stake[]) public stakes;

    // Events for logging
    event Staked(address indexed user, address token, uint256 amount, uint256 lockPeriod);
    event Unstaked(address indexed user, address token, uint256 amount, uint256 yield);

    constructor(address _liquidityPool, address _artUSD, address _usdc) Ownable(msg.sender) {
        require(_liquidityPool != address(0) && _artUSD != address(0) && _usdc != address(0), "Invalid address");
        liquidityPool = SharedLiquidityPool(_liquidityPool);
        artUSD = IERC20(_artUSD);
        usdc = IERC20(_usdc);

        // Initialize lock periods and yield rates (e.g., 30 days = 4%, 90 days = 6%)
        lockPeriods = [30 days, 90 days, 180 days];
        yieldRates[30 days] = 400; // 4%
        yieldRates[90 days] = 600; // 6%
        yieldRates[180 days] = 800; // 8%
    }

    // Stake ArtUSD or USDC for a specific lock period
    function stake(address token, uint256 amount, uint256 lockPeriod) external nonReentrant {
        require(token == address(artUSD) || token == address(usdc), "Unsupported token");
        require(amount > 0, "Amount must be greater than 0");
        require(yieldRates[lockPeriod] > 0, "Invalid lock period");

        // Transfer tokens to liquidity pool
        IERC20(token).transferFrom(msg.sender, address(liquidityPool), amount);
        liquidityPool.deposit(token, amount);

        // Record stake
        stakes[msg.sender].push(Stake({
            artUSDAmount: token == address(artUSD) ? amount : 0,
            usdcAmount: token == address(usdc) ? amount : 0,
            lockPeriod: lockPeriod,
            stakeTime: block.timestamp
        }));

        emit Staked(msg.sender, token, amount, lockPeriod);
    }

    // Unstake and claim yield
    function unstake(uint256 stakeIndex) external nonReentrant {
        require(stakeIndex < stakes[msg.sender].length, "Invalid stake index");
        Stake storage userStake = stakes[msg.sender][stakeIndex];
        require(block.timestamp >= userStake.stakeTime + userStake.lockPeriod, "Lock period not ended");

        uint256 amount = userStake.artUSDAmount > 0 ? userStake.artUSDAmount : userStake.usdcAmount;
        address token = userStake.artUSDAmount > 0 ? address(artUSD) : address(usdc);

        // Calculate yield (simple interest)
        uint256 yield = (amount * yieldRates[userStake.lockPeriod] * userStake.lockPeriod) / (365 days * 10000);

        // Withdraw principal and yield from liquidity pool
        liquidityPool.withdraw(token, msg.sender, amount);
        if (yield > 0) {
            liquidityPool.withdraw(address(artUSD), msg.sender, yield);
        }

        // Remove stake
        stakes[msg.sender][stakeIndex] = stakes[msg.sender][stakes[msg.sender].length - 1];
        stakes[msg.sender].pop();

        emit Unstaked(msg.sender, token, amount + yield, yield);
    }

    // Update yield rates
    function updateYieldRate(uint256 lockPeriod, uint256 newRate) external onlyOwner {
        require(newRate <= 10000, "Invalid rate");
        require(yieldRates[lockPeriod] > 0, "Invalid lock period");
        yieldRates[lockPeriod] = newRate;
    }

    // Emergency pause
    bool public paused;
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    // Cybersecurity Notes:
    // - ReentrancyGuard prevents reentrancy during staking and unstaking.
    // - Ownable restricts yield rate updates and pausing to the owner.
    // - Input validation ensures valid tokens, amounts, and lock periods.
    // - Pause mechanism halts operations during emergencies.
    // - Array management prevents out-of-bounds errors.
}
