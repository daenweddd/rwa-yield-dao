// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {GovernanceToken} from "../../src/token/GovernanceToken.sol";
import {RWAGovernor} from "../../src/governance/RWAGovernor.sol";
import {RWATimelock} from "../../src/governance/RWATimelock.sol";

contract RWAGovernorTest is Test {
    GovernanceToken token;
    RWATimelock timelock;
    RWAGovernor governor;

    address admin = address(0xA11CE);

    function setUp() public {
        token = new GovernanceToken(admin);

        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = address(0);

        timelock = new RWATimelock(
            2 days,
            proposers,
            executors,
            admin
        );

        governor = new RWAGovernor(token, timelock);
    }

    function testGovernorName() public view {
        assertEq(governor.name(), "RealYield RWA Governor");
    }

    function testGovernorVotingDelay() public view {
        assertEq(governor.votingDelay(), 7200);
    }

    function testGovernorVotingPeriod() public view {
        assertEq(governor.votingPeriod(), 50400);
    }

    function testProposalThreshold() public view {
        assertEq(governor.proposalThreshold(), 10_000 ether);
    }

    function testTimelockDelay() public view {
        assertEq(timelock.getMinDelay(), 2 days);
    }
}