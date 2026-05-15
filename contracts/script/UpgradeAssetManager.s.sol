// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {UpgradeableAssetManager} from "../src/upgradeable/UpgradeableAssetManager.sol";
import {UpgradeableAssetManagerV2} from "../src/upgradeable/UpgradeableAssetManagerV2.sol";

contract UpgradeAssetManager is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address assetManagerProxyAddress = vm.envAddress("ASSET_MANAGER_PROXY");

        vm.startBroadcast(deployerPrivateKey);

        UpgradeableAssetManagerV2 newImplementation = new UpgradeableAssetManagerV2();

        UpgradeableAssetManager proxy = UpgradeableAssetManager(assetManagerProxyAddress);

        proxy.upgradeToAndCall(address(newImplementation), "");

        console2.log("AssetManager proxy:", assetManagerProxyAddress);
        console2.log("New implementation:", address(newImplementation));
        console2.log("Version after upgrade:", proxy.version());

        vm.stopBroadcast();
    }
}
