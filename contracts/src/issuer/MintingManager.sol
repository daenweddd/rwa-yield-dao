// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IssuerRegistry} from "./IssuerRegistry.sol";
import {RWAOracleAdapter} from "../oracle/RWAOracleAdapter.sol";

interface IRWAAssetToken {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}

contract MintingManager is AccessControl, Pausable, ReentrancyGuard {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    IRWAAssetToken public immutable assetToken;
    IssuerRegistry public immutable issuerRegistry;
    RWAOracleAdapter public immutable oracleAdapter;

    event AssetMinted(
        address indexed issuer,
        address indexed to,
        uint256 amount,
        int256 oraclePrice
    );

    event AssetBurned(
        address indexed issuer,
        address indexed from,
        uint256 amount,
        int256 oraclePrice
    );

    error ZeroAddress();
    error ZeroAmount();
    error NotAuthorizedIssuer();

    constructor(
        address admin,
        address _assetToken,
        address _issuerRegistry,
        address _oracleAdapter
    ) {
        if (
            admin == address(0) ||
            _assetToken == address(0) ||
            _issuerRegistry == address(0) ||
            _oracleAdapter == address(0)
        ) {
            revert ZeroAddress();
        }

        assetToken = IRWAAssetToken(_assetToken);
        issuerRegistry = IssuerRegistry(_issuerRegistry);
        oracleAdapter = RWAOracleAdapter(_oracleAdapter);

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
    }

    function mint(address to, uint256 amount) external nonReentrant whenNotPaused {
        if (to == address(0)) {
            revert ZeroAddress();
        }

        if (amount == 0) {
            revert ZeroAmount();
        }

        if (!issuerRegistry.isIssuer(msg.sender)) {
            revert NotAuthorizedIssuer();
        }

        int256 price = oracleAdapter.getLatestPrice();

        assetToken.mint(to, amount);

        emit AssetMinted(msg.sender, to, amount, price);
    }

    function burn(address from, uint256 amount) external nonReentrant whenNotPaused {
        if (from == address(0)) {
            revert ZeroAddress();
        }

        if (amount == 0) {
            revert ZeroAmount();
        }

        if (!issuerRegistry.isIssuer(msg.sender)) {
            revert NotAuthorizedIssuer();
        }

        int256 price = oracleAdapter.getLatestPrice();

        assetToken.burn(from, amount);

        emit AssetBurned(msg.sender, from, amount, price);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }
}