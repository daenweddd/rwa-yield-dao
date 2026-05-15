// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {RWAYieldVault} from "../../src/vault/RWAYieldVault.sol";

contract VaultMockERC20 is ERC20 {
    constructor() ERC20("RWA Asset", "RWA") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract RWAYieldVaultTest is Test {
    VaultMockERC20 asset;
    RWAYieldVault vault;

    address admin = address(0xA11CE);
    address treasury = address(0x777);
    address user = address(0xB0B);
    address stranger = address(0xBAD);

    function setUp() public {
        asset = new VaultMockERC20();
        vault = new RWAYieldVault(asset, admin, treasury);

        asset.mint(user, 1_000 ether);

        vm.prank(user);
        asset.approve(address(vault), type(uint256).max);
    }

    function testConstructorSetsValues() public view {
        assertEq(address(vault.asset()), address(asset));
        assertEq(vault.treasury(), treasury);
        assertEq(vault.name(), "RealYield RWA Vault Share");
        assertEq(vault.symbol(), "ryRWA");
    }

    function testConstructorRevertsForZeroAdmin() public {
        vm.expectRevert(RWAYieldVault.ZeroAddress.selector);
        new RWAYieldVault(asset, address(0), treasury);
    }

    function testDepositWorks() public {
        vm.prank(user);
        uint256 shares = vault.deposit(100 ether, user);

        assertEq(shares, 100 ether);
        assertEq(vault.balanceOf(user), 100 ether);
        assertEq(vault.totalAssets(), 100 ether);
    }

    function testWithdrawWorks() public {
        vm.startPrank(user);
        vault.deposit(100 ether, user);
        uint256 sharesBurned = vault.withdraw(40 ether, user, user);
        vm.stopPrank();

        assertEq(sharesBurned, 40 ether);
        assertEq(vault.balanceOf(user), 60 ether);
    }

    function testRedeemWorks() public {
        vm.startPrank(user);
        vault.deposit(100 ether, user);
        uint256 assetsReturned = vault.redeem(50 ether, user, user);
        vm.stopPrank();

        assertEq(assetsReturned, 50 ether);
        assertEq(vault.balanceOf(user), 50 ether);
    }

    function testMintSharesWorks() public {
        vm.prank(user);
        uint256 assetsUsed = vault.mint(100 ether, user);

        assertEq(assetsUsed, 100 ether);
        assertEq(vault.balanceOf(user), 100 ether);
    }

    function testPauseBlocksDeposit() public {
        vm.prank(admin);
        vault.pause();

        vm.prank(user);
        vm.expectRevert();
        vault.deposit(100 ether, user);
    }

    function testUnpauseRestoresDeposit() public {
        vm.startPrank(admin);
        vault.pause();
        vault.unpause();
        vm.stopPrank();

        vm.prank(user);
        vault.deposit(100 ether, user);

        assertEq(vault.balanceOf(user), 100 ether);
    }

    function testUpdateTreasuryWorks() public {
        address newTreasury = address(0x888);

        vm.prank(admin);
        vault.updateTreasury(newTreasury);

        assertEq(vault.treasury(), newTreasury);
    }

    function testUpdateTreasuryByNonAdminReverts() public {
        vm.prank(stranger);
        vm.expectRevert();
        vault.updateTreasury(address(0x888));
    }

    function testUpdatePerformanceFeeWorks() public {
        vm.prank(admin);
        vault.updatePerformanceFeeBps(500);

        assertEq(vault.performanceFeeBps(), 500);
        assertEq(vault.previewPerformanceFee(100 ether), 5 ether);
    }

    function testUpdatePerformanceFeeTooHighReverts() public {
        vm.prank(admin);
        vm.expectRevert(RWAYieldVault.FeeTooHigh.selector);
        vault.updatePerformanceFeeBps(2_001);
    }
}