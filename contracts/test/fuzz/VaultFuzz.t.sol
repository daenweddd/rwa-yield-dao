// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

contract VaultFuzzTest is Test {
    function testFuzzPlaceholder(uint256 assets) public {
        assets = bound(assets, 1, 1_000_000 ether);
        assertGt(assets, 0);
    }
}
