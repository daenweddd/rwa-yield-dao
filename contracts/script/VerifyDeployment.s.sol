// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {GovernanceToken} from "../src/token/GovernanceToken.sol";
import {RWAAssetToken} from "../src/token/RWAAssetToken.sol";
import {IssuerRegistry} from "../src/issuer/IssuerRegistry.sol";
import {RWAOracleAdapter} from "../src/oracle/RWAOracleAdapter.sol";
import {RWAYieldVault} from "../src/vault/RWAYieldVault.sol";
import {RWATimelock} from "../src/governance/RWATimelock.sol";
import {RWAGovernor} from "../src/governance/RWAGovernor.sol";
import {UpgradeableAssetManager} from "../src/upgradeable/UpgradeableAssetManager.sol";

contract VerifyDeployment is Script {
    uint256 public constant EXPECTED_TIMELOCK_DELAY = 2 days;
    uint256 public constant EXPECTED_VOTING_DELAY = 7200;
    uint256 public constant EXPECTED_VOTING_PERIOD = 50400;
    uint256 public constant EXPECTED_QUORUM_NUMERATOR = 4;

    function run() external view {
        address governanceTokenAddress = vm.envAddress("GOVERNANCE_TOKEN");
        address rwaTokenAddress = vm.envAddress("RWA_TOKEN");
        address issuerRegistryAddress = vm.envAddress("ISSUER_REGISTRY");
        address oracleAdapterAddress = vm.envAddress("ORACLE_ADAPTER");
        address vaultAddress = vm.envAddress("VAULT");
        address timelockAddress = vm.envAddress("TIMELOCK");
        address governorAddress = vm.envAddress("GOVERNOR");
        address assetManagerProxyAddress = vm.envAddress("ASSET_MANAGER_PROXY");
        address mintingManagerAddress = vm.envAddress("MINTING_MANAGER");

        GovernanceToken governanceToken = GovernanceToken(governanceTokenAddress);

        RWAAssetToken rwaToken = RWAAssetToken(rwaTokenAddress);

        IssuerRegistry issuerRegistry = IssuerRegistry(issuerRegistryAddress);

        RWAOracleAdapter oracleAdapter = RWAOracleAdapter(oracleAdapterAddress);

        RWAYieldVault vault = RWAYieldVault(vaultAddress);

        RWATimelock timelock = RWATimelock(payable(timelockAddress));

        RWAGovernor governor = RWAGovernor(payable(governorAddress));

        UpgradeableAssetManager assetManager = UpgradeableAssetManager(assetManagerProxyAddress);

        console2.log("Starting deployment verification...");

        require(timelock.getMinDelay() == EXPECTED_TIMELOCK_DELAY, "Wrong timelock delay");

        require(governor.votingDelay() == EXPECTED_VOTING_DELAY, "Wrong voting delay");

        require(governor.votingPeriod() == EXPECTED_VOTING_PERIOD, "Wrong voting period");

        require(governor.quorumNumerator() == EXPECTED_QUORUM_NUMERATOR, "Wrong quorum numerator");

        require(address(vault.asset()) == rwaTokenAddress, "Vault asset is not RWA token");

        require(address(oracleAdapter.priceFeed()) != address(0), "Oracle feed is zero address");

        require(rwaToken.hasRole(rwaToken.MINTER_ROLE(), mintingManagerAddress), "MintingManager has no MINTER_ROLE");

        require(rwaToken.hasRole(rwaToken.BURNER_ROLE(), mintingManagerAddress), "MintingManager has no BURNER_ROLE");

        require(governanceToken.totalSupply() > 0, "Governance token supply is zero");

        require(bytes(assetManager.version()).length > 0, "AssetManager version missing");

        require(address(issuerRegistry) != address(0), "IssuerRegistry is zero");

        console2.log("GovernanceToken:", governanceTokenAddress);
        console2.log("RWAAssetToken:", rwaTokenAddress);
        console2.log("IssuerRegistry:", issuerRegistryAddress);
        console2.log("OracleAdapter:", oracleAdapterAddress);
        console2.log("Vault:", vaultAddress);
        console2.log("Timelock:", timelockAddress);
        console2.log("Governor:", governorAddress);
        console2.log("AssetManagerProxy:", assetManagerProxyAddress);

        console2.log("Verification passed.");
    }
}
