// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

contract RWAOracleAdapter is AccessControl {
    bytes32 public constant ORACLE_ADMIN_ROLE = keccak256("ORACLE_ADMIN_ROLE");

    AggregatorV3Interface public priceFeed;
    uint256 public maxStaleness;

    error InvalidPrice();
    error StalePrice();

    event PriceFeedUpdated(address indexed newFeed);
    event MaxStalenessUpdated(uint256 newMaxStaleness);

    constructor(address feed, uint256 initialMaxStaleness, address admin) {
        require(feed != address(0), "Invalid feed");
        require(admin != address(0), "Invalid admin");
        require(initialMaxStaleness > 0, "Invalid staleness");

        priceFeed = AggregatorV3Interface(feed);
        maxStaleness = initialMaxStaleness;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ORACLE_ADMIN_ROLE, admin);
    }

    function getLatestPrice() public view returns (int256 price, uint8 decimals) {
        (, int256 answer,, uint256 updatedAt,) = priceFeed.latestRoundData();

        if (answer <= 0) revert InvalidPrice();
        if (block.timestamp - updatedAt > maxStaleness) revert StalePrice();

        return (answer, priceFeed.decimals());
    }

    function setPriceFeed(address newFeed) external onlyRole(ORACLE_ADMIN_ROLE) {
        require(newFeed != address(0), "Invalid feed");

        priceFeed = AggregatorV3Interface(newFeed);

        emit PriceFeedUpdated(newFeed);
    }

    function setMaxStaleness(uint256 newMaxStaleness) external onlyRole(ORACLE_ADMIN_ROLE) {
        require(newMaxStaleness > 0, "Invalid staleness");

        maxStaleness = newMaxStaleness;

        emit MaxStalenessUpdated(newMaxStaleness);
    }
}
