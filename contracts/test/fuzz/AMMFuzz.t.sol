// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

contract AMMFuzzTest is Test {
    function testFuzzPlaceholder(uint256 amount) public {
        amount = bound(amount, 1, 1_000_000 ether);
        assertGt(amount, 0);
    }
}
