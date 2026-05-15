// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {RWAAssetToken} from "../token/RWAAssetToken.sol";
import {IssuerRegistry} from "./IssuerRegistry.sol";
import {RWAOracleAdapter} from "../oracle/RWAOracleAdapter.sol";

contract MintingManager is AccessControl, Pausable, ReentrancyGuard {
    bytes32 public constant MANAGER_ADMIN_ROLE = keccak256("MANAGER_ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    RWAAssetToken public immutable rwaToken;
    IssuerRegistry public issuerRegistry;
    RWAOracleAdapter public oracleAdapter;

    event AssetMinted(address indexed issuer, address indexed to, uint256 amount, int256 oraclePrice);

    event AssetBurned(address indexed issuer, address indexed from, uint256 amount, int256 oraclePrice);

    event IssuerRegistryUpdated(address indexed newRegistry);
    event OracleAdapterUpdated(address indexed newOracle);

    constructor(address token_, address registry_, address oracle_, address admin) {
        require(token_ != address(0), "Invalid token");
        require(registry_ != address(0), "Invalid registry");
        require(oracle_ != address(0), "Invalid oracle");
        require(admin != address(0), "Invalid admin");

        rwaToken = RWAAssetToken(token_);
        issuerRegistry = IssuerRegistry(registry_);
        oracleAdapter = RWAOracleAdapter(oracle_);

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MANAGER_ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
    }

    function mintBackedTokens(address to, uint256 amount) external nonReentrant whenNotPaused {
        require(issuerRegistry.isIssuer(msg.sender), "Not authorized issuer");
        require(to != address(0), "Invalid receiver");
        require(amount > 0, "Amount is zero");

        (int256 price,) = oracleAdapter.getLatestPrice();

        rwaToken.mint(to, amount);

        emit AssetMinted(msg.sender, to, amount, price);
    }

    function burnBackedTokens(address from, uint256 amount) external nonReentrant whenNotPaused {
        require(issuerRegistry.isIssuer(msg.sender), "Not authorized issuer");
        require(from != address(0), "Invalid account");
        require(amount > 0, "Amount is zero");

        (int256 price,) = oracleAdapter.getLatestPrice();

        rwaToken.burn(from, amount);

        emit AssetBurned(msg.sender, from, amount, price);
    }

    function setIssuerRegistry(address newRegistry) external onlyRole(MANAGER_ADMIN_ROLE) {
        require(newRegistry != address(0), "Invalid registry");

        issuerRegistry = IssuerRegistry(newRegistry);

        emit IssuerRegistryUpdated(newRegistry);
    }

    function setOracleAdapter(address newOracle) external onlyRole(MANAGER_ADMIN_ROLE) {
        require(newOracle != address(0), "Invalid oracle");

        oracleAdapter = RWAOracleAdapter(newOracle);

        emit OracleAdapterUpdated(newOracle);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }
}
