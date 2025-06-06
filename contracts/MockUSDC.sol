// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDC is ERC20 {
    constructor() ERC20("Mock USDC", "mUSDC") {
        // Mint 1,000,000 USDC to the contract deployer
        // USDC has 6 decimals, so we multiply by 10^6
        _mint(msg.sender, 1000000 * 10**6);
    }

    // Override decimals to return 6 instead of 18
    function decimals() public pure override returns (uint8) {
        return 6;
    }
} 