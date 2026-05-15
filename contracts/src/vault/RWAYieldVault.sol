// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract RWAYieldVault is ERC4626, AccessControl, Pausable, ReentrancyGuard {
    bytes32 public constant VAULT_ADMIN_ROLE = keccak256("VAULT_ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    address public treasury;
    uint256 public managementFeeBps;

    uint256 public constant MAX_BPS = 10_000;
    uint256 public constant MAX_MANAGEMENT_FEE_BPS = 500;

    event TreasuryUpdated(address indexed newTreasury);
    event ManagementFeeUpdated(uint256 newFeeBps);

    constructor(IERC20 asset_, address admin, address treasury_)
        ERC20("RealYield Vault Share", "rvRWA")
        ERC4626(asset_)
    {
        require(admin != address(0), "Invalid admin");
        require(treasury_ != address(0), "Invalid treasury");

        treasury = treasury_;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(VAULT_ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
    }

    function setTreasury(address newTreasury) external onlyRole(VAULT_ADMIN_ROLE) {
        require(newTreasury != address(0), "Invalid treasury");

        treasury = newTreasury;

        emit TreasuryUpdated(newTreasury);
    }

    function setManagementFeeBps(uint256 newFeeBps) external onlyRole(VAULT_ADMIN_ROLE) {
        require(newFeeBps <= MAX_MANAGEMENT_FEE_BPS, "Fee too high");

        managementFeeBps = newFeeBps;

        emit ManagementFeeUpdated(newFeeBps);
    }

    function deposit(uint256 assets, address receiver)
        public
        override
        nonReentrant
        whenNotPaused
        returns (uint256 shares)
    {
        return super.deposit(assets, receiver);
    }

    function mint(uint256 shares, address receiver)
        public
        override
        nonReentrant
        whenNotPaused
        returns (uint256 assets)
    {
        return super.mint(shares, receiver);
    }

    function withdraw(uint256 assets, address receiver, address owner)
        public
        override
        nonReentrant
        whenNotPaused
        returns (uint256 shares)
    {
        return super.withdraw(assets, receiver, owner);
    }

    function redeem(uint256 shares, address receiver, address owner)
        public
        override
        nonReentrant
        whenNotPaused
        returns (uint256 assets)
    {
        return super.redeem(shares, receiver, owner);
    }

    function maxDeposit(address receiver) public view override returns (uint256) {
        if (paused()) {
            return 0;
        }

        return super.maxDeposit(receiver);
    }

    function maxMint(address receiver) public view override returns (uint256) {
        if (paused()) {
            return 0;
        }

        return super.maxMint(receiver);
    }

    function maxWithdraw(address owner) public view override returns (uint256) {
        if (paused()) {
            return 0;
        }

        return super.maxWithdraw(owner);
    }

    function maxRedeem(address owner) public view override returns (uint256) {
        if (paused()) {
            return 0;
        }

        return super.maxRedeem(owner);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }
}
