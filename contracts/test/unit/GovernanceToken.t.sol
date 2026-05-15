// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {GovernanceToken} from "../../src/token/GovernanceToken.sol";

contract GovernanceTokenTest is Test {
    GovernanceToken token;

    address initialReceiver = address(0xA11CE);
    address user1 = address(0xB0B);
    address user2 = address(0xCAFE);

    function setUp() public {
        token = new GovernanceToken(initialReceiver);
    }

    function testNameIsCorrect() public view {
        assertEq(token.name(), "RealYield Governance Token");
    }

    function testSymbolIsCorrect() public view {
        assertEq(token.symbol(), "RYG");
    }

    function testDecimalsIs18() public view {
        assertEq(token.decimals(), 18);
    }

    function testInitialSupplyMintedToReceiver() public view {
        assertEq(token.totalSupply(), 1_000_000 ether);
        assertEq(token.balanceOf(initialReceiver), 1_000_000 ether);
    }

    function testConstructorRevertsForZeroReceiver() public {
    vm.expectRevert();
    new GovernanceToken(address(0));
    }

    function testTransferWorks() public {
        vm.prank(initialReceiver);
        token.transfer(user1, 100 ether);

        assertEq(token.balanceOf(user1), 100 ether);
        assertEq(token.balanceOf(initialReceiver), 999_900 ether);
    }

    function testDelegateGivesVotingPower() public {
        vm.prank(initialReceiver);
        token.delegate(initialReceiver);

        assertEq(token.getVotes(initialReceiver), 1_000_000 ether);
    }

    function testVotingPowerMovesAfterTransferAndDelegation() public {
        vm.prank(initialReceiver);
        token.delegate(initialReceiver);

        vm.prank(initialReceiver);
        token.transfer(user1, 100 ether);

        assertEq(token.getVotes(initialReceiver), 999_900 ether);

        vm.prank(user1);
        token.delegate(user1);

        assertEq(token.getVotes(user1), 100 ether);
    }

    function testDelegationToAnotherAddressWorks() public {
        vm.prank(initialReceiver);
        token.delegate(user2);

        assertEq(token.getVotes(user2), 1_000_000 ether);
        assertEq(token.getVotes(initialReceiver), 0);
    }

   function testClockMatchesCurrentBlock() public view {
    assertEq(token.clock(), block.number);
    }


    function testCannotQueryPastVotesForFutureBlock() public {
        vm.expectRevert();
        token.getPastVotes(initialReceiver, block.number + 1);
    }
}