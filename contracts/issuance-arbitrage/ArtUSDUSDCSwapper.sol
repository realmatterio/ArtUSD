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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArtUSDUSDCSwapper is Ownable {
    IERC20 public artUSD;
    IERC20 public usdc;
    uint256 public reserveArtUSD;
    uint256 public reserveUSDC;
    uint256 constant public FEE = 3;

    event LiquidityAdded(address indexed provider, uint256 artUSDAmount, uint256 usdcAmount);
    event Swap(address indexed user, uint256 artUSDIn, uint256 usdcOut, uint256 usdcIn, uint256 artUSDOut);

    constructor(address initialOwner, address _artUSD, address _usdc) Ownable(initialOwner) {
        artUSD = IERC20(_artUSD);
        usdc = IERC20(_usdc);
    }

    function addLiquidity(uint256 artUSDAmount, uint256 usdcAmount) external {
        require(artUSD.transferFrom(msg.sender, address(this), artUSDAmount), "ArtUSD transfer failed");
        require(usdc.transferFrom(msg.sender, address(this), usdcAmount), "USDC transfer failed");
        reserveArtUSD += artUSDAmount;
        reserveUSDC += usdcAmount;
        emit LiquidityAdded(msg.sender, artUSDAmount, usdcAmount);
    }

    function removeLiquidity(uint256 artUSDAmount, uint256 usdcAmount) external onlyOwner {
        require(reserveArtUSD >= artUSDAmount && reserveUSDC >= usdcAmount, "Insufficient reserves");
        require(artUSD.transfer(msg.sender, artUSDAmount), "ArtUSD transfer failed");
        require(usdc.transfer(msg.sender, usdcAmount), "USDC transfer failed");
        reserveArtUSD -= artUSDAmount;
        reserveUSDC -= usdcAmount;
    }

    function swapArtUSDToUSDC(uint256 artUSDIn) external returns (uint256) {
        require(artUSDIn > 0, "Invalid input amount");
        require(artUSD.transferFrom(msg.sender, address(this), artUSDIn), "ArtUSD transfer failed");
        uint256 usdcOut = getUSDCOut(artUSDIn);
        require(reserveUSDC >= usdcOut, "Insufficient USDC reserve");
        require(usdc.transfer(msg.sender, usdcOut), "USDC transfer failed");
        reserveArtUSD += artUSDIn;
        reserveUSDC -= usdcOut;
        emit Swap(msg.sender, artUSDIn, usdcOut, 0, 0);
        return usdcOut;
    }

    function swapUSDCToArtUSD(uint256 usdcIn) external returns (uint256) {
        require(usdcIn > 0, "Invalid input amount");
        require(usdc.transferFrom(msg.sender, address(this), usdcIn), "USDC transfer failed");
        uint256 artUSDOut = getArtUSDOut(usdcIn);
        require(reserveArtUSD >= artUSDOut, "Insufficient ArtUSD reserve");
        require(artUSD.transfer(msg.sender, artUSDOut), "ArtUSD transfer failed");
        reserveUSDC += usdcIn;
        reserveArtUSD -= artUSDOut;
        emit Swap(msg.sender, 0, 0, usdcIn, artUSDOut);
        return artUSDOut;
    }

    function getUSDCOut(uint256 artUSDIn) public view returns (uint256) {
        require(artUSDIn > 0 && reserveArtUSD > 0 && reserveUSDC > 0, "Invalid reserves");
        uint256 artUSDInWithFee = artUSDIn * (1000 - FEE);
        return (artUSDInWithFee * reserveUSDC) / (reserveArtUSD * 1000 + artUSDInWithFee);
    }

    function getArtUSDOut(uint256 usdcIn) public view returns (uint256) {
        require(usdcIn > 0 && reserveArtUSD > 0 && reserveUSDC > 0, "Invalid reserves");
        uint256 usdcInWithFee = usdcIn * (1000 - FEE);
        return (usdcInWithFee * reserveArtUSD) / (reserveUSDC * 1000 + usdcInWithFee);
    }
}

