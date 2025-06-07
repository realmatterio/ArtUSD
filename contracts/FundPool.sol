// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FundPool is Ownable {
    IERC20 public usdc;
    address public artUSD;
    uint256 public totalReserve;

    event USDDeposited(address indexed user, uint256 amount);
    event USDReleased(address indexed user, uint256 amount);

    constructor(address _usdc, address _artUSD) Ownable(msg.sender) {
        usdc = IERC20(_usdc);
        artUSD = _artUSD;
        totalReserve = 0;
    }

    function depositUSD(uint256 amount) payable external {
        require(usdc.transferFrom(msg.sender, address(this), amount), "USDC transfer failed");
        totalReserve += amount;
        (bool success, ) = artUSD.call(abi.encodeWithSignature("mint(address,uint256)", msg.sender, amount));
        require(success, "ArtUSD mint failed");
        emit USDDeposited(msg.sender, amount);
    }

    // TODO: Write tests for this
    function releaseUSD(address to, uint256 amount) external {
        require(msg.sender == artUSD, "Only ArtUSD contract can call");
        require(totalReserve >= amount, "Insufficient reserve");
        require(usdc.transfer(to, amount), "USDC transfer failed");
        totalReserve -= amount;
        emit USDReleased(to, amount);
    }

    function getReserveBalance() external view returns (uint256) {
        return totalReserve;
    }

    // TODO: Write tests for this
    function withdrawUSD(uint256 amount) external onlyOwner {
        require(totalReserve >= amount, "Insufficient reserve");
        require(usdc.transfer(owner(), amount), "USDC transfer failed");
        totalReserve -= amount;
    }
}