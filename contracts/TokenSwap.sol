// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title TokenSwap
 * @dev Simple AMM-style token swap contract with liquidity pools
 */
contract TokenSwap is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Fee percentage (0.3% = 30 basis points)
    uint256 public constant FEE_PERCENT = 30;
    uint256 public constant FEE_DENOMINATOR = 10000;

    // Liquidity pools: token address => reserve amount
    mapping(address => uint256) public reserves;

    // Events
    event Swap(
        address indexed user,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    event LiquidityAdded(
        address indexed provider,
        address indexed token,
        uint256 amount
    );

    event LiquidityRemoved(
        address indexed provider,
        address indexed token,
        uint256 amount
    );

    constructor() Ownable(msg.sender) {}

    /**
     * @dev Add liquidity to a token pool
     * @param token The token address
     * @param amount The amount to add
     */
    function addLiquidity(address token, uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        reserves[token] += amount;

        emit LiquidityAdded(msg.sender, token, amount);
    }

    /**
     * @dev Remove liquidity from a token pool
     * @param token The token address
     * @param amount The amount to remove
     */
    function removeLiquidity(address token, uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(reserves[token] >= amount, "Insufficient liquidity");

        reserves[token] -= amount;
        IERC20(token).safeTransfer(msg.sender, amount);

        emit LiquidityRemoved(msg.sender, token, amount);
    }

    /**
     * @dev Calculate output amount for a swap using constant product formula
     * @param tokenIn Input token address
     * @param tokenOut Output token address
     * @param amountIn Input amount
     * @return amountOut Output amount after fees
     */
    function getAmountOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) public view returns (uint256 amountOut) {
        require(amountIn > 0, "Amount must be greater than 0");
        require(reserves[tokenIn] > 0 && reserves[tokenOut] > 0, "Insufficient liquidity");

        // Apply fee to input amount
        uint256 amountInWithFee = amountIn * (FEE_DENOMINATOR - FEE_PERCENT);
        
        // Constant product formula: x * y = k
        // amountOut = (reserveOut * amountInWithFee) / (reserveIn * FEE_DENOMINATOR + amountInWithFee)
        uint256 numerator = reserves[tokenOut] * amountInWithFee;
        uint256 denominator = (reserves[tokenIn] * FEE_DENOMINATOR) + amountInWithFee;
        
        amountOut = numerator / denominator;
    }

    /**
     * @dev Swap tokens
     * @param tokenIn Input token address
     * @param tokenOut Output token address
     * @param amountIn Input amount
     * @param minAmountOut Minimum output amount (slippage protection)
     */
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut
    ) external nonReentrant returns (uint256 amountOut) {
        require(amountIn > 0, "Amount must be greater than 0");
        require(tokenIn != tokenOut, "Cannot swap same token");

        // Calculate output amount
        amountOut = getAmountOut(tokenIn, tokenOut, amountIn);
        require(amountOut >= minAmountOut, "Slippage tolerance exceeded");
        require(amountOut <= reserves[tokenOut], "Insufficient output liquidity");

        // Transfer tokens
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenOut).safeTransfer(msg.sender, amountOut);

        // Update reserves
        reserves[tokenIn] += amountIn;
        reserves[tokenOut] -= amountOut;

        emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }

    /**
     * @dev Get reserve amount for a token
     * @param token Token address
     * @return reserve Reserve amount
     */
    function getReserve(address token) external view returns (uint256 reserve) {
        return reserves[token];
    }

    /**
     * @dev Emergency withdraw function
     * @param token Token address
     */
    function emergencyWithdraw(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(msg.sender, balance);
        reserves[token] = 0;
    }
}
