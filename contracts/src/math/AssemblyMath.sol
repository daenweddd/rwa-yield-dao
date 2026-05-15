// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract AssemblyMath {
    uint256 public constant MAX_BPS = 10_000;

    function calculateFee(uint256 amount, uint256 feeBps) external pure returns (uint256 result) {
        require(feeBps <= MAX_BPS, "Fee too high");

        assembly {
            result := div(mul(amount, feeBps), 10000)
        }
    }

    function min(uint256 a, uint256 b) external pure returns (uint256 result) {
        assembly {
            result := xor(b, mul(xor(a, b), lt(a, b)))
        }
    }
}
