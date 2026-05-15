// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {RWAOracleAdapter} from "../../src/oracle/RWAOracleAdapter.sol";
import {MockV3Aggregator} from "../../src/mocks/MockV3Aggregator.sol";

contract RWAOracleAdapterTest is Test {
    MockV3Aggregator feed;
    RWAOracleAdapter adapter;

    address admin = address(0xA11CE);
    address stranger = address(0xBAD);

    uint256 maxStaleness = 1 hours;

    function setUp() public {
        feed = new MockV3Aggregator(8, 2_000e8);
        adapter = new RWAOracleAdapter(admin, address(feed), maxStaleness);
    }

    function testConstructorSetsValues() public view {
        assertEq(address(adapter.priceFeed()), address(feed));
        assertEq(adapter.maxStaleness(), maxStaleness);
        assertEq(adapter.decimals(), 8);
    }

    function testConstructorRevertsForZeroAdmin() public {
        vm.expectRevert(RWAOracleAdapter.ZeroAddress.selector);
        new RWAOracleAdapter(address(0), address(feed), maxStaleness);
    }

    function testConstructorRevertsForZeroFeed() public {
        vm.expectRevert(RWAOracleAdapter.ZeroAddress.selector);
        new RWAOracleAdapter(admin, address(0), maxStaleness);
    }

    function testConstructorRevertsForZeroStaleness() public {
        vm.expectRevert(RWAOracleAdapter.InvalidStaleness.selector);
        new RWAOracleAdapter(admin, address(feed), 0);
    }

    function testGetLatestPriceWorks() public view {
        assertEq(adapter.getLatestPrice(), 2_000e8);
    }

    function testGetLatestPriceRevertsForInvalidPrice() public {
        feed.updateAnswer(0);

        vm.expectRevert(RWAOracleAdapter.InvalidPrice.selector);
        adapter.getLatestPrice();
    }

   function testGetLatestPriceRevertsForStalePrice() public {
    vm.warp(10 hours);
    feed.setUpdatedAt(block.timestamp - maxStaleness - 1);

    vm.expectRevert(RWAOracleAdapter.StalePrice.selector);
    adapter.getLatestPrice();
    }

    function testUpdatePriceFeedWorks() public {
        MockV3Aggregator newFeed = new MockV3Aggregator(8, 3_000e8);

        vm.prank(admin);
        adapter.updatePriceFeed(address(newFeed));

        assertEq(address(adapter.priceFeed()), address(newFeed));
        assertEq(adapter.getLatestPrice(), 3_000e8);
    }

    function testUpdatePriceFeedByNonAdminReverts() public {
        MockV3Aggregator newFeed = new MockV3Aggregator(8, 3_000e8);

        vm.prank(stranger);
        vm.expectRevert();
        adapter.updatePriceFeed(address(newFeed));
    }

    function testUpdateMaxStalenessWorks() public {
        vm.prank(admin);
        adapter.updateMaxStaleness(2 hours);

        assertEq(adapter.maxStaleness(), 2 hours);
    }

    function testUpdateMaxStalenessByNonAdminReverts() public {
        vm.prank(stranger);
        vm.expectRevert();
        adapter.updateMaxStaleness(2 hours);
    }
}