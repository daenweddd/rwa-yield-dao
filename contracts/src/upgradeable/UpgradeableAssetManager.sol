// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract UpgradeableAssetManager is Initializable, UUPSUpgradeable, AccessControlUpgradeable {
    bytes32 public constant ASSET_ADMIN_ROLE = keccak256("ASSET_ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    struct AssetConfig {
        bool supported;
        uint256 collateralRatioBps;
        address oracle;
    }

    mapping(address asset => AssetConfig config) internal assetConfigs;

    event AssetAdded(address indexed asset, uint256 collateralRatioBps, address indexed oracle);

    event AssetRemoved(address indexed asset);

    event CollateralRatioUpdated(address indexed asset, uint256 oldRatioBps, uint256 newRatioBps);

    event OracleUpdated(address indexed asset, address indexed oldOracle, address indexed newOracle);

    error ZeroAddress();
    error InvalidCollateralRatio();
    error AssetNotSupported();
    error AssetAlreadySupported();

    function initialize(address admin) public initializer {
        if (admin == address(0)) {
            revert ZeroAddress();
        }

        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ASSET_ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
    }

    function addAsset(address asset, uint256 collateralRatioBps, address oracle) external onlyRole(ASSET_ADMIN_ROLE) {
        if (asset == address(0) || oracle == address(0)) {
            revert ZeroAddress();
        }

        if (assetConfigs[asset].supported) {
            revert AssetAlreadySupported();
        }

        if (collateralRatioBps == 0 || collateralRatioBps > 20_000) {
            revert InvalidCollateralRatio();
        }

        assetConfigs[asset] = AssetConfig({supported: true, collateralRatioBps: collateralRatioBps, oracle: oracle});

        emit AssetAdded(asset, collateralRatioBps, oracle);
    }

    function removeAsset(address asset) external onlyRole(ASSET_ADMIN_ROLE) {
        if (!assetConfigs[asset].supported) {
            revert AssetNotSupported();
        }

        delete assetConfigs[asset];

        emit AssetRemoved(asset);
    }

    function updateCollateralRatio(address asset, uint256 newCollateralRatioBps) external onlyRole(ASSET_ADMIN_ROLE) {
        if (!assetConfigs[asset].supported) {
            revert AssetNotSupported();
        }

        if (newCollateralRatioBps == 0 || newCollateralRatioBps > 20_000) {
            revert InvalidCollateralRatio();
        }

        uint256 oldRatio = assetConfigs[asset].collateralRatioBps;
        assetConfigs[asset].collateralRatioBps = newCollateralRatioBps;

        emit CollateralRatioUpdated(asset, oldRatio, newCollateralRatioBps);
    }

    function updateOracle(address asset, address newOracle) external onlyRole(ASSET_ADMIN_ROLE) {
        if (newOracle == address(0)) {
            revert ZeroAddress();
        }

        if (!assetConfigs[asset].supported) {
            revert AssetNotSupported();
        }

        address oldOracle = assetConfigs[asset].oracle;
        assetConfigs[asset].oracle = newOracle;

        emit OracleUpdated(asset, oldOracle, newOracle);
    }

    function isAssetSupported(address asset) external view returns (bool) {
        return assetConfigs[asset].supported;
    }

    function getAssetConfig(address asset)
        external
        view
        returns (bool supported, uint256 collateralRatioBps, address oracle)
    {
        AssetConfig memory config = assetConfigs[asset];

        return (config.supported, config.collateralRatioBps, config.oracle);
    }

    function version() external pure virtual returns (string memory) {
        return "V1";
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {
        if (newImplementation == address(0)) {
            revert ZeroAddress();
        }
    }

    uint256[50] private __gap;
}
