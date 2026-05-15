// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {GovernanceToken} from "../src/token/GovernanceToken.sol";
import {RWAAssetToken} from "../src/token/RWAAssetToken.sol";
import {AssetCertificateNFT} from "../src/token/AssetCertificateNFT.sol";

import {IssuerRegistry} from "../src/issuer/IssuerRegistry.sol";
import {MintingManager} from "../src/issuer/MintingManager.sol";

import {RWAOracleAdapter} from "../src/oracle/RWAOracleAdapter.sol";
import {RWAYieldVault} from "../src/vault/RWAYieldVault.sol";
import {RWAAMM} from "../src/amm/RWAAMM.sol";
import {RWATreasury} from "../src/treasury/RWATreasury.sol";

import {RWATimelock} from "../src/governance/RWATimelock.sol";
import {RWAGovernor} from "../src/governance/RWAGovernor.sol";

import {RWAFactory} from "../src/factory/RWAFactory.sol";
import {UpgradeableAssetManager} from "../src/upgradeable/UpgradeableAssetManager.sol";
import {MockV3Aggregator} from "../src/mocks/MockV3Aggregator.sol";

contract DeployRWA is Script {
    uint256 public constant TIMELOCK_DELAY = 2 days;
    uint256 public constant ORACLE_MAX_STALENESS = 1 days;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console2.log("Deploying contracts with deployer:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        MockV3Aggregator mockFeed = new MockV3Aggregator(8, 100_00000000);

        GovernanceToken governanceToken = new GovernanceToken(deployer);

        address[] memory proposers = new address[](0);

        address[] memory executors = new address[](1);
        executors[0] = address(0);

        RWATimelock timelock = new RWATimelock(TIMELOCK_DELAY, proposers, executors, deployer);

        RWAGovernor governor = new RWAGovernor(governanceToken, timelock);

        RWATreasury treasury = new RWATreasury(deployer);

        RWAAssetToken rwaToken = new RWAAssetToken(deployer, "RealYield RWA Asset Token", "rRWA");

        AssetCertificateNFT certificateNFT = new AssetCertificateNFT(deployer);

        RWAOracleAdapter oracleAdapter = new RWAOracleAdapter(address(mockFeed), deployer, ORACLE_MAX_STALENESS);

        IssuerRegistry issuerRegistry = new IssuerRegistry(deployer);

        MintingManager mintingManager =
            new MintingManager(address(rwaToken), address(issuerRegistry), address(oracleAdapter), deployer);

        RWAYieldVault vault = new RWAYieldVault(rwaToken, deployer, address(treasury));

        RWAAMM amm = new RWAAMM(address(rwaToken), address(governanceToken));

        RWAFactory factory = new RWAFactory();

        UpgradeableAssetManager assetManagerImplementation = new UpgradeableAssetManager();

        bytes memory initData = abi.encodeCall(UpgradeableAssetManager.initialize, (deployer));

        ERC1967Proxy assetManagerProxy = new ERC1967Proxy(address(assetManagerImplementation), initData);

        rwaToken.grantRole(rwaToken.MINTER_ROLE(), address(mintingManager));

        rwaToken.grantRole(rwaToken.BURNER_ROLE(), address(mintingManager));

        issuerRegistry.addIssuer(deployer);

        timelock.grantRole(timelock.PROPOSER_ROLE(), address(governor));

        timelock.grantRole(timelock.EXECUTOR_ROLE(), address(0));

        console2.log("MockV3Aggregator:", address(mockFeed));
        console2.log("GovernanceToken:", address(governanceToken));
        console2.log("RWATimelock:", address(timelock));
        console2.log("RWAGovernor:", address(governor));
        console2.log("RWATreasury:", address(treasury));
        console2.log("RWAAssetToken:", address(rwaToken));
        console2.log("AssetCertificateNFT:", address(certificateNFT));
        console2.log("RWAOracleAdapter:", address(oracleAdapter));
        console2.log("IssuerRegistry:", address(issuerRegistry));
        console2.log("MintingManager:", address(mintingManager));
        console2.log("RWAYieldVault:", address(vault));
        console2.log("RWAAMM:", address(amm));
        console2.log("RWAFactory:", address(factory));
        console2.log("AssetManagerImplementation:", address(assetManagerImplementation));
        console2.log("AssetManagerProxy:", address(assetManagerProxy));

        vm.stopBroadcast();
    }
}
