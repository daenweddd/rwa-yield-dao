// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {RWAFactory} from "../../src/factory/RWAFactory.sol";

contract FactoryMockERC20 is ERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}
}

contract RWAFactoryTest is Test {
    RWAFactory factory;
    FactoryMockERC20 token0;
    FactoryMockERC20 token1;

    function setUp() public {
        factory = new RWAFactory();
        token0 = new FactoryMockERC20("RWA", "RWA");
        token1 = new FactoryMockERC20("USDC", "USDC");
    }

    function testCreateAMMWorks() public {
        address amm = factory.createAMM(address(token0), address(token1));

        assertTrue(amm != address(0));
        assertEq(factory.allAMMsLength(), 1);
    }

    function testCreateAMMRevertsForZeroAddress() public {
        vm.expectRevert(RWAFactory.ZeroAddress.selector);
        factory.createAMM(address(0), address(token1));
    }

    function testPredictCreate2AddressWorks() public {
        bytes32 salt = keccak256("SALT");

        address predicted = factory.predictAMM2Address(
            address(token0),
            address(token1),
            salt
        );

        address actual = factory.createAMM2(
            address(token0),
            address(token1),
            salt
        );

        assertEq(predicted, actual);
        assertEq(factory.allAMMsLength(), 1);
    }

    function testCreateAMM2RevertsForZeroAddress() public {
        bytes32 salt = keccak256("SALT");

        vm.expectRevert(RWAFactory.ZeroAddress.selector);
        factory.createAMM2(address(0), address(token1), salt);
    }
}