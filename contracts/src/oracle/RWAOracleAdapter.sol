// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract RWAOracleAdapter is AccessControl {
    bytes32 public constant ORACLE_ADMIN_ROLE = keccak256("ORACLE_ADMIN_ROLE");

    AggregatorV3Interface public priceFeed;
    uint256 public maxStaleness;

    event PriceFeedUpdated(address indexed oldFeed, address indexed newFeed);
    event MaxStalenessUpdated(uint256 oldValue, uint256 newValue);

    error ZeroAddress();
    error InvalidPrice();
    error StalePrice();
    error InvalidStaleness();

    constructor(address admin, address _priceFeed, uint256 _maxStaleness) {
        if (admin == address(0) || _priceFeed == address(0)) {
            revert ZeroAddress();
        }

        if (_maxStaleness == 0) {
            revert InvalidStaleness();
        }

        priceFeed = AggregatorV3Interface(_priceFeed);
        maxStaleness = _maxStaleness;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ORACLE_ADMIN_ROLE, admin);
    }

    function getLatestPrice() public view returns (int256) {
        (, int256 price,, uint256 updatedAt,) = priceFeed.latestRoundData();

        if (price <= 0) {
            revert InvalidPrice();
        }

        if (block.timestamp - updatedAt > maxStaleness) {
            revert StalePrice();
        }

        return price;
    }

    function getLatestPriceData() external view returns (int256 price, uint256 updatedAt, uint256 currentTimestamp) {
        (, int256 answer,, uint256 feedUpdatedAt,) = priceFeed.latestRoundData();

        if (answer <= 0) {
            revert InvalidPrice();
        }

        if (block.timestamp - feedUpdatedAt > maxStaleness) {
            revert StalePrice();
        }

        return (answer, feedUpdatedAt, block.timestamp);
    }

    function updatePriceFeed(address newFeed) external onlyRole(ORACLE_ADMIN_ROLE) {
        if (newFeed == address(0)) {
            revert ZeroAddress();
        }

        address oldFeed = address(priceFeed);
        priceFeed = AggregatorV3Interface(newFeed);

        emit PriceFeedUpdated(oldFeed, newFeed);
    }

    function updateMaxStaleness(uint256 newMaxStaleness) external onlyRole(ORACLE_ADMIN_ROLE) {
        if (newMaxStaleness == 0) {
            revert InvalidStaleness();
        }

        uint256 oldValue = maxStaleness;
        maxStaleness = newMaxStaleness;

        emit MaxStalenessUpdated(oldValue, newMaxStaleness);
    }

    function decimals() external view returns (uint8) {
        return priceFeed.decimals();
    }
}
