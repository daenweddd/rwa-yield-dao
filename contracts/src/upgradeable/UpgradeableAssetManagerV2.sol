// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {UpgradeableAssetManager} from "./UpgradeableAssetManager.sol";

contract UpgradeableAssetManagerV2 is UpgradeableAssetManager {
    mapping(address => uint256) private _assetRiskScores;
    mapping(address => bool) private _assetFrozen;

    event AssetRiskScoreUpdated(address indexed asset, uint256 riskScore);
    event AssetFrozen(address indexed asset, bool frozen);

    function setAssetRiskScore(address asset, uint256 riskScore) external onlyRole(ASSET_ADMIN_ROLE) {
        require(asset != address(0), "Invalid asset");
        require(riskScore <= 100, "Risk score too high");

        _assetRiskScores[asset] = riskScore;

        emit AssetRiskScoreUpdated(asset, riskScore);
    }

    function setAssetFrozen(address asset, bool frozen) external onlyRole(ASSET_ADMIN_ROLE) {
        require(asset != address(0), "Invalid asset");

        _assetFrozen[asset] = frozen;

        emit AssetFrozen(asset, frozen);
    }

    function getAssetRiskScore(address asset) external view returns (uint256) {
        return _assetRiskScores[asset];
    }

    function isAssetFrozen(address asset) external view returns (bool) {
        return _assetFrozen[asset];
    }

    function version() external pure override returns (string memory) {
        return "V2";
    }
}
