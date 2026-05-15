# Architecture — RealYield RWA DAO

## 1. Overview

RealYield RWA DAO is a Solidity-based protocol for tokenized real-world assets. The system combines asset-backed ERC-20 tokens, NFT asset certificates, yield vaults, oracle-based price validation, issuer permissions, AMM liquidity, treasury management, governance, and upgradeable asset configuration.

The protocol is designed as a modular smart-contract system where each contract has a separate responsibility.

---

## 2. Main Components

### 2.1 `RWAAssetToken`

`RWAAssetToken` is the main ERC-20 token representing a tokenized real-world asset.

Main responsibilities:

- minting asset-backed tokens;
- burning tokens;
- pausing transfers during emergencies;
- storing asset metadata;
- enforcing role-based access control.

Roles:

- `DEFAULT_ADMIN_ROLE`
- `MINTER_ROLE`
- `BURNER_ROLE`
- `PAUSER_ROLE`

---

### 2.2 `GovernanceToken`

`GovernanceToken` is the protocol governance token.

It supports:

- ERC-20 transfers;
- voting power delegation;
- vote checkpoints;
- governance voting through OpenZeppelin Governor.

---

### 2.3 `AssetCertificateNFT`

`AssetCertificateNFT` is an ERC-721 certificate contract used to represent asset certificates or metadata proofs.

It supports:

- permissioned minting;
- token metadata URI storage;
- role-based certificate issuance.

---

### 2.4 `RWAYieldVault`

`RWAYieldVault` is an ERC-4626 vault for depositing RWA asset tokens and receiving vault shares.

Main responsibilities:

- deposits;
- withdrawals;
- minting vault shares;
- redeeming vault shares;
- treasury configuration;
- performance fee preview;
- pause and unpause controls.

---

### 2.5 `RWAOracleAdapter`

`RWAOracleAdapter` connects the protocol to a Chainlink-style oracle feed.

Main responsibilities:

- reading latest price data;
- rejecting invalid prices;
- rejecting stale oracle data;
- allowing admin-controlled feed updates;
- allowing admin-controlled staleness configuration.

---

### 2.6 `IssuerRegistry`

`IssuerRegistry` controls which issuers are authorized to mint or burn RWA-backed tokens through the minting manager.

Main responsibilities:

- add authorized issuers;
- remove authorized issuers;
- check issuer authorization.

---

### 2.7 `MintingManager`

`MintingManager` connects the asset token, issuer registry, and oracle adapter.

Main responsibilities:

- allow authorized issuers to mint;
- allow authorized issuers to burn;
- check oracle price before minting or burning;
- pause and unpause minting operations.

---

### 2.8 `RWAAMM`

`RWAAMM` is a constant-product automated market maker.

Main responsibilities:

- add liquidity;
- remove liquidity;
- swap between two ERC-20 tokens;
- calculate output amounts;
- maintain reserves;
- enforce slippage checks.

---

### 2.9 `RWALPToken`

`RWALPToken` is the ERC-20 liquidity provider token minted by the AMM.

Main responsibilities:

- mint LP tokens to liquidity providers;
- burn LP tokens during liquidity removal;
- restrict minting and burning to the AMM.

---

### 2.10 `RWAFactory`

`RWAFactory` deploys new AMM pairs.

Main responsibilities:

- create AMMs with normal deployment;
- create AMMs with deterministic CREATE2 deployment;
- predict CREATE2 AMM addresses;
- track deployed AMMs.

---

### 2.11 `RWATreasury`

`RWATreasury` stores ETH and ERC-20 protocol funds.

Main responsibilities:

- receive ETH;
- withdraw ETH;
- withdraw ERC-20 tokens;
- restrict withdrawals to treasury managers;
- protect withdrawals with reentrancy guard.

---

### 2.12 `RWAGovernor` and `RWATimelock`

`RWAGovernor` and `RWATimelock` implement protocol governance.

Main responsibilities:

- proposal creation;
- voting;
- quorum checks;
- proposal execution through timelock;
- delayed governance execution.

---

### 2.13 `UpgradeableAssetManager`

`UpgradeableAssetManager` stores supported asset configuration.

Main responsibilities:

- add supported assets;
- remove supported assets;
- update collateral ratios;
- update oracle addresses;
- authorize upgrades through `UPGRADER_ROLE`.

---

### 2.14 `UpgradeableAssetManagerV2`

`UpgradeableAssetManagerV2` extends the asset manager with risk configuration.

Main responsibilities:

- assign risk scores;
- freeze assets;
- check freeze status;
- preserve upgradeable architecture.

---

### 2.15 `AssemblyMath` and `SolidityMath`

`AssemblyMath` and `SolidityMath` provide small arithmetic helper implementations.

Main purpose:

- compare a Solidity implementation with an inline assembly implementation;
- support gas and implementation comparison;
- demonstrate low-level Solidity optimization concepts.

---

## 3. High-Level Architecture Diagram

```text
                            ┌──────────────────────┐
                            │   GovernanceToken     │
                            │      ERC20Votes       │
                            └──────────┬───────────┘
                                       │
                                       ▼
┌──────────────────────┐      ┌──────────────────────┐
│     RWAGovernor       │─────▶│     RWATimelock      │
└──────────────────────┘      └──────────────────────┘


┌──────────────────────┐      ┌──────────────────────┐
│    IssuerRegistry     │─────▶│    MintingManager    │
└──────────────────────┘      └──────────┬───────────┘
                                         │
                                         ▼
                              ┌──────────────────────┐
                              │    RWAAssetToken     │
                              └──────────┬───────────┘
                                         │
                                         ▼
                              ┌──────────────────────┐
                              │    RWAYieldVault     │
                              └──────────────────────┘


┌──────────────────────┐      ┌──────────────────────┐
│   RWAOracleAdapter    │─────▶│    Chainlink Feed    │
└──────────────────────┘      └──────────────────────┘


┌──────────────────────┐      ┌──────────────────────┐
│      RWAFactory       │─────▶│        RWAAMM        │
└──────────────────────┘      └──────────┬───────────┘
                                         │
                                         ▼
                              ┌──────────────────────┐
                              │      RWALPToken      │
                              └──────────────────────┘


┌──────────────────────┐
│      RWATreasury      │
└──────────────────────┘

┌──────────────────────┐
│  AssetCertificateNFT  │
└──────────────────────┘

┌──────────────────────────────┐
│  UpgradeableAssetManager V1/V2│
└──────────────────────────────┘

4. Main Protocol Flows
4.1 Asset Issuance Flow
Admin deploys RWAAssetToken, IssuerRegistry, RWAOracleAdapter, and MintingManager.
Admin grants MintingManager mint and burn roles on RWAAssetToken.
Admin adds an issuer to IssuerRegistry.
Authorized issuer calls MintingManager.mint.
MintingManager checks issuer authorization.
MintingManager checks oracle freshness and validity.
MintingManager mints asset tokens to the receiver.
4.2 Asset Burn Flow
Authorized issuer calls MintingManager.burn.
MintingManager checks issuer authorization.
MintingManager checks oracle freshness and validity.
MintingManager burns tokens from the specified account.
4.3 Vault Flow
User receives or buys RWA asset tokens.
User approves RWAYieldVault.
User deposits assets into the vault.
Vault mints ERC-4626 shares.
User can later withdraw assets or redeem shares.
4.4 AMM Flow
Liquidity provider approves both AMM tokens.
Liquidity provider adds liquidity.
AMM mints LP tokens.
Traders swap between token0 and token1.
AMM updates reserves after each operation.
Liquidity provider burns LP tokens to remove liquidity.
4.5 Governance Flow
Governance token holders delegate voting power.
Eligible holders create proposals.
Token holders vote.
Successful proposals are queued in the timelock.
After delay, proposals can be executed.
4.6 Treasury Flow
Treasury receives ETH or ERC-20 tokens.
A treasury manager calls a withdrawal function.
The treasury validates role permissions.
The treasury validates address and amount.
Funds are transferred out.
Reentrancy protection prevents nested withdrawal attacks.
4.7 Upgrade Flow
Admin deploys upgradeable asset manager implementation.
Proxy points to implementation.
Admin with UPGRADER_ROLE authorizes upgrade.
V2 adds risk score and freeze functionality.
5. Security Controls

The system includes several security controls:

role-based access control;
reentrancy guards;
pausable operations;
oracle staleness checks;
zero address checks;
zero amount checks;
slippage protection;
timelock governance;
upgrade authorization;
unit tests;
fuzz tests;
invariant tests;
fork tests;
Slither static analysis.
6. Role Model
Admin Roles

Admin roles are responsible for setup and protocol configuration.

Examples:

granting mint and burn roles;
managing issuers;
configuring oracles;
configuring treasury managers;
authorizing upgrades.
Issuer Roles

Issuer roles are responsible for asset-backed minting and burning through the MintingManager.

Issuers cannot mint directly unless the required role model is configured through the manager and token contracts.

Treasury Manager Role

Treasury managers can withdraw ETH and ERC-20 tokens from RWATreasury.

Pauser Roles

Pauser roles can pause critical operations during emergency conditions.

Upgrader Role

The upgrader role authorizes UUPS upgrades for the upgradeable asset manager.

7. Testing Architecture

The test suite is organized into:

test/unit
test/fuzz
test/invariant
test/fork
test/security
Unit Tests

Unit tests validate expected behavior of individual contracts.

Examples:

token metadata;
minting;
burning;
access control;
treasury withdrawals;
vault deposits;
AMM swaps;
oracle stale price checks.
Fuzz Tests

Fuzz tests validate behavior over randomized inputs.

Covered areas:

AMM swaps;
vault deposits and withdrawals;
governance token transfers and delegation.
Invariant Tests

Invariant tests verify that core accounting properties remain true across many state transitions.

Covered areas:

AMM reserve accounting;
vault asset accounting;
treasury balance accounting.
Fork Tests

Fork tests validate integrations with mainnet contracts.

Covered integrations:

Chainlink ETH/USD feed;
USDC token metadata;
Uniswap V2 router behavior.
Security Tests

Security tests demonstrate vulnerable and fixed implementations for:

reentrancy;
missing access control.
8. Deployment Scripts

Deployment scripts are stored in:

contracts/script

The scripts support:

deployment;
verification;
upgrade flows.
9. Documentation Files

Important project documentation:

docs/coverage-report.md
docs/slither-report.txt
docs/audit-report.md
docs/architecture.md
10. Conclusion

The RealYield RWA DAO architecture is modular and security-focused.

Each contract has a clear responsibility, and critical operations are protected with access control, validation checks, reentrancy protection, oracle staleness checks, and testing.

The project is structured to support future expansion through governance, upgradeable asset configuration, and modular protocol components.