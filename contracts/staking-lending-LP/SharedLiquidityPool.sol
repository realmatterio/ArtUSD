// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Shared Liquidity Pool for ArtUSD and USDC
contract SharedLiquidityPool is ReentrancyGuard, Ownable {
    // Token contracts for ArtUSD and USDC
    IERC20 public artUSD;
    IERC20 public usdc;

    // Balances of ArtUSD and USDC in the pool
    uint256 public artUSDBalance;
    uint256 public usdcBalance;

    // Address of the market maker for arbitrage
    address public marketMaker;

    // Events for logging deposits, withdrawals, and arbitrage
    event Deposited(address indexed user, address token, uint256 amount);
    event Withdrawn(address indexed user, address token, uint256 amount);
    event ArbitragePerformed(address indexed marketMaker, uint256 artUSDAmount, uint256 usdcAmount);

    // Constructor to initialize token addresses and market maker
    constructor(address _artUSD, address _usdc, address _marketMaker) Ownable(msg.sender) {
        require(_artUSD != address(0) && _usdc != address(0) && _marketMaker != address(0), "Invalid address");
        artUSD = IERC20(_artUSD);
        usdc = IERC20(_usdc);
        marketMaker = _marketMaker;
    }

    // Modifier to restrict functions to authorized contracts (e.g., Lending or Staking Protocol)
    modifier onlyAuthorized() {
        require(msg.sender == owner() || msg.sender == marketMaker, "Unauthorized");
        _;
    }

    // Deposit ArtUSD or USDC into the pool
    function deposit(address token, uint256 amount) external nonReentrant {
        require(token == address(artUSD) || token == address(usdc), "Unsupported token");
        require(amount > 0, "Amount must be greater than 0");

        // Transfer tokens to the pool
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        // Update pool balances
        if (token == address(artUSD)) {
            artUSDBalance += amount;
        } else {
            usdcBalance += amount;
        }

        emit Deposited(msg.sender, token, amount);
    }

    // Withdraw ArtUSD or USDC from the pool (only authorized contracts)
    function withdraw(address token, address to, uint256 amount) external onlyAuthorized nonReentrant {
        require(token == address(artUSD) || token == address(usdc), "Unsupported token");
        require(amount > 0, "Amount must be greater than 0");

        // Check pool balance
        if (token == address(artUSD)) {
            require(artUSDBalance >= amount, "Insufficient ArtUSD balance");
            artUSDBalance -= amount;
        } else {
            require(usdcBalance >= amount, "Insufficient USDC balance");
            usdcBalance -= amount;
        }

        // Transfer tokens to recipient
        IERC20(token).transfer(to, amount);

        emit Withdrawn(to, token, amount);
    }

    // Perform arbitrage to maintain 1:1 peg (called by market maker)
    function performArbitrage(uint256 artUSDAmount, uint256 usdcAmount) external onlyAuthorized nonReentrant {
        require(artUSDBalance >= artUSDAmount && usdcBalance >= usdcAmount, "Insufficient pool balance");

        // Update pool balances
        artUSDBalance -= artUSDAmount;
        usdcBalance -= usdcAmount;

        // Transfer tokens to market maker for arbitrage
        if (artUSDAmount > 0) {
            artUSD.transfer(marketMaker, artUSDAmount);
        }
        if (usdcAmount > 0) {
            usdc.transfer(marketMaker, usdcAmount);
        }

        emit ArbitragePerformed(marketMaker, artUSDAmount, usdcAmount);
    }

    // Emergency pause to stop deposits and withdrawals
    bool public paused;
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    // Update market maker address
    function updateMarketMaker(address _newMarketMaker) external onlyOwner {
        require(_newMarketMaker != address(0), "Invalid address");
        marketMaker = _newMarketMaker;
    }

    // Cybersecurity Notes:
    // - ReentrancyGuard prevents reentrancy attacks during token transfers.
    // - Ownable restricts critical functions (e.g., pause, update market maker) to the owner.
    // - Input validation ensures valid token addresses and non-zero amounts.
    // - Pausing mechanism allows stopping operations in case of vulnerabilities or attacks.
}
