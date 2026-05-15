// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {RWAAMM} from "../amm/RWAAMM.sol";

contract RWAFactory {
    event AMMCreated(
        address indexed amm,
        address indexed token0,
        address indexed token1,
        address creator
    );

    event AMMCreated2(
        address indexed amm,
        address indexed token0,
        address indexed token1,
        bytes32 salt,
        address creator
    );

    error ZeroAddress();

    address[] public allAMMs;

    function createAMM(address token0, address token1) external returns (address amm) {
        if (token0 == address(0) || token1 == address(0)) {
            revert ZeroAddress();
        }

        amm = address(new RWAAMM(token0, token1));
        allAMMs.push(amm);

        emit AMMCreated(amm, token0, token1, msg.sender);
    }

    function createAMM2(
        address token0,
        address token1,
        bytes32 salt
    ) external returns (address amm) {
        if (token0 == address(0) || token1 == address(0)) {
            revert ZeroAddress();
        }

        amm = address(new RWAAMM{salt: salt}(token0, token1));
        allAMMs.push(amm);

        emit AMMCreated2(amm, token0, token1, salt, msg.sender);
    }

    function predictAMM2Address(
        address token0,
        address token1,
        bytes32 salt
    ) external view returns (address predicted) {
        bytes memory bytecode = abi.encodePacked(
            type(RWAAMM).creationCode,
            abi.encode(token0, token1)
        );

        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(bytecode)
            )
        );

        predicted = address(uint160(uint256(hash)));
    }

    function allAMMsLength() external view returns (uint256) {
        return allAMMs.length;
    }
}