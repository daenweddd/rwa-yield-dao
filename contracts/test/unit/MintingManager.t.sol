// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {RWAAssetToken} from "../../src/token/RWAAssetToken.sol";
import {IssuerRegistry} from "../../src/issuer/IssuerRegistry.sol";
import {MintingManager} from "../../src/issuer/MintingManager.sol";
import {RWAOracleAdapter} from "../../src/oracle/RWAOracleAdapter.sol";
import {MockV3Aggregator} from "../../src/mocks/MockV3Aggregator.sol";

contract MintingManagerTest is Test {
    RWAAssetToken token;
    IssuerRegistry registry;
    MockV3Aggregator feed;
    RWAOracleAdapter oracle;
    MintingManager manager;

    address admin = address(0xA11CE);
    address issuer = address(0x155E7);
    address user = address(0xB0B);
    address stranger = address(0xBAD);

    function setUp() public {
        token = new RWAAssetToken(admin, "Tokenized Gold", "ipfs://proof");
        registry = new IssuerRegistry(admin);
        feed = new MockV3Aggregator(8, 2_000e8);
        oracle = new RWAOracleAdapter(admin, address(feed), 1 hours);

        manager = new MintingManager(
            admin,
            address(token),
            address(registry),
            address(oracle)
        );

        vm.startPrank(admin);
        token.grantRole(token.MINTER_ROLE(), address(manager));
        token.grantRole(token.BURNER_ROLE(), address(manager));
        registry.addIssuer(issuer);
        vm.stopPrank();
    }

    function testConstructorSetsValues() public view {
        assertEq(address(manager.assetToken()), address(token));
        assertEq(address(manager.issuerRegistry()), address(registry));
        assertEq(address(manager.oracleAdapter()), address(oracle));
    }

    function testAuthorizedIssuerCanMint() public {
        vm.prank(issuer);
        manager.mint(user, 100 ether);

        assertEq(token.balanceOf(user), 100 ether);
    }

    function testUnauthorizedIssuerCannotMint() public {
        vm.prank(stranger);
        vm.expectRevert(MintingManager.NotAuthorizedIssuer.selector);
        manager.mint(user, 100 ether);
    }

    function testMintRevertsForZeroAddress() public {
        vm.prank(issuer);
        vm.expectRevert(MintingManager.ZeroAddress.selector);
        manager.mint(address(0), 100 ether);
    }

    function testMintRevertsForZeroAmount() public {
        vm.prank(issuer);
        vm.expectRevert(MintingManager.ZeroAmount.selector);
        manager.mint(user, 0);
    }

   function testMintRevertsIfOracleStale() public {
    vm.warp(10 hours);
    feed.setUpdatedAt(block.timestamp - 2 hours);

    vm.prank(issuer);
    vm.expectRevert(RWAOracleAdapter.StalePrice.selector);
    manager.mint(user, 100 ether);
    }

    function testAuthorizedIssuerCanBurn() public {
        vm.prank(issuer);
        manager.mint(user, 100 ether);

        vm.prank(issuer);
        manager.burn(user, 40 ether);

        assertEq(token.balanceOf(user), 60 ether);
    }

    function testUnauthorizedIssuerCannotBurn() public {
        vm.prank(stranger);
        vm.expectRevert(MintingManager.NotAuthorizedIssuer.selector);
        manager.burn(user, 10 ether);
    }

    function testPauseBlocksMint() public {
        vm.prank(admin);
        manager.pause();

        vm.prank(issuer);
        vm.expectRevert();
        manager.mint(user, 100 ether);
    }

    function testUnpauseRestoresMint() public {
        vm.startPrank(admin);
        manager.pause();
        manager.unpause();
        vm.stopPrank();

        vm.prank(issuer);
        manager.mint(user, 100 ether);

        assertEq(token.balanceOf(user), 100 ether);
    }
    function testConstructorRevertsForZeroAdmin() public {
    vm.expectRevert(MintingManager.ZeroAddress.selector);
    new MintingManager(
        address(0),
        address(token),
        address(registry),
        address(oracle)
    );
    }

    function testConstructorRevertsForZeroAssetToken() public {
    vm.expectRevert(MintingManager.ZeroAddress.selector);
    new MintingManager(
        admin,
        address(0),
        address(registry),
        address(oracle)
    );
    }

    function testConstructorRevertsForZeroRegistry() public {
    vm.expectRevert(MintingManager.ZeroAddress.selector);
    new MintingManager(
        admin,
        address(token),
        address(0),
        address(oracle)
    );
    }

    function testConstructorRevertsForZeroOracle() public {
    vm.expectRevert(MintingManager.ZeroAddress.selector);
    new MintingManager(
        admin,
        address(token),
        address(registry),
        address(0)
    );
    }

    function testBurnRevertsForZeroAddress() public {
    vm.prank(issuer);
    vm.expectRevert(MintingManager.ZeroAddress.selector);
    manager.burn(address(0), 100 ether);
    }

    function testBurnRevertsForZeroAmount() public {
    vm.prank(issuer);
    vm.expectRevert(MintingManager.ZeroAmount.selector);
    manager.burn(user, 0);
    }

    function testBurnRevertsIfOracleStale() public {
    vm.prank(issuer);
    manager.mint(user, 100 ether);

    vm.warp(10 hours);
    feed.setUpdatedAt(block.timestamp - 2 hours);

    vm.prank(issuer);
    vm.expectRevert(RWAOracleAdapter.StalePrice.selector);
    manager.burn(user, 10 ether);
    }

}