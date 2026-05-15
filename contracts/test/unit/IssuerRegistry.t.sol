// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {IssuerRegistry} from "../../src/issuer/IssuerRegistry.sol";

contract IssuerRegistryTest is Test {
    IssuerRegistry registry;

    address admin = address(0xA11CE);
    address issuer = address(0x155E7);
    address stranger = address(0xBAD);

    function setUp() public {
        registry = new IssuerRegistry(admin);
    }

    function testAdminHasRoles() public view {
        assertTrue(registry.hasRole(registry.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(registry.hasRole(registry.ISSUER_ADMIN_ROLE(), admin));
    }

    function testConstructorRevertsForZeroAdmin() public {
        vm.expectRevert(IssuerRegistry.ZeroAddress.selector);
        new IssuerRegistry(address(0));
    }

    function testAddIssuerWorks() public {
        vm.prank(admin);
        registry.addIssuer(issuer);

        assertTrue(registry.isIssuer(issuer));
    }

    function testAddIssuerRevertsForZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(IssuerRegistry.ZeroAddress.selector);
        registry.addIssuer(address(0));
    }

    function testAddIssuerByNonAdminReverts() public {
        vm.prank(stranger);
        vm.expectRevert();
        registry.addIssuer(issuer);
    }

    function testRemoveIssuerWorks() public {
        vm.startPrank(admin);
        registry.addIssuer(issuer);
        registry.removeIssuer(issuer);
        vm.stopPrank();

        assertFalse(registry.isIssuer(issuer));
    }

    function testRemoveIssuerByNonAdminReverts() public {
        vm.prank(stranger);
        vm.expectRevert();
        registry.removeIssuer(issuer);
    }
}