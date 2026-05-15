// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {RWATreasury} from "../../src/treasury/RWATreasury.sol";

contract TreasuryMockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MOCK") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract RWATreasuryTest is Test {
    RWATreasury treasury;
    TreasuryMockERC20 token;

    address admin = address(0xA11CE);
    address receiver = address(0xB0B);
    address stranger = address(0xBAD);

    function setUp() public {
        treasury = new RWATreasury(admin);
        token = new TreasuryMockERC20();

        vm.deal(address(treasury), 10 ether);
        token.mint(address(treasury), 1_000 ether);
    }

    function testConstructorSetsRoles() public view {
        assertTrue(treasury.hasRole(treasury.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(treasury.hasRole(treasury.TREASURY_MANAGER_ROLE(), admin));
    }

    function testConstructorRevertsForZeroAdmin() public {
        vm.expectRevert(RWATreasury.ZeroAddress.selector);
        new RWATreasury(address(0));
    }

    function testEtherBalance() public view {
        assertEq(treasury.etherBalance(), 10 ether);
    }

    function testERC20Balance() public view {
        assertEq(treasury.erc20Balance(address(token)), 1_000 ether);
    }

    function testWithdrawEtherWorks() public {
        uint256 beforeBalance = receiver.balance;

        vm.prank(admin);
        treasury.withdrawEther(payable(receiver), 1 ether);

        assertEq(receiver.balance, beforeBalance + 1 ether);
        assertEq(address(treasury).balance, 9 ether);
    }

    function testWithdrawEtherByNonManagerReverts() public {
        vm.prank(stranger);
        vm.expectRevert();
        treasury.withdrawEther(payable(receiver), 1 ether);
    }

    function testWithdrawEtherRevertsForZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(RWATreasury.ZeroAddress.selector);
        treasury.withdrawEther(payable(address(0)), 1 ether);
    }

    function testWithdrawERC20Works() public {
        vm.prank(admin);
        treasury.withdrawERC20(address(token), receiver, 100 ether);

        assertEq(token.balanceOf(receiver), 100 ether);
        assertEq(token.balanceOf(address(treasury)), 900 ether);
    }

    function testWithdrawERC20ByNonManagerReverts() public {
        vm.prank(stranger);
        vm.expectRevert();
        treasury.withdrawERC20(address(token), receiver, 100 ether);
    }
}