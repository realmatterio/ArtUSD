
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; /* an example of price oracle */

contract ArtUSD is ERC20, Ownable {
    AggregatorV3Interface public artPriceFeed;
    address public fundPool;
    bool public paused;

    event Redeemed(address indexed user, uint256 amount, string assetType);

    constructor(address initialOwner, address _artPriceFeed) ERC20("ArtUSD", "AUSD")  Ownable(initialOwner) {
        artPriceFeed = AggregatorV3Interface(_artPriceFeed);
        paused = false;
    }

    // Set fund pool address
    function setFundPool(address _fundPool) external onlyOwner {
        fundPool = _fundPool;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function mint(address to, uint256 amount) external onlyOwner whenNotPaused {
        require(getArtReserveValue() >= totalSupply() + amount, "Insufficient art collection reserve");
        _mint(to, amount);
    }

    function redeemForUSD(uint256 amount) external whenNotPaused {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(msg.sender, amount);
        (bool success, ) = fundPool.call(abi.encodeWithSignature("releaseUSD(address,uint256)", msg.sender, amount));
        require(success, "USD redemption failed");
        emit Redeemed(msg.sender, amount, "USDC");
    }

    function getArtReserveValue() public view returns (uint256) {
        (, int256 price, , , ) = artPriceFeed.latestRoundData();
        require(price > 0, "Invalid price feed");
        return uint256(price);
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }
}
