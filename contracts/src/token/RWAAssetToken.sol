// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract RWAAssetToken is ERC20, ERC20Permit, ERC20Pausable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    string public assetName;
    string public assetProofURI;

    event AssetProofURIUpdated(string oldURI, string newURI);

    error ZeroAddress();
    error EmptyString();

    constructor(
        address admin,
        string memory _assetName,
        string memory _assetProofURI
    )
        ERC20("RealYield RWA Asset Token", "RYRWA")
        ERC20Permit("RealYield RWA Asset Token")
    {
        if (admin == address(0)) {
            revert ZeroAddress();
        }

        if (bytes(_assetName).length == 0) {
            revert EmptyString();
        }

        assetName = _assetName;
        assetProofURI = _assetProofURI;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
        _grantRole(BURNER_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        if (to == address(0)) {
            revert ZeroAddress();
        }

        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE) {
        if (from == address(0)) {
            revert ZeroAddress();
        }

        _burn(from, amount);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function updateAssetProofURI(
        string calldata newURI
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        string memory oldURI = assetProofURI;
        assetProofURI = newURI;

        emit AssetProofURIUpdated(oldURI, newURI);
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override(ERC20, ERC20Pausable) {
        super._update(from, to, value);
    }
}