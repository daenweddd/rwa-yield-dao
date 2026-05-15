// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {RWAAssetToken} from "../../src/token/RWAAssetToken.sol";

contract RWAAssetTokenTest is Test {
    RWAAssetToken token;

    address admin = address(0xA11CE);
    address user = address(0xB0B);
    address stranger = address(0xBAD);

    function setUp() public {
        token = new RWAAssetToken(admin, "Tokenized Gold", "ipfs://proof");
    }

    function testMetadataIsCorrect() public view {
        assertEq(token.name(), "RealYield RWA Asset Token");
        assertEq(token.symbol(), "RYRWA");
        assertEq(token.assetName(), "Tokenized Gold");
        assertEq(token.assetProofURI(), "ipfs://proof");
    }

    function testAdminHasRoles() public view {
        assertTrue(token.hasRole(token.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(token.hasRole(token.MINTER_ROLE(), admin));
        assertTrue(token.hasRole(token.BURNER_ROLE(), admin));
        assertTrue(token.hasRole(token.PAUSER_ROLE(), admin));
    }

    function testConstructorRevertsForZeroAdmin() public {
        vm.expectRevert(RWAAssetToken.ZeroAddress.selector);
        new RWAAssetToken(address(0), "Asset", "uri");
    }

    function testConstructorRevertsForEmptyAssetName() public {
        vm.expectRevert(RWAAssetToken.EmptyString.selector);
        new RWAAssetToken(admin, "", "uri");
    }

    function testMintByMinterWorks() public {
        vm.prank(admin);
        token.mint(user, 100 ether);

        assertEq(token.balanceOf(user), 100 ether);
        assertEq(token.totalSupply(), 100 ether);
    }

    function testMintRevertsForZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(RWAAssetToken.ZeroAddress.selector);
        token.mint(address(0), 100 ether);
    }

    function testMintByNonMinterReverts() public {
        vm.prank(stranger);
        vm.expectRevert();
        token.mint(user, 100 ether);
    }

    function testBurnByBurnerWorks() public {
        vm.startPrank(admin);
        token.mint(user, 100 ether);
        token.burn(user, 40 ether);
        vm.stopPrank();

        assertEq(token.balanceOf(user), 60 ether);
        assertEq(token.totalSupply(), 60 ether);
    }

    function testBurnByNonBurnerReverts() public {
        vm.prank(admin);
        token.mint(user, 100 ether);

        vm.prank(stranger);
        vm.expectRevert();
        token.burn(user, 10 ether);
    }

    function testPauseBlocksTransfers() public {
        vm.startPrank(admin);
        token.mint(user, 100 ether);
        token.pause();
        vm.stopPrank();

        vm.prank(user);
        vm.expectRevert();
        token.transfer(stranger, 10 ether);
    }

    function testUnpauseRestoresTransfers() public {
        vm.startPrank(admin);
        token.mint(user, 100 ether);
        token.pause();
        token.unpause();
        vm.stopPrank();

        vm.prank(user);
        token.transfer(stranger, 10 ether);

        assertEq(token.balanceOf(stranger), 10 ether);
    }

    function testUpdateAssetProofURI() public {
        vm.prank(admin);
        token.updateAssetProofURI("ipfs://new-proof");

        assertEq(token.assetProofURI(), "ipfs://new-proof");
    }

    function testUpdateAssetProofURIByNonAdminReverts() public {
        vm.prank(stranger);
        vm.expectRevert();
        token.updateAssetProofURI("ipfs://new-proof");
    }

    function testBurnRevertsForZeroAddress() public {
    vm.prank(admin);
    vm.expectRevert(RWAAssetToken.ZeroAddress.selector);
    token.burn(address(0), 100 ether);
    }

    function testPauseByNonPauserReverts() public {
    vm.prank(stranger);
    vm.expectRevert();
    token.pause();
    }

    function testUnpauseByNonPauserReverts() public {
    vm.prank(stranger);
    vm.expectRevert();
    token.unpause();
    }

    function testTransferWorksWhenNotPaused() public {
    vm.prank(admin);
    token.mint(user, 100 ether);

    vm.prank(user);
    token.transfer(stranger, 25 ether);

    assertEq(token.balanceOf(stranger), 25 ether);
    assertEq(token.balanceOf(user), 75 ether);
    }
}