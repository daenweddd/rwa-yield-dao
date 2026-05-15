// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {RWAAMM} from "../../src/amm/RWAAMM.sol";

contract AMMFuzzERC20 is ERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract AMMFuzzTest is Test {
    AMMFuzzERC20 token0;
    AMMFuzzERC20 token1;
    RWAAMM amm;

    address liquidityProvider = address(0xA11CE);
    address trader = address(0xB0B);

    function setUp() public {
        token0 = new AMMFuzzERC20("RWA Token", "RWA");
        token1 = new AMMFuzzERC20("Mock USDC", "mUSDC");

        amm = new RWAAMM(address(token0), address(token1));

        token0.mint(liquidityProvider, 10_000 ether);
        token1.mint(liquidityProvider, 10_000 ether);

        token0.mint(trader, 10_000 ether);
        token1.mint(trader, 10_000 ether);

        vm.startPrank(liquidityProvider);
        token0.approve(address(amm), type(uint256).max);
        token1.approve(address(amm), type(uint256).max);
        amm.addLiquidity(1_000 ether, 1_000 ether, 1);
        vm.stopPrank();

        vm.startPrank(trader);
        token0.approve(address(amm), type(uint256).max);
        token1.approve(address(amm), type(uint256).max);
        vm.stopPrank();
    }

    function testFuzzSwapToken0ForToken1(uint256 amountIn) public {
        amountIn = bound(amountIn, 1 ether, 100 ether);

        uint256 traderToken1Before = token1.balanceOf(trader);

        uint256 expectedAmountOut = amm.getAmountOut(
            amountIn,
            amm.reserve0(),
            amm.reserve1()
        );

        vm.prank(trader);
        uint256 actualAmountOut = amm.swap(address(token0), amountIn, 0);

        assertEq(actualAmountOut, expectedAmountOut);
        assertEq(token1.balanceOf(trader), traderToken1Before + actualAmountOut);
        assertGt(amm.reserve0(), 1_000 ether);
        assertLt(amm.reserve1(), 1_000 ether);
    }

    function testFuzzSwapToken1ForToken0(uint256 amountIn) public {
        amountIn = bound(amountIn, 1 ether, 100 ether);

        uint256 traderToken0Before = token0.balanceOf(trader);

        uint256 expectedAmountOut = amm.getAmountOut(
            amountIn,
            amm.reserve1(),
            amm.reserve0()
        );

        vm.prank(trader);
        uint256 actualAmountOut = amm.swap(address(token1), amountIn, 0);

        assertEq(actualAmountOut, expectedAmountOut);
        assertEq(token0.balanceOf(trader), traderToken0Before + actualAmountOut);
        assertGt(amm.reserve1(), 1_000 ether);
        assertLt(amm.reserve0(), 1_000 ether);
    }

    function testFuzzAddLiquidity(uint256 amount0, uint256 amount1) public {
        amount0 = bound(amount0, 1 ether, 500 ether);
        amount1 = bound(amount1, 1 ether, 500 ether);

        uint256 lpBalanceBefore = amm.lpToken().balanceOf(liquidityProvider);

        vm.prank(liquidityProvider);
        uint256 liquidity = amm.addLiquidity(amount0, amount1, 1);

        assertGt(liquidity, 0);
        assertEq(
            amm.lpToken().balanceOf(liquidityProvider),
            lpBalanceBefore + liquidity
        );
    }

    function testFuzzSlippageProtection(uint256 amountIn, uint256 minAmountOut) public {
        amountIn = bound(amountIn, 1 ether, 100 ether);
        minAmountOut = bound(minAmountOut, 1_001 ether, 10_000 ether);

        vm.prank(trader);
        vm.expectRevert(RWAAMM.SlippageExceeded.selector);
        amm.swap(address(token0), amountIn, minAmountOut);
    }
}