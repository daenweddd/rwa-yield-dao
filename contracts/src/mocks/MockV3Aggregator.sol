// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract MockV3Aggregator {
    uint8 public immutable decimals;
    string public description;
    uint256 public version = 1;

    uint80 private latestRoundId;
    int256 private latestAnswer;
    uint256 private latestStartedAt;
    uint256 private latestUpdatedAt;
    uint80 private latestAnsweredInRound;

    event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

    event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);

    constructor(uint8 _decimals, int256 _initialAnswer) {
        decimals = _decimals;
        description = "Mock Chainlink Aggregator";

        updateAnswer(_initialAnswer);
    }

    function updateAnswer(int256 answer) public {
        latestRoundId++;

        latestAnswer = answer;
        latestStartedAt = block.timestamp;
        latestUpdatedAt = block.timestamp;
        latestAnsweredInRound = latestRoundId;

        emit NewRound(latestRoundId, msg.sender, block.timestamp);
        emit AnswerUpdated(answer, latestRoundId, block.timestamp);
    }

    function setUpdatedAt(uint256 updatedAt) external {
        latestUpdatedAt = updatedAt;
    }

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (latestRoundId, latestAnswer, latestStartedAt, latestUpdatedAt, latestAnsweredInRound);
    }

    function getRoundData(uint80 roundId) external view returns (uint80, int256, uint256, uint256, uint80) {
        return (roundId, latestAnswer, latestStartedAt, latestUpdatedAt, latestAnsweredInRound);
    }
}
