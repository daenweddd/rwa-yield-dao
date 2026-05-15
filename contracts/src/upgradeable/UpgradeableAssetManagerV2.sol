// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {UpgradeableAssetManager} from "./UpgradeableAssetManager.sol";

contract UpgradeableAssetManagerV2 is UpgradeableAssetManager {
    struct RiskConfig {
        uint256 riskScore;
        bool frozen;
    }

    mapping(address asset => RiskConfig config) internal riskConfigs;

    event RiskScoreUpdated(address indexed asset, uint256 oldRiskScore, uint256 newRiskScore);

    event AssetFreezeStatusUpdated(address indexed asset, bool frozen);

    error InvalidRiskScore();
    error AssetFrozen();

    function initializeV2() public reinitializer(2) {}

    function setRiskScore(address asset, uint256 newRiskScore) external onlyRole(ASSET_ADMIN_ROLE) {
        if (!assetConfigs[asset].supported) {
            revert AssetNotSupported();
        }

        if (newRiskScore > 100) {
            revert InvalidRiskScore();
        }

        uint256 oldRiskScore = riskConfigs[asset].riskScore;
        riskConfigs[asset].riskScore = newRiskScore;

        emit RiskScoreUpdated(asset, oldRiskScore, newRiskScore);
    }

    function setAssetFrozen(address asset, bool frozen) external onlyRole(ASSET_ADMIN_ROLE) {
        if (!assetConfigs[asset].supported) {
            revert AssetNotSupported();
        }

        riskConfigs[asset].frozen = frozen;

        emit AssetFreezeStatusUpdated(asset, frozen);
    }

    function getRiskConfig(address asset) external view returns (uint256 riskScore, bool frozen) {
        RiskConfig memory config = riskConfigs[asset];

        return (config.riskScore, config.frozen);
    }

    function requireAssetNotFrozen(address asset) external view {
        if (riskConfigs[asset].frozen) {
            revert AssetFrozen();
        }
    }

    function version() external pure override returns (string memory) {
        return "V2";
    }
}
