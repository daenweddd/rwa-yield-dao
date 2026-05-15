// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract UpgradeableAssetManager is Initializable, UUPSUpgradeable, AccessControlUpgradeable {
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant ASSET_ADMIN_ROLE = keccak256("ASSET_ADMIN_ROLE");

    struct AssetConfig {
        bool supported;
        uint256 collateralRatioBps;
        address oracle;
    }

    mapping(address => AssetConfig) internal _assetConfigs;

    event AssetConfigured(address indexed asset, bool supported, uint256 collateralRatioBps, address indexed oracle);

    function initialize(address admin) public initializer {
        require(admin != address(0), "Invalid admin");

        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        _grantRole(ASSET_ADMIN_ROLE, admin);
    }

    function setAssetConfig(address asset, bool supported, uint256 collateralRatioBps, address oracle)
        external
        onlyRole(ASSET_ADMIN_ROLE)
    {
        require(asset != address(0), "Invalid asset");
        require(oracle != address(0), "Invalid oracle");
        require(collateralRatioBps > 0, "Invalid ratio");

        _assetConfigs[asset] =
            AssetConfig({supported: supported, collateralRatioBps: collateralRatioBps, oracle: oracle});

        emit AssetConfigured(asset, supported, collateralRatioBps, oracle);
    }

    function getAssetConfig(address asset)
        external
        view
        returns (bool supported, uint256 collateralRatioBps, address oracle)
    {
        AssetConfig memory config = _assetConfigs[asset];

        return (config.supported, config.collateralRatioBps, config.oracle);
    }

    function version() external pure virtual returns (string memory) {
        return "V1";
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

    uint256[49] private __gap;
}
