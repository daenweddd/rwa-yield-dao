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

    event Swap(
        address indexed user, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut
    );

    error ZeroAddress();
    error ZeroAmount();
    error InvalidToken();
    error InsufficientLiquidity();
    error SlippageExceeded();

    constructor(address _token0, address _token1) {
        if (_token0 == address(0) || _token1 == address(0)) {
            revert ZeroAddress();
        }

        if (_token0 == _token1) {
            revert InvalidToken();
        }

        token0 = IERC20(_token0);
        token1 = IERC20(_token1);

        lpToken = new RWALPToken(address(this));
    }

    function addLiquidity(uint256 amount0, uint256 amount1, uint256 minLiquidity)
        external
        nonReentrant
        returns (uint256 liquidity)
    {
        if (amount0 == 0 || amount1 == 0) {
            revert ZeroAmount();
        }

        uint256 totalSupply = lpToken.totalSupply();

        if (totalSupply == 0) {
            liquidity = _sqrt(amount0 * amount1);
        } else {
            uint256 liquidity0 = (amount0 * totalSupply) / reserve0;
            uint256 liquidity1 = (amount1 * totalSupply) / reserve1;
            liquidity = _min(liquidity0, liquidity1);
        }

        if (liquidity == 0) {
            revert InsufficientLiquidity();
        }

        if (liquidity < minLiquidity) {
            revert SlippageExceeded();
        }

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
        if (liquidity == 0) {
            revert ZeroAmount();
        }

        uint256 totalSupply = lpToken.totalSupply();

        amount0 = (liquidity * reserve0) / totalSupply;
        amount1 = (liquidity * reserve1) / totalSupply;

        if (amount0 < minAmount0 || amount1 < minAmount1) {
            revert SlippageExceeded();
        }

        if (amount0 == 0 || amount1 == 0) {
            revert InsufficientLiquidity();
        }

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
        if (amountIn == 0) {
            revert ZeroAmount();
        }

        bool isToken0In = tokenIn == address(token0);
        bool isToken1In = tokenIn == address(token1);

        if (!isToken0In && !isToken1In) {
            revert InvalidToken();
        }

        IERC20 inputToken = isToken0In ? token0 : token1;
        IERC20 outputToken = isToken0In ? token1 : token0;

        uint256 reserveIn = isToken0In ? reserve0 : reserve1;
        uint256 reserveOut = isToken0In ? reserve1 : reserve0;

        if (reserveIn == 0 || reserveOut == 0) {
            revert InsufficientLiquidity();
        }

        amountOut = getAmountOut(amountIn, reserveIn, reserveOut);

        if (amountOut < minAmountOut) {
            revert SlippageExceeded();
        }

        inputToken.safeTransferFrom(msg.sender, address(this), amountIn);
        outputToken.safeTransfer(msg.sender, amountOut);

        _updateReserves();

        emit Swap(msg.sender, address(inputToken), address(outputToken), amountIn, amountOut);
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        public
        pure
        returns (uint256 amountOut)
    {
        if (amountIn == 0) {
            revert ZeroAmount();
        }

        if (reserveIn == 0 || reserveOut == 0) {
            revert InsufficientLiquidity();
        }

        uint256 amountInWithFee = amountIn * FEE_NUMERATOR;
        amountOut = (amountInWithFee * reserveOut) / ((reserveIn * FEE_DENOMINATOR) + amountInWithFee);
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
