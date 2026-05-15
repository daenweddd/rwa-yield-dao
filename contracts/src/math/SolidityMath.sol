// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SolidityMath {
    uint256 public constant MAX_BPS = 10_000;

    function calculateFee(uint256 amount, uint256 feeBps) external pure returns (uint256) {
        require(feeBps <= MAX_BPS, "Fee too high");

        return (amount * feeBps) / MAX_BPS;
    }

    function min(uint256 a, uint256 b) external pure returns (uint256) {
        return a < b ? a : b;
    }
}
