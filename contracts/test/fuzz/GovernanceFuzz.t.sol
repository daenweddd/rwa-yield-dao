// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {GovernanceToken} from "../../src/token/GovernanceToken.sol";

contract GovernanceFuzzTest is Test {
    GovernanceToken token;

    address holder = address(0xA11CE);
    address voter = address(0xB0B);
    address delegatee = address(0xCAFE);

    function setUp() public {
        token = new GovernanceToken(holder);
    }

    function testFuzzTransferGovernanceTokens(uint256 amount) public {
        amount = bound(amount, 1 wei, token.balanceOf(holder));

        vm.prank(holder);
        token.transfer(voter, amount);

        assertEq(token.balanceOf(voter), amount);
        assertEq(token.balanceOf(holder), 1_000_000 ether - amount);
    }

    function testFuzzDelegateVotingPower(uint256 amount) public {
        amount = bound(amount, 1 wei, token.balanceOf(holder));

        vm.prank(holder);
        token.transfer(voter, amount);

        vm.prank(voter);
        token.delegate(voter);

        assertEq(token.getVotes(voter), amount);
    }

    function testFuzzDelegateToAnotherAddress(uint256 amount) public {
        amount = bound(amount, 1 wei, token.balanceOf(holder));

        vm.prank(holder);
        token.transfer(voter, amount);

        vm.prank(voter);
        token.delegate(delegatee);

        assertEq(token.getVotes(delegatee), amount);
        assertEq(token.getVotes(voter), 0);
    }

    function testFuzzVotingPowerMovesAfterTransfer(uint256 amount) public {
        amount = bound(amount, 1 wei, 500_000 ether);

        vm.prank(holder);
        token.delegate(holder);

        uint256 votesBefore = token.getVotes(holder);

        vm.prank(holder);
        token.transfer(voter, amount);

        assertEq(token.getVotes(holder), votesBefore - amount);

        vm.prank(voter);
        token.delegate(voter);

        assertEq(token.getVotes(voter), amount);
    }
}