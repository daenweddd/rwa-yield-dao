// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RWALPToken is ERC20 {
    address public immutable amm;

    modifier onlyAMM() {
        require(msg.sender == amm, "Only AMM");
        _;
    }

    constructor(address amm_) ERC20("RealYield AMM LP Token", "ryLP") {
        require(amm_ != address(0), "Invalid AMM");
        amm = amm_;
    }

    function mint(address to, uint256 amount) external onlyAMM {
        require(to != address(0), "Invalid receiver");
        require(amount > 0, "Amount is zero");

        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyAMM {
        require(from != address(0), "Invalid account");
        require(amount > 0, "Amount is zero");

        _burn(from, amount);
    }
}
