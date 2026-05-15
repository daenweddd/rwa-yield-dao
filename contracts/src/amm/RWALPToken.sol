// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract RWALPToken is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    error ZeroAddress();

    constructor(address amm) ERC20("RealYield AMM LP Token", "RYLP") {
        if (amm == address(0)) {
            revert ZeroAddress();
        }

        _grantRole(DEFAULT_ADMIN_ROLE, amm);
        _grantRole(MINTER_ROLE, amm);
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        if (to == address(0)) {
            revert ZeroAddress();
        }

        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyRole(MINTER_ROLE) {
        if (from == address(0)) {
            revert ZeroAddress();
        }

        _burn(from, amount);
    }
}
