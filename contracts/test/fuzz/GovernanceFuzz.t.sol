// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

contract GovernanceFuzzTest is Test {
    function testFuzzPlaceholder(uint256 votes) public {
        votes = bound(votes, 1, 1_000_000 ether);
        assertGt(votes, 0);
    }
}
