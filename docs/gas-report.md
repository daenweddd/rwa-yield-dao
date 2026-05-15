# Gas Report — RealYield RWA DAO

## 1. Overview

This document summarizes gas usage for the RealYield RWA DAO smart contracts.

Gas measurements are collected using Foundry.

The purpose of this report is to document the relative gas cost of core protocol actions, including:

- token minting and burning;
- vault deposits and withdrawals;
- AMM liquidity operations;
- AMM swaps;
- treasury withdrawals;
- oracle reads;
- governance configuration;
- upgradeable asset manager operations.

---

## 2. Command Used

Gas reporting can be generated with:

```bash
forge test --gas-report
The command should be run from the contracts directory:

cd contracts
forge test --gas-report
3. Gas-Critical Contracts

The most gas-sensitive contracts in this project are:

RWAAMM.sol
RWAYieldVault.sol
MintingManager.sol
RWATreasury.sol
RWAAssetToken.sol
UpgradeableAssetManager.sol
UpgradeableAssetManagerV2.sol

These contracts are gas-sensitive because they are expected to be called by users, issuers, liquidity providers, treasury managers, or governance operators.

4. Core Gas Operations
4.1 RWAAssetToken

Important gas operations:

mint
burn
pause
unpause
updateAssetProofURI

Gas considerations:

Minting and burning are restricted with role checks.
Pausable transfer logic adds security at the cost of additional checks.
Metadata update is admin-only and not expected to be called frequently.
4.2 GovernanceToken

Important gas operations:

token transfer;
delegation;
vote checkpoint updates.

Gas considerations:

ERC20Votes adds checkpoint storage writes.
Transfers after delegation are more expensive than normal ERC-20 transfers because voting power must be updated.
Governance operations are expected to be less frequent than normal token transfers.
4.3 AssetCertificateNFT

Important gas operations:

mintCertificate
tokenURI

Gas considerations:

_safeMint includes an external receiver check when minting to contracts.
Metadata URI storage adds a storage write per certificate.
Minting is permissioned through CERTIFICATE_MINTER_ROLE.
4.4 RWAYieldVault

Important gas operations:

deposit
mint
withdraw
redeem
updateTreasury
updatePerformanceFeeBps

Gas considerations:

ERC4626 vault operations include asset transfer and share accounting.
Pause checks and reentrancy protection add security overhead.
Admin configuration functions are low-frequency operations.
4.5 RWAOracleAdapter

Important gas operations:

getLatestPrice
getLatestPriceData
updatePriceFeed
updateMaxStaleness

Gas considerations:

Oracle reads are external calls to a Chainlink-style feed.
Staleness and invalid price checks are required for safety.
Admin update functions are not expected to be called frequently.
4.6 IssuerRegistry

Important gas operations:

addIssuer
removeIssuer
isIssuer

Gas considerations:

Role-based issuer management uses OpenZeppelin AccessControl.
Issuer updates are admin operations.
isIssuer is a view function and is used by MintingManager.
4.7 MintingManager

Important gas operations:

mint
burn
pause
unpause

Gas considerations:

Minting and burning require issuer checks.
Oracle freshness is checked before minting and burning.
Reentrancy protection is included for safety.
The manager must have mint and burn roles on the asset token.
4.8 RWAAMM

Important gas operations:

addLiquidity
removeLiquidity
swap
getAmountOut

Gas considerations:

Swaps and liquidity operations are frequent user-facing actions.
Reserve updates read token balances after transfers.
nonReentrant protects state-changing AMM operations.
Slippage checks protect users from unexpected execution prices.
4.9 RWALPToken

Important gas operations:

mint
burn

Gas considerations:

LP minting and burning are restricted to the AMM.
AccessControl role checks add security overhead.
LP token operations are only called through liquidity flows.
4.10 RWAFactory

Important gas operations:

createAMM
createAMM2
predictAMM2Address

Gas considerations:

AMM deployment is expensive but infrequent.
CREATE2 deployment supports deterministic AMM addresses.
Address prediction is a view operation.
4.11 RWATreasury

Important gas operations:

withdrawEther
withdrawERC20
etherBalance
erc20Balance

Gas considerations:

Withdrawals are protected with role checks and nonReentrant.
ETH withdrawal uses a low-level call and checks success.
ERC20 withdrawal uses SafeERC20.
4.12 UpgradeableAssetManager

Important gas operations:

initialize
addAsset
removeAsset
updateCollateralRatio
updateOracle
upgradeToAndCall

Gas considerations:

Asset configuration writes are storage-heavy but infrequent.
UUPS upgrade authorization is restricted to UPGRADER_ROLE.
Asset configuration reads are lightweight.
4.13 UpgradeableAssetManagerV2

Important gas operations:

setRiskScore
setAssetFrozen
getRiskConfig
requireAssetNotFrozen

Gas considerations:

V2 adds risk configuration storage.
Freeze status checks are simple reads.
Risk score and freeze updates are restricted admin operations.
5. Optimization Notes

The project applies the following gas-aware design decisions:

frequent functions use simple validation logic;
external calls are minimized where possible;
immutable variables are used in AMM token references;
view functions are used for read-only operations;
assembly math is isolated in a separate comparison contract;
admin-only configuration functions are not optimized aggressively because they are low-frequency operations.
6. Security vs Gas Tradeoffs

Some gas overhead is intentionally accepted for security.

Examples:

ReentrancyGuard increases gas cost but protects withdrawals and AMM operations.
AccessControl increases gas cost but provides clear role separation.
Pausable adds checks but allows emergency response.
Oracle staleness checks add validation but prevent stale-price usage.
ERC20Votes increases transfer/delegation cost but enables governance.

These tradeoffs are acceptable because the project prioritizes safety and correctness over minimal gas cost.

7. How to Reproduce

To reproduce the gas report:

cd contracts
forge test --gas-report

To save the gas output manually:

forge test --gas-report > ../docs/gas-output.txt

The summarized gas analysis is documented in this file:

docs/gas-report.md
8. Conclusion

The RealYield RWA DAO protocol uses standard security-focused Solidity patterns such as AccessControl, ReentrancyGuard, ERC4626, ERC20Votes, UUPS upgradeability, and Chainlink-style oracle reads.

Gas costs are acceptable for a security-focused academic RWA protocol. The most gas-sensitive areas are AMM operations, vault operations, and governance token delegation. Security-related gas overhead is intentional and documented.