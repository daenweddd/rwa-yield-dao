// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {RWAYieldVault} from "../../src/vault/RWAYieldVault.sol";

contract VaultFuzzERC20 is ERC20 {
    constructor() ERC20("RWA Asset", "RWA") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract VaultFuzzTest is Test {
    VaultFuzzERC20 asset;
    RWAYieldVault vault;

    address admin = address(0xA11CE);
    address treasury = address(0x777);
    address user = address(0xB0B);

    function setUp() public {
        asset = new VaultFuzzERC20();
        vault = new RWAYieldVault(asset, admin, treasury);

        asset.mint(user, 1_000_000 ether);

        vm.prank(user);
        asset.approve(address(vault), type(uint256).max);
    }

    function testFuzzDeposit(uint256 assets) public {
        assets = bound(assets, 1 wei, 100_000 ether);

        vm.prank(user);
        uint256 shares = vault.deposit(assets, user);

        assertEq(shares, assets);
        assertEq(vault.balanceOf(user), shares);
        assertEq(vault.totalAssets(), assets);
    }

    function testFuzzWithdrawAfterDeposit(uint256 assets, uint256 withdrawAmount) public {
        assets = bound(assets, 1 ether, 100_000 ether);
        withdrawAmount = bound(withdrawAmount, 1 wei, assets);

        vm.startPrank(user);
        vault.deposit(assets, user);

        uint256 sharesBurned = vault.withdraw(withdrawAmount, user, user);
        vm.stopPrank();

        assertEq(sharesBurned, withdrawAmount);
        assertEq(vault.totalAssets(), assets - withdrawAmount);
    }

    function testFuzzRedeemAfterDeposit(uint256 assets, uint256 sharesToRedeem) public {
        assets = bound(assets, 1 ether, 100_000 ether);
        sharesToRedeem = bound(sharesToRedeem, 1 wei, assets);

        vm.startPrank(user);
        vault.deposit(assets, user);

        uint256 assetsReturned = vault.redeem(sharesToRedeem, user, user);
        vm.stopPrank();

        assertEq(assetsReturned, sharesToRedeem);
        assertEq(vault.balanceOf(user), assets - sharesToRedeem);
    }

    function testFuzzMintShares(uint256 shares) public {
        shares = bound(shares, 1 wei, 100_000 ether);

        vm.prank(user);
        uint256 assetsUsed = vault.mint(shares, user);

        assertEq(assetsUsed, shares);
        assertEq(vault.balanceOf(user), shares);
        assertEq(vault.totalAssets(), shares);
    }

    function testFuzzPerformanceFee(uint256 yieldAmount, uint256 feeBps) public {
        yieldAmount = bound(yieldAmount, 1 wei, 1_000_000 ether);
        feeBps = bound(feeBps, 0, vault.MAX_FEE_BPS());

        vm.prank(admin);
        vault.updatePerformanceFeeBps(feeBps);

        uint256 expectedFee = (yieldAmount * feeBps) / vault.BPS_DENOMINATOR();

        assertEq(vault.previewPerformanceFee(yieldAmount), expectedFee);
    }
}