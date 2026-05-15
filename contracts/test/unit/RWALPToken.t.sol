// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {RWALPToken} from "../../src/amm/RWALPToken.sol";

contract RWALPTokenTest is Test {
    RWALPToken lp;

    address amm = address(0xA11CE);
    address user = address(0xB0B);
    address stranger = address(0xBAD);

    function setUp() public {
        lp = new RWALPToken(amm);
    }

    function testConstructorSetsRoles() public view {
        assertTrue(lp.hasRole(lp.DEFAULT_ADMIN_ROLE(), amm));
        assertTrue(lp.hasRole(lp.MINTER_ROLE(), amm));
    }

    function testConstructorRevertsForZeroAmm() public {
        vm.expectRevert(RWALPToken.ZeroAddress.selector);
        new RWALPToken(address(0));
    }

    function testMintWorksForMinter() public {
        vm.prank(amm);
        lp.mint(user, 100 ether);

        assertEq(lp.balanceOf(user), 100 ether);
        assertEq(lp.totalSupply(), 100 ether);
    }

    function testMintRevertsForZeroAddress() public {
        vm.prank(amm);
        vm.expectRevert(RWALPToken.ZeroAddress.selector);
        lp.mint(address(0), 100 ether);
    }

    function testMintRevertsForNonMinter() public {
        vm.prank(stranger);
        vm.expectRevert();
        lp.mint(user, 100 ether);
    }

    function testBurnWorksForMinter() public {
        vm.startPrank(amm);
        lp.mint(user, 100 ether);
        lp.burn(user, 40 ether);
        vm.stopPrank();

        assertEq(lp.balanceOf(user), 60 ether);
        assertEq(lp.totalSupply(), 60 ether);
    }

    function testBurnRevertsForZeroAddress() public {
        vm.prank(amm);
        vm.expectRevert(RWALPToken.ZeroAddress.selector);
        lp.burn(address(0), 1 ether);
    }

    function testBurnRevertsForNonMinter() public {
        vm.prank(stranger);
        vm.expectRevert();
        lp.burn(user, 1 ether);
    }
}