// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {AssemblyMath} from "../../src/math/AssemblyMath.sol";
import {SolidityMath} from "../../src/math/SolidityMath.sol";

contract MathTest is Test {
    AssemblyMath assemblyMath;
    SolidityMath solidityMath;

    function setUp() public {
        assemblyMath = new AssemblyMath();
        solidityMath = new SolidityMath();
    }

    function testCalculateFeeMatchesSolidityVersion() public view {
        uint256 amount = 1_000 ether;
        uint256 bps = 300;

        uint256 assemblyFee = assemblyMath.calculateFee(amount, bps);
        uint256 solidityFee = solidityMath.calculateFee(amount, bps);

        assertEq(assemblyFee, solidityFee);
        assertEq(assemblyFee, 30 ether);
    }

    function testCalculateFeeRevertsWhenBpsTooHigh() public {
        vm.expectRevert(AssemblyMath.BasisPointsTooHigh.selector);
        assemblyMath.calculateFee(1_000 ether, 10_001);

        vm.expectRevert(SolidityMath.BasisPointsTooHigh.selector);
        solidityMath.calculateFee(1_000 ether, 10_001);
    }

    function testMinMatchesSolidityVersion() public view {
        assertEq(assemblyMath.min(10, 20), solidityMath.min(10, 20));
        assertEq(assemblyMath.min(20, 10), solidityMath.min(20, 10));
    }

    function testMaxMatchesSolidityVersion() public view {
        assertEq(assemblyMath.max(10, 20), solidityMath.max(10, 20));
        assertEq(assemblyMath.max(20, 10), solidityMath.max(20, 10));
    }

    function testAssemblyCalculateFeeZeroAmount() public view {
    assertEq(assemblyMath.calculateFee(0, 300), 0);
    }
    
    function testAssemblyMinEqualValues() public view {
    assertEq(assemblyMath.min(10, 10), 10);
    }
    
    function testAssemblyMaxEqualValues() public view {
    assertEq(assemblyMath.max(10, 10), 10);
    }
}