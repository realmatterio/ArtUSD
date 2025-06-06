// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract MockArtPriceFeed is AggregatorV3Interface {
    uint8 private _decimals = 8;
    uint80 private _roundId = 1;
    uint256 private _timestamp = block.timestamp;
    uint80 private _answeredInRound = 1;
    int256 private _price;

    constructor(int256 initialPrice) {
        _price = initialPrice;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function description() external pure override returns (string memory) {
        return "Mock Art Price Feed";
    }

    function version() external pure override returns (uint256) {
        return 1;
    }

    function getRoundData(uint80 _id) external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (_id, _price, _timestamp, _timestamp, _answeredInRound);
    }

    function latestRoundData() external view override returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (_roundId, _price, _timestamp, _timestamp, _answeredInRound);
    }

    function setPrice(int256 newPrice) external {
        _price = newPrice;
        _roundId++;
        _timestamp = block.timestamp;
        _answeredInRound = _roundId;
    }
} 