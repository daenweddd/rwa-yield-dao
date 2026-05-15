// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract RWATreasury is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant TREASURY_MANAGER_ROLE = keccak256("TREASURY_MANAGER_ROLE");

    event EtherReceived(address indexed sender, uint256 amount);
    event EtherWithdrawn(address indexed to, uint256 amount);
    event ERC20Withdrawn(address indexed token, address indexed to, uint256 amount);

    error ZeroAddress();
    error ZeroAmount();
    error EtherTransferFailed();

    constructor(address admin) {
        if (admin == address(0)) {
            revert ZeroAddress();
        }

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(TREASURY_MANAGER_ROLE, admin);
    }

    receive() external payable {
        emit EtherReceived(msg.sender, msg.value);
    }

    function withdrawEther(address payable to, uint256 amount) external nonReentrant onlyRole(TREASURY_MANAGER_ROLE) {
        if (to == address(0)) {
            revert ZeroAddress();
        }

        if (amount == 0) {
            revert ZeroAmount();
        }

        (bool success,) = to.call{value: amount}("");

        if (!success) {
            revert EtherTransferFailed();
        }

        emit EtherWithdrawn(to, amount);
    }

    function withdrawERC20(address token, address to, uint256 amount)
        external
        nonReentrant
        onlyRole(TREASURY_MANAGER_ROLE)
    {
        if (token == address(0) || to == address(0)) {
            revert ZeroAddress();
        }

        if (amount == 0) {
            revert ZeroAmount();
        }

        IERC20(token).safeTransfer(to, amount);

        emit ERC20Withdrawn(token, to, amount);
    }

    function etherBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function erc20Balance(address token) external view returns (uint256) {
        if (token == address(0)) {
            revert ZeroAddress();
        }

        return IERC20(token).balanceOf(address(this));
    }
}
