/**
 * License: MIT
 *
 * Copyright (c) 2025 REALMATTER
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; /* an example of price oracle */
import "@openzeppelin/contracts/utils/Pausable.sol";

contract ArtUSD is ERC20, Ownable, Pausable {
    AggregatorV3Interface public artPriceFeed;
    address public fundPool;

    event Redeemed(address indexed user, uint256 amount, string assetType);

    constructor(address initialOwner, address _artPriceFeed) ERC20("ArtUSD", "AUSD")  Ownable(initialOwner) {
        artPriceFeed = AggregatorV3Interface(_artPriceFeed);
    }

    // Set fund pool address
    function setFundPool(address _fundPool) external onlyOwner {
        fundPool = _fundPool;
    }

    // Required for minting more stablecoin tokens (either fund pool or the owner)
    modifier onlyOwnerOrFundPool() {
        require(msg.sender == owner() || msg.sender == fundPool, "Not authorized");
        _;
    }

    function mint(address to, uint256 amount) external onlyOwnerOrFundPool whenNotPaused {
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

    // Pausable functions, can only be called by owner of contract
    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
