# SwapDen Smart Contract

## Overview

This is a simple Automated Market Maker (AMM) style token swap contract that allows users to swap ERC20 tokens with minimal fees.

## Features

- **Token Swapping**: Swap between any supported ERC20 tokens
- **Liquidity Pools**: Constant product formula (x * y = k) for pricing
- **Low Fees**: 0.3% swap fee
- **Slippage Protection**: Minimum output amount parameter
- **Security**: ReentrancyGuard and SafeERC20 implementations

## Contract Functions

### User Functions

- `swap(tokenIn, tokenOut, amountIn, minAmountOut)`: Swap tokens
- `getAmountOut(tokenIn, tokenOut, amountIn)`: Calculate expected output amount

### Owner Functions

- `addLiquidity(token, amount)`: Add liquidity to a pool
- `removeLiquidity(token, amount)`: Remove liquidity from a pool
- `emergencyWithdraw(token)`: Emergency withdrawal function

## Deployment

### Prerequisites

\`\`\`bash
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
npm install @openzeppelin/contracts
\`\`\`

### Deploy Script

Create `scripts/deploy.ts`:

\`\`\`typescript
import { ethers } from "hardhat";

async function main() {
  const TokenSwap = await ethers.getContractFactory("TokenSwap");
  const tokenSwap = await TokenSwap.deploy();
  await tokenSwap.waitForDeployment();

  console.log("TokenSwap deployed to:", await tokenSwap.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
\`\`\`

### Deploy

\`\`\`bash
npx hardhat run scripts/deploy.ts --network <network-name>
\`\`\`

## Testing

Create comprehensive tests in `test/TokenSwap.test.ts` to verify:
- Swap functionality
- Liquidity management
- Fee calculations
- Slippage protection
- Access control

## Security Considerations

1. **Audits**: Get the contract audited before mainnet deployment
2. **Liquidity**: Ensure sufficient liquidity in pools
3. **Price Oracle**: Consider integrating Chainlink or other oracles for better pricing
4. **Front-running**: Implement additional MEV protection if needed
5. **Upgradability**: Consider using proxy patterns for future upgrades

## Integration

Update the contract address in `lib/contracts/token-swap.ts` after deployment:

\`\`\`typescript
export const CONTRACTS = {
  TOKEN_SWAP: '0xYourDeployedContractAddress',
  // ...
}
\`\`\`

## License

MIT
