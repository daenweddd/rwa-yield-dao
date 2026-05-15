## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help

```
# RealYield RWA DAO

RealYield RWA DAO is a Solidity-based protocol for tokenized real-world assets. The project includes RWA asset tokens, NFT asset certificates, oracle integration, issuer management, a yield vault, an AMM, treasury management, governance, upgradeable asset configuration, and a full Foundry test suite.

This repository was built for a blockchain final project using Foundry.

---

## Features

- ERC-20 RWA asset token
- ERC-20 governance token with voting support
- ERC-721 asset certificate NFT
- ERC-4626 yield vault
- Chainlink-style oracle adapter
- Authorized issuer registry
- Minting and burning manager
- Constant-product AMM
- LP token
- AMM factory with CREATE2 support
- Treasury contract
- Governor and timelock governance
- UUPS upgradeable asset manager
- Assembly vs Solidity math comparison
- Unit tests
- Fuzz tests
- Invariant tests
- Mainnet fork tests
- Security case studies
- Slither static analysis
- Coverage report
- GitHub Actions CI

---

## Project Structure

```text
contracts/
  src/
    amm/
    factory/
    governance/
    issuer/
    math/
    mocks/
    oracle/
    token/
    treasury/
    upgradeable/
    vault/
  script/
  test/
    unit/
    fuzz/
    invariant/
    fork/
    security/

docs/
  audit-report.md
  architecture.md
  coverage-report.md
  gas-report.md
  slither-report.txt

.github/
  workflows/
    foundry.yml


Core Contracts
Tokens
RWAAssetToken.sol — ERC-20 token representing tokenized real-world assets.
GovernanceToken.sol — governance token with voting and delegation support.
AssetCertificateNFT.sol — ERC-721 certificate NFT for asset metadata/proofs.
Vault
RWAYieldVault.sol — ERC-4626 vault for depositing RWA asset tokens and receiving vault shares.
Oracle
RWAOracleAdapter.sol — Chainlink-style oracle adapter with stale price and invalid price checks.
MockV3Aggregator.sol — mock oracle feed for tests.
Issuer System
IssuerRegistry.sol — registry of authorized issuers.
MintingManager.sol — minting and burning manager that checks issuer authorization and oracle validity.
AMM
RWAAMM.sol — constant-product AMM.
RWALPToken.sol — LP token minted by the AMM.
RWAFactory.sol — factory for deploying AMM pairs.
Governance
RWAGovernor.sol — OpenZeppelin Governor-based governance contract.
RWATimelock.sol — governance timelock controller.
Treasury
RWATreasury.sol — ETH and ERC-20 treasury with role-gated withdrawals.
Upgradeability
UpgradeableAssetManager.sol — UUPS upgradeable asset configuration manager.
UpgradeableAssetManagerV2.sol — V2 implementation with risk score and freeze status support.
Math
SolidityMath.sol — pure Solidity math implementation.
AssemblyMath.sol — inline assembly math implementation for comparison.
Requirements

Install Foundry:

curl -L https://foundry.paradigm.xyz | bash
foundryup

Install dependencies:

cd contracts
forge install
Build

Run from the contracts directory:

forge build
Test

Run all tests:

forge test

The test suite includes:

unit tests;
fuzz tests;
invariant tests;
fork tests;
security case-study tests.
Coverage

Coverage is measured with Foundry:

forge coverage --ir-minimum --no-match-coverage "^(script|test)/"

The coverage report is stored at:

docs/coverage-report.md

Project requirement:

Line coverage >= 90%
Slither

Run Slither from the contracts directory:

slither . --exclude-dependencies

The Slither report is stored at:

docs/slither-report.txt

Project requirement:

High findings: 0
Medium findings: 0

Low and informational findings are reviewed in:

docs/audit-report.md
Gas Report

Generate gas report:

cd contracts
forge test --gas-report

Gas documentation is stored at:

docs/gas-report.md

## Fork Tests

The project includes mainnet fork tests for external protocol integrations.

Fork tests are located in:

```text
contracts/test/fork

Included fork tests:

ChainlinkFork.t.sol — reads the Chainlink ETH/USD price feed.
USDCFork.t.sol — reads USDC metadata and total supply on Ethereum mainnet.
UniswapFork.t.sol — reads Uniswap V2 router data and checks WETH to USDC output.

Fork tests use the MAINNET_RPC_URL environment variable.

Example:

export MAINNET_RPC_URL="https://eth-mainnet.g.alchemy.com/v2/ucPjk5ZKXZ60NR8F3v8TP"

Run fork tests:

cd contracts
forge test --match-path "test/fork/*.t.sol" -vv

The fork tests are written so that normal forge test can still run without a configured RPC URL.

Security Case Studies

The project includes security case-study tests in:

contracts/test/security

Included case studies:

ReentrancyCaseStudy.t.sol
AccessControlCaseStudy.t.sol
Reentrancy Case Study

The reentrancy case study demonstrates:

a vulnerable ETH vault;
an attacker contract;
a fixed vault using checks-effects-interactions and ReentrancyGuard;
tests proving that the vulnerable version can be exploited;
tests proving that the fixed version blocks the attack.
Access Control Case Study

The access-control case study demonstrates:

a vulnerable token where anyone can mint;
an attacker minting arbitrary tokens;
a fixed token using AccessControl;
a MINTER_ROLE permission model;
tests proving unauthorized minting is blocked.
Documentation

Project documentation is stored in:

docs/

Important files:

docs/audit-report.md — security audit report.
docs/architecture.md — protocol architecture.
docs/coverage-report.md — Foundry coverage report.
docs/gas-report.md — gas usage summary.
docs/slither-report.txt — Slither static analysis output.
Continuous Integration

The repository includes GitHub Actions CI:

.github/workflows/foundry.yml

The CI workflow runs:

forge build
forge test

All tests must pass in CI on the final commit.

How to Reproduce Locally

Clone the repository:

git clone https://github.com/daenweddd/rwa-yield-dao.git
cd rwa-yield-dao

Enter the contracts directory:

cd contracts

Build contracts:

forge build

Run tests:

forge test

Run coverage:

forge coverage --ir-minimum --no-match-coverage "^(script|test)/"

Run Slither:

slither . --exclude-dependencies

Run gas report:

forge test --gas-report
Reports

The project includes checked-in reports:

docs/coverage-report.md
docs/slither-report.txt
docs/audit-report.md
docs/architecture.md
docs/gas-report.md

These reports document testing, static analysis, architecture, gas usage, and security review.

Final Project Status

Current project status:

Smart contracts implemented.
Unit tests implemented.
Fuzz tests implemented.
Invariant tests implemented.
Fork tests implemented.
Security case studies implemented.
Coverage report included.
Slither report included.
Audit report included.
Architecture documentation included.
Gas report included.
GitHub Actions CI included.
License

This project is licensed under the MIT License.


