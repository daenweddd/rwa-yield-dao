// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {RWAAMM} from "../../src/amm/RWAAMM.sol";

contract AMMInvariantERC20 is ERC20 {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract AMMHandler {
    AMMInvariantERC20 public token0;
    AMMInvariantERC20 public token1;
    RWAAMM public amm;

    address public user = address(0xB0B);

    constructor(AMMInvariantERC20 _token0, AMMInvariantERC20 _token1, RWAAMM _amm) {
        token0 = _token0;
        token1 = _token1;
        amm = _amm;

        token0.mint(user, 1_000_000 ether);
        token1.mint(user, 1_000_000 ether);
    }

    function swapToken0ForToken1(uint256 amountIn) external {
        amountIn = bound(amountIn, 1 ether, 10 ether);

        token0.mint(address(this), amountIn);
        token0.approve(address(amm), amountIn);

        try amm.swap(address(token0), amountIn, 0) {} catch {}
    }

    function swapToken1ForToken0(uint256 amountIn) external {
        amountIn = bound(amountIn, 1 ether, 10 ether);

        token1.mint(address(this), amountIn);
        token1.approve(address(amm), amountIn);

        try amm.swap(address(token1), amountIn, 0) {} catch {}
    }

    function bound(uint256 x, uint256 min, uint256 max) internal pure returns (uint256) {
        if (x < min) return min;
        if (x > max) return max;
        return x;
    }
}

contract AMMInvariantTest is Test {
    AMMInvariantERC20 token0;
    AMMInvariantERC20 token1;
    RWAAMM amm;
    AMMHandler handler;

    uint256 initialK;

    address liquidityProvider = address(0xA11CE);

    function setUp() public {
        token0 = new AMMInvariantERC20("RWA Token", "RWA");
        token1 = new AMMInvariantERC20("Mock USDC", "mUSDC");

        amm = new RWAAMM(address(token0), address(token1));

        token0.mint(liquidityProvider, 10_000 ether);
        token1.mint(liquidityProvider, 10_000 ether);

        vm.startPrank(liquidityProvider);
        token0.approve(address(amm), type(uint256).max);
        token1.approve(address(amm), type(uint256).max);
        amm.addLiquidity(1_000 ether, 1_000 ether, 1);
        vm.stopPrank();

        initialK = amm.reserve0() * amm.reserve1();

        handler = new AMMHandler(token0, token1, amm);
        targetContract(address(handler));
    }

    function invariant_KNeverDecreases() public view {
        uint256 currentK = amm.reserve0() * amm.reserve1();
        assertGe(currentK, initialK);
    }

    function invariant_ReservesEqualBalances() public view {
        assertEq(amm.reserve0(), token0.balanceOf(address(amm)));
        assertEq(amm.reserve1(), token1.balanceOf(address(amm)));
    }
}