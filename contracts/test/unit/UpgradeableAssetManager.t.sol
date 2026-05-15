// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {UpgradeableAssetManager} from "../../src/upgradeable/UpgradeableAssetManager.sol";
import {UpgradeableAssetManagerV2} from "../../src/upgradeable/UpgradeableAssetManagerV2.sol";

contract UpgradeableAssetManagerTest is Test {
    UpgradeableAssetManager manager;
    UpgradeableAssetManagerV2 managerV2;

    address admin = address(0xA11CE);
    address asset = address(0xA55E7);
    address oracle = address(0x0A11CE);
    address stranger = address(0xBAD);

    function setUp() public {
        manager = new UpgradeableAssetManager();
        manager.initialize(admin);

        managerV2 = new UpgradeableAssetManagerV2();
        managerV2.initialize(admin);
    }

    function testInitializeSetsRoles() public view {
        assertTrue(manager.hasRole(manager.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(manager.hasRole(manager.ASSET_ADMIN_ROLE(), admin));
        assertTrue(manager.hasRole(manager.UPGRADER_ROLE(), admin));
    }

    function testInitializeRevertsForZeroAdmin() public {
        UpgradeableAssetManager newManager = new UpgradeableAssetManager();

        vm.expectRevert(UpgradeableAssetManager.ZeroAddress.selector);
        newManager.initialize(address(0));
    }

    function testAddAssetWorks() public {
        vm.prank(admin);
        manager.addAsset(asset, 15_000, oracle);

        assertTrue(manager.isAssetSupported(asset));

        (bool supported, uint256 ratio, address savedOracle) =
            manager.getAssetConfig(asset);

        assertTrue(supported);
        assertEq(ratio, 15_000);
        assertEq(savedOracle, oracle);
    }

    function testAddAssetByNonAdminReverts() public {
        vm.prank(stranger);
        vm.expectRevert();
        manager.addAsset(asset, 15_000, oracle);
    }

    function testAddAssetRevertsForZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(UpgradeableAssetManager.ZeroAddress.selector);
        manager.addAsset(address(0), 15_000, oracle);
    }

    function testAddAssetRevertsForInvalidRatio() public {
        vm.prank(admin);
        vm.expectRevert(UpgradeableAssetManager.InvalidCollateralRatio.selector);
        manager.addAsset(asset, 0, oracle);
    }

    function testRemoveAssetWorks() public {
        vm.startPrank(admin);
        manager.addAsset(asset, 15_000, oracle);
        manager.removeAsset(asset);
        vm.stopPrank();

        assertFalse(manager.isAssetSupported(asset));
    }

    function testUpdateCollateralRatioWorks() public {
        vm.startPrank(admin);
        manager.addAsset(asset, 15_000, oracle);
        manager.updateCollateralRatio(asset, 12_000);
        vm.stopPrank();

        (, uint256 ratio, ) = manager.getAssetConfig(asset);
        assertEq(ratio, 12_000);
    }

    function testUpdateOracleWorks() public {
        address newOracle = address(0x1234);

        vm.startPrank(admin);
        manager.addAsset(asset, 15_000, oracle);
        manager.updateOracle(asset, newOracle);
        vm.stopPrank();

        (, , address savedOracle) = manager.getAssetConfig(asset);
        assertEq(savedOracle, newOracle);
    }

    function testVersionV1() public view {
        assertEq(manager.version(), "V1");
    }

    function testV2RiskScoreWorks() public {
        vm.startPrank(admin);
        managerV2.addAsset(asset, 15_000, oracle);
        managerV2.setRiskScore(asset, 80);
        vm.stopPrank();

        (uint256 riskScore, bool frozen) = managerV2.getRiskConfig(asset);

        assertEq(riskScore, 80);
        assertFalse(frozen);
    }

    function testV2FreezeWorks() public {
        vm.startPrank(admin);
        managerV2.addAsset(asset, 15_000, oracle);
        managerV2.setAssetFrozen(asset, true);
        vm.stopPrank();

        (, bool frozen) = managerV2.getRiskConfig(asset);
        assertTrue(frozen);

        vm.expectRevert(UpgradeableAssetManagerV2.AssetFrozen.selector);
        managerV2.requireAssetNotFrozen(asset);
    }

    function testVersionV2() public view {
        assertEq(managerV2.version(), "V2");
    }
}