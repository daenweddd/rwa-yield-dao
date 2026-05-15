// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {RWAAMM} from "../../src/amm/RWAAMM.sol";
import {RWALPToken} from "../../src/amm/RWALPToken.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract RWAAMMTest is Test {
    MockERC20 token0;
    MockERC20 token1;
    RWAAMM amm;
    RWALPToken lpToken;

    address user = address(0xB0B);
    address trader = address(0xCAFE);

    function setUp() public {
        token0 = new MockERC20("RWA", "RWA");
        token1 = new MockERC20("Mock USDC", "mUSDC");

        amm = new RWAAMM(address(token0), address(token1));
        lpToken = amm.lpToken();

        token0.mint(user, 10_000 ether);
        token1.mint(user, 10_000 ether);

        token0.mint(trader, 10_000 ether);
        token1.mint(trader, 10_000 ether);

        vm.startPrank(user);
        token0.approve(address(amm), type(uint256).max);
        token1.approve(address(amm), type(uint256).max);
        vm.stopPrank();

        vm.startPrank(trader);
        token0.approve(address(amm), type(uint256).max);
        token1.approve(address(amm), type(uint256).max);
        vm.stopPrank();
    }

    function testConstructorSetsTokens() public view {
        assertEq(address(amm.token0()), address(token0));
        assertEq(address(amm.token1()), address(token1));
    }

    function testConstructorRevertsForZeroAddress() public {
        vm.expectRevert(RWAAMM.ZeroAddress.selector);
        new RWAAMM(address(0), address(token1));
    }

    function testConstructorRevertsForSameToken() public {
        vm.expectRevert(RWAAMM.InvalidToken.selector);
        new RWAAMM(address(token0), address(token0));
    }

    function testAddLiquidityWorks() public {
        vm.prank(user);
        uint256 liquidity = amm.addLiquidity(100 ether, 100 ether, 1);

        assertGt(liquidity, 0);
        assertEq(lpToken.balanceOf(user), liquidity);
        assertEq(amm.reserve0(), 100 ether);
        assertEq(amm.reserve1(), 100 ether);
    }

    function testAddLiquidityRevertsForZeroAmount() public {
        vm.prank(user);
        vm.expectRevert(RWAAMM.ZeroAmount.selector);
        amm.addLiquidity(0, 100 ether, 1);
    }

    function testRemoveLiquidityWorks() public {
        vm.prank(user);
        uint256 liquidity = amm.addLiquidity(100 ether, 100 ether, 1);

        vm.prank(user);
        amm.removeLiquidity(liquidity / 2, 1, 1);

        assertLt(lpToken.balanceOf(user), liquidity);
        assertEq(amm.reserve0(), 50 ether);
        assertEq(amm.reserve1(), 50 ether);
    }

    function testSwapWorks() public {
        vm.prank(user);
        amm.addLiquidity(1_000 ether, 1_000 ether, 1);

        vm.prank(trader);
        uint256 amountOut = amm.swap(address(token0), 100 ether, 1);

        assertGt(amountOut, 0);
        assertGt(token1.balanceOf(trader), 10_000 ether);
    }

    function testSwapRevertsForInvalidToken() public {
        vm.prank(user);
        amm.addLiquidity(1_000 ether, 1_000 ether, 1);

        vm.prank(trader);
        vm.expectRevert(RWAAMM.InvalidToken.selector);
        amm.swap(address(0xBAD), 100 ether, 1);
    }

    function testSwapRevertsForSlippage() public {
        vm.prank(user);
        amm.addLiquidity(1_000 ether, 1_000 ether, 1);

        vm.prank(trader);
        vm.expectRevert(RWAAMM.SlippageExceeded.selector);
        amm.swap(address(token0), 100 ether, 1_000 ether);
    }

    function testGetAmountOutWorks() public view {
        uint256 amountOut = amm.getAmountOut(100 ether, 1_000 ether, 1_000 ether);
        assertGt(amountOut, 0);
    }
}