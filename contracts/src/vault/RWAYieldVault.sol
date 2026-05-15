// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract RWAYieldVault is ERC4626, AccessControl, Pausable, ReentrancyGuard {
    bytes32 public constant VAULT_ADMIN_ROLE = keccak256("VAULT_ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    address public treasury;
    uint256 public performanceFeeBps;

    uint256 public constant MAX_FEE_BPS = 2_000;
    uint256 public constant BPS_DENOMINATOR = 10_000;

    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);

    event PerformanceFeeUpdated(uint256 oldFeeBps, uint256 newFeeBps);

    error ZeroAddress();
    error FeeTooHigh();

    constructor(IERC20 asset_, address admin, address treasury_)
        ERC20("RealYield RWA Vault Share", "ryRWA")
        ERC4626(asset_)
    {
        if (address(asset_) == address(0) || admin == address(0) || treasury_ == address(0)) {
            revert ZeroAddress();
        }

        treasury = treasury_;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(VAULT_ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
    }

    function deposit(uint256 assets, address receiver)
        public
        override
        nonReentrant
        whenNotPaused
        returns (uint256 shares)
    {
        shares = super.deposit(assets, receiver);
    }

    function mint(uint256 shares, address receiver)
        public
        override
        nonReentrant
        whenNotPaused
        returns (uint256 assets)
    {
        assets = super.mint(shares, receiver);
    }

    function withdraw(uint256 assets, address receiver, address owner)
        public
        override
        nonReentrant
        whenNotPaused
        returns (uint256 shares)
    {
        shares = super.withdraw(assets, receiver, owner);
    }

    function redeem(uint256 shares, address receiver, address owner)
        public
        override
        nonReentrant
        whenNotPaused
        returns (uint256 assets)
    {
        assets = super.redeem(shares, receiver, owner);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function updateTreasury(address newTreasury) external onlyRole(VAULT_ADMIN_ROLE) {
        if (newTreasury == address(0)) {
            revert ZeroAddress();
        }

        address oldTreasury = treasury;
        treasury = newTreasury;

        emit TreasuryUpdated(oldTreasury, newTreasury);
    }

    function updatePerformanceFeeBps(uint256 newFeeBps) external onlyRole(VAULT_ADMIN_ROLE) {
        if (newFeeBps > MAX_FEE_BPS) {
            revert FeeTooHigh();
        }

        uint256 oldFee = performanceFeeBps;
        performanceFeeBps = newFeeBps;

        emit PerformanceFeeUpdated(oldFee, newFeeBps);
    }

    function previewPerformanceFee(uint256 yieldAmount) external view returns (uint256) {
        return (yieldAmount * performanceFeeBps) / BPS_DENOMINATOR;
    }
}
