// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {RWALPToken} from "./RWALPToken.sol";

contract RWAAMM is ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable token0;
    IERC20 public immutable token1;
    RWALPToken public immutable lpToken;

    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public constant FEE_NUMERATOR = 997;
    uint256 public constant FEE_DENOMINATOR = 1000;

    event LiquidityAdded(address indexed provider, uint256 amount0, uint256 amount1, uint256 liquidity);

    event LiquidityRemoved(address indexed provider, uint256 amount0, uint256 amount1, uint256 liquidity);

    event Swapped(
        address indexed trader, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut
    );

    constructor(address token0_, address token1_) {
        require(token0_ != address(0), "Invalid token0");
        require(token1_ != address(0), "Invalid token1");
        require(token0_ != token1_, "Same token");

        token0 = IERC20(token0_);
        token1 = IERC20(token1_);
        lpToken = new RWALPToken(address(this));
    }

    function addLiquidity(uint256 amount0, uint256 amount1, uint256 minLiquidity)
        external
        nonReentrant
        returns (uint256 liquidity)
    {
        require(amount0 > 0 && amount1 > 0, "Invalid amounts");

        uint256 totalSupply = lpToken.totalSupply();

        if (totalSupply == 0) {
            liquidity = _sqrt(amount0 * amount1);
        } else {
            uint256 liquidity0 = (amount0 * totalSupply) / reserve0;
            uint256 liquidity1 = (amount1 * totalSupply) / reserve1;
            liquidity = _min(liquidity0, liquidity1);
        }

        require(liquidity >= minLiquidity, "Insufficient liquidity minted");
        require(liquidity > 0, "Zero liquidity");

        token0.safeTransferFrom(msg.sender, address(this), amount0);
        token1.safeTransferFrom(msg.sender, address(this), amount1);

        lpToken.mint(msg.sender, liquidity);

        _updateReserves();

        emit LiquidityAdded(msg.sender, amount0, amount1, liquidity);
    }

    function removeLiquidity(uint256 liquidity, uint256 minAmount0, uint256 minAmount1)
        external
        nonReentrant
        returns (uint256 amount0, uint256 amount1)
    {
        require(liquidity > 0, "Zero liquidity");

        uint256 totalSupply = lpToken.totalSupply();

        amount0 = (liquidity * reserve0) / totalSupply;
        amount1 = (liquidity * reserve1) / totalSupply;

        require(amount0 >= minAmount0, "Insufficient token0 amount");
        require(amount1 >= minAmount1, "Insufficient token1 amount");

        lpToken.burn(msg.sender, liquidity);

        token0.safeTransfer(msg.sender, amount0);
        token1.safeTransfer(msg.sender, amount1);

        _updateReserves();

        emit LiquidityRemoved(msg.sender, amount0, amount1, liquidity);
    }

    function swap(address tokenIn, uint256 amountIn, uint256 minAmountOut)
        external
        nonReentrant
        returns (uint256 amountOut)
    {
        require(amountIn > 0, "Amount is zero");
        require(tokenIn == address(token0) || tokenIn == address(token1), "Invalid token");

        bool isToken0In = tokenIn == address(token0);

        IERC20 inputToken = isToken0In ? token0 : token1;
        IERC20 outputToken = isToken0In ? token1 : token0;

        uint256 reserveIn = isToken0In ? reserve0 : reserve1;
        uint256 reserveOut = isToken0In ? reserve1 : reserve0;

        amountOut = getAmountOut(amountIn, reserveIn, reserveOut);

        require(amountOut >= minAmountOut, "Slippage too high");
        require(amountOut < reserveOut, "Insufficient liquidity");

        inputToken.safeTransferFrom(msg.sender, address(this), amountIn);
        outputToken.safeTransfer(msg.sender, amountOut);

        _updateReserves();

        emit Swapped(msg.sender, address(inputToken), address(outputToken), amountIn, amountOut);
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256) {
        require(amountIn > 0, "Amount is zero");
        require(reserveIn > 0 && reserveOut > 0, "Invalid reserves");

        uint256 amountInWithFee = amountIn * FEE_NUMERATOR;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * FEE_DENOMINATOR) + amountInWithFee;

        return numerator / denominator;
    }

    function getReserves() external view returns (uint256, uint256) {
        return (reserve0, reserve1);
    }

    function _updateReserves() internal {
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));
    }

    function _sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = (y / 2) + 1;

            while (x < z) {
                z = x;
                x = ((y / x) + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
