// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract IssuerRegistry is AccessControl {
    bytes32 public constant ISSUER_ADMIN_ROLE = keccak256("ISSUER_ADMIN_ROLE");
    bytes32 public constant AUTHORIZED_ISSUER_ROLE = keccak256("AUTHORIZED_ISSUER_ROLE");

    event IssuerAdded(address indexed issuer);
    event IssuerRemoved(address indexed issuer);

    constructor(address admin) {
        require(admin != address(0), "Invalid admin");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ISSUER_ADMIN_ROLE, admin);
    }

    function addIssuer(address issuer) external onlyRole(ISSUER_ADMIN_ROLE) {
        require(issuer != address(0), "Invalid issuer");
        _grantRole(AUTHORIZED_ISSUER_ROLE, issuer);

        emit IssuerAdded(issuer);
    }

    function removeIssuer(address issuer) external onlyRole(ISSUER_ADMIN_ROLE) {
        require(issuer != address(0), "Invalid issuer");
        _revokeRole(AUTHORIZED_ISSUER_ROLE, issuer);

        emit IssuerRemoved(issuer);
    }

    function isIssuer(address account) external view returns (bool) {
        return hasRole(AUTHORIZED_ISSUER_ROLE, account);
    }
}
