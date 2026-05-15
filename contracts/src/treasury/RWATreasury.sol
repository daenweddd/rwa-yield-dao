// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract RWATreasury is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant TREASURER_ROLE = keccak256("TREASURER_ROLE");

    event ETHReceived(address indexed sender, uint256 amount);
    event ETHWithdrawn(address indexed to, uint256 amount);
    event ERC20Withdrawn(address indexed token, address indexed to, uint256 amount);

    constructor(address admin) {
        require(admin != address(0), "Invalid admin");

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(TREASURER_ROLE, admin);
    }

    receive() external payable {
        emit ETHReceived(msg.sender, msg.value);
    }

    function withdrawETH(address payable to, uint256 amount) external nonReentrant onlyRole(TREASURER_ROLE) {
        require(to != address(0), "Invalid receiver");
        require(amount <= address(this).balance, "Insufficient ETH");

        (bool success,) = to.call{value: amount}("");
        require(success, "ETH transfer failed");

        emit ETHWithdrawn(to, amount);
    }

    function withdrawERC20(address token, address to, uint256 amount) external nonReentrant onlyRole(TREASURER_ROLE) {
        require(token != address(0), "Invalid token");
        require(to != address(0), "Invalid receiver");

        IERC20(token).safeTransfer(to, amount);

        emit ERC20Withdrawn(token, to, amount);
    }
}
