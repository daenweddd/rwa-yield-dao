// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SolidityMath {
    error BasisPointsTooHigh();

    function calculateFee(
        uint256 amount,
        uint256 basisPoints
    ) external pure returns (uint256) {
        if (basisPoints > 10_000) {
            revert BasisPointsTooHigh();
        }

        return (amount * basisPoints) / 10_000;
    }

    function min(uint256 a, uint256 b) external pure returns (uint256) {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b) external pure returns (uint256) {
        return a > b ? a : b;
    }
}