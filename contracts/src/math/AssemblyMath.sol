// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract AssemblyMath {
    error BasisPointsTooHigh();

    function calculateFee(
        uint256 amount,
        uint256 basisPoints
    ) external pure returns (uint256 fee) {
        if (basisPoints > 10_000) {
            revert BasisPointsTooHigh();
        }

        assembly {
            fee := div(mul(amount, basisPoints), 10000)
        }
    }

    function min(uint256 a, uint256 b) external pure returns (uint256 result) {
        assembly {
            result := xor(b, mul(xor(a, b), lt(a, b)))
        }
    }

    function max(uint256 a, uint256 b) external pure returns (uint256 result) {
        assembly {
            result := xor(a, mul(xor(a, b), lt(a, b)))
        }
    }
}