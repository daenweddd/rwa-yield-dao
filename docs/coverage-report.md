Compiling 144 files with Solc 0.8.24
Solc 0.8.24 finished in 37.42s
Compiler run successful with warnings:
Warning (2018): Function state mutability can be restricted to view
   --> src/upgradeable/UpgradeableAssetManager.sol:121:5:
    |
121 |     function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {
    |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to view
  --> test/fork/ChainlinkFork.t.sol:20:5:
   |
20 |     function testForkReadChainlinkEthUsdFeed() public {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to view
  --> test/fork/USDCFork.t.sol:26:5:
   |
26 |     function testForkReadUSDCMetadata() public {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to view
  --> test/fork/UniswapFork.t.sol:38:5:
   |
38 |     function testForkReadUniswapRouter() public {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Warning (2018): Function state mutability can be restricted to view
  --> test/fork/UniswapFork.t.sol:48:5:
   |
48 |     function testForkGetAmountsOutWethToUsdc() public {
   |     ^ (Relevant source part starts here and spans across multiple lines).

Analysing contracts...
Running tests...

Ran 4 tests for test/unit/RWAFactory.t.sol:RWAFactoryTest
[PASS] testCreateAMM2RevertsForZeroAddress() (gas: 14005)
[PASS] testCreateAMMRevertsForZeroAddress() (gas: 14035)
[PASS] testCreateAMMWorks() (gas: 2723698)
[PASS] testPredictCreate2AddressWorks() (gas: 2776809)
Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 9.47ms (3.86ms CPU time)

Ran 11 tests for test/unit/GovernanceToken.t.sol:GovernanceTokenTest
[PASS] testCannotQueryPastVotesForFutureBlock() (gas: 14634)
[PASS] testClockMatchesCurrentBlock() (gas: 7398)
[PASS] testConstructorRevertsForZeroReceiver() (gas: 96256)
[PASS] testDecimalsIs18() (gas: 7199)
[PASS] testDelegateGivesVotingPower() (gas: 98129)
[PASS] testDelegationToAnotherAddressWorks() (gas: 105722)
[PASS] testInitialSupplyMintedToReceiver() (gas: 16180)
[PASS] testNameIsCorrect() (gas: 15103)
[PASS] testSymbolIsCorrect() (gas: 15954)
[PASS] testTransferWorks() (gas: 61497)
[PASS] testVotingPowerMovesAfterTransferAndDelegation() (gas: 231525)
Suite result: ok. 11 passed; 0 failed; 0 skipped; finished in 14.77ms (5.50ms CPU time)

Ran 17 tests for test/unit/MintingManager.t.sol:MintingManagerTest
[PASS] testAuthorizedIssuerCanBurn() (gas: 151811)
[PASS] testAuthorizedIssuerCanMint() (gas: 121838)
[PASS] testBurnRevertsForZeroAddress() (gas: 23541)
[PASS] testBurnRevertsForZeroAmount() (gas: 26010)
[PASS] testBurnRevertsIfOracleStale() (gas: 142079)
[PASS] testConstructorRevertsForZeroAdmin() (gas: 70921)
[PASS] testConstructorRevertsForZeroAssetToken() (gas: 71007)
[PASS] testConstructorRevertsForZeroOracle() (gas: 71696)
[PASS] testConstructorRevertsForZeroRegistry() (gas: 71423)
[PASS] testConstructorSetsValues() (gas: 19316)
[PASS] testMintRevertsForZeroAddress() (gas: 23334)
[PASS] testMintRevertsForZeroAmount() (gas: 25642)
[PASS] testMintRevertsIfOracleStale() (gas: 65016)
[PASS] testPauseBlocksMint() (gas: 54700)
[PASS] testUnauthorizedIssuerCannotBurn() (gas: 32655)
[PASS] testUnauthorizedIssuerCannotMint() (gas: 32632)
[PASS] testUnpauseRestoresMint() (gas: 137364)
Suite result: ok. 17 passed; 0 failed; 0 skipped; finished in 18.63ms (11.67ms CPU time)

Ran 7 tests for test/unit/IssuerRegistry.t.sol:IssuerRegistryTest
[PASS] testAddIssuerByNonAdminReverts() (gas: 18669)
[PASS] testAddIssuerRevertsForZeroAddress() (gas: 16988)
[PASS] testAddIssuerWorks() (gas: 49676)
[PASS] testAdminHasRoles() (gas: 20981)
[PASS] testConstructorRevertsForZeroAdmin() (gas: 38705)
[PASS] testRemoveIssuerByNonAdminReverts() (gas: 18715)
[PASS] testRemoveIssuerWorks() (gas: 43812)
Suite result: ok. 7 passed; 0 failed; 0 skipped; finished in 3.44ms (2.93ms CPU time)

Ran 5 tests for test/unit/RWAGovernor.t.sol:RWAGovernorTest
[PASS] testGovernorName() (gas: 15424)
[PASS] testGovernorVotingDelay() (gas: 9248)
[PASS] testGovernorVotingPeriod() (gas: 9318)
[PASS] testProposalThreshold() (gas: 9855)
[PASS] testTimelockDelay() (gas: 9380)
Suite result: ok. 5 passed; 0 failed; 0 skipped; finished in 5.06ms (3.03ms CPU time)

Ran 7 tests for test/unit/Math.t.sol:MathTest
[PASS] testAssemblyCalculateFeeZeroAmount() (gas: 7413)
[PASS] testAssemblyMaxEqualValues() (gas: 7221)
[PASS] testAssemblyMinEqualValues() (gas: 7606)
[PASS] testCalculateFeeMatchesSolidityVersion() (gas: 14678)
[PASS] testCalculateFeeRevertsWhenBpsTooHigh() (gas: 18493)
[PASS] testMaxMatchesSolidityVersion() (gas: 18628)
[PASS] testMinMatchesSolidityVersion() (gas: 18656)
Suite result: ok. 7 passed; 0 failed; 0 skipped; finished in 4.04ms (3.69ms CPU time)

Ran 8 tests for test/unit/RWALPToken.t.sol:RWALPTokenTest
[PASS] testBurnRevertsForNonMinter() (gas: 19456)
[PASS] testBurnRevertsForZeroAddress() (gas: 17617)
[PASS] testBurnWorksForMinter() (gas: 82804)
[PASS] testConstructorRevertsForZeroAmm() (gas: 86063)
[PASS] testConstructorSetsRoles() (gas: 21740)
[PASS] testMintRevertsForNonMinter() (gas: 19479)
[PASS] testMintRevertsForZeroAddress() (gas: 17479)
[PASS] testMintWorksForMinter() (gas: 72734)
Suite result: ok. 8 passed; 0 failed; 0 skipped; finished in 6.49ms (5.84ms CPU time)

Ran 11 tests for test/unit/AssetCertificateNFT.t.sol:AssetCertificateNFTTest
[PASS] testAdminCanGrantMinterRole() (gas: 139062)
[PASS] testAdminHasRoles() (gas: 21372)
[PASS] testConstructorRevertsForZeroAdmin() (gas: 110305)
[PASS] testMintCertificateByNonMinterReverts() (gas: 19522)
[PASS] testMintCertificateIncrementsTokenId() (gas: 176002)
[PASS] testMintCertificateRevertsForZeroReceiver() (gas: 15297)
[PASS] testMintCertificateWorks() (gas: 111590)
[PASS] testNameAndSymbolAreCorrect() (gas: 23697)
[PASS] testSupportsAccessControlInterface() (gas: 7208)
[PASS] testSupportsERC721Interface() (gas: 7274)
[PASS] testTokenURIRevertsForNonexistentToken() (gas: 16012)
Suite result: ok. 11 passed; 0 failed; 0 skipped; finished in 12.51ms (11.20ms CPU time)

Ran 20 tests for test/unit/RWAAMM.t.sol:RWAAMMTest
[PASS] testAddLiquidityRevertsForMinLiquiditySlippage() (gas: 28379)
[PASS] testAddLiquidityRevertsForZeroAmount() (gas: 21110)
[PASS] testAddLiquidityWithTinyAmountsCoversSqrtSmallBranch() (gas: 252218)
[PASS] testAddLiquidityWorks() (gas: 262572)
[PASS] testConstructorRevertsForSameToken() (gas: 68851)
[PASS] testConstructorRevertsForZeroAddress() (gas: 68013)
[PASS] testConstructorSetsTokens() (gas: 14667)
[PASS] testGetAmountOutRevertsForZeroAmount() (gas: 11054)
[PASS] testGetAmountOutRevertsForZeroReserveIn() (gas: 11277)
[PASS] testGetAmountOutRevertsForZeroReserveOut() (gas: 11897)
[PASS] testGetAmountOutWorks() (gas: 9488)
[PASS] testGetReservesWorks() (gas: 257066)
[PASS] testRemoveLiquidityRevertsForSlippage() (gas: 264992)
[PASS] testRemoveLiquidityRevertsForZeroLiquidity() (gas: 21259)
[PASS] testRemoveLiquidityWorks() (gas: 303713)
[PASS] testSwapRevertsForInsufficientLiquidity() (gas: 29061)
[PASS] testSwapRevertsForInvalidToken() (gas: 268118)
[PASS] testSwapRevertsForSlippage() (gas: 272956)
[PASS] testSwapRevertsForZeroAmount() (gas: 269069)
[PASS] testSwapWorks() (gas: 312549)
Suite result: ok. 20 passed; 0 failed; 0 skipped; finished in 44.32ms (42.41ms CPU time)

Ran 17 tests for test/unit/RWAOracleAdapter.t.sol:RWAOracleAdapterTest
[PASS] testConstructorRevertsForZeroAdmin() (gas: 44646)
[PASS] testConstructorRevertsForZeroFeed() (gas: 44843)
[PASS] testConstructorRevertsForZeroStaleness() (gas: 45200)
[PASS] testConstructorSetsValues() (gas: 24258)
[PASS] testGetLatestPriceDataReturnsCurrentTimestamp() (gas: 27959)
[PASS] testGetLatestPriceDataRevertsForInvalidPrice() (gas: 49240)
[PASS] testGetLatestPriceDataRevertsForStalePrice() (gas: 42126)
[PASS] testGetLatestPriceDataWorks() (gas: 28964)
[PASS] testGetLatestPriceRevertsForInvalidPrice() (gas: 44328)
[PASS] testGetLatestPriceRevertsForStalePrice() (gas: 41948)
[PASS] testGetLatestPriceWorks() (gas: 27689)
[PASS] testUpdateMaxStalenessByNonAdminReverts() (gas: 16783)
[PASS] testUpdateMaxStalenessRevertsForZeroValue() (gas: 16840)
[PASS] testUpdateMaxStalenessWorks() (gas: 25481)
[PASS] testUpdatePriceFeedByNonAdminReverts() (gas: 742631)
[PASS] testUpdatePriceFeedRevertsForZeroAddress() (gas: 17240)
[PASS] testUpdatePriceFeedWorks() (gas: 761394)
Suite result: ok. 17 passed; 0 failed; 0 skipped; finished in 27.07ms (18.81ms CPU time)

Ran 17 tests for test/unit/RWAAssetToken.t.sol:RWAAssetTokenTest
[PASS] testAdminHasRoles() (gas: 37152)
[PASS] testBurnByBurnerWorks() (gas: 88550)
[PASS] testBurnByNonBurnerReverts() (gas: 79976)
[PASS] testBurnRevertsForZeroAddress() (gas: 17893)
[PASS] testConstructorRevertsForEmptyAssetName() (gas: 98423)
[PASS] testConstructorRevertsForZeroAdmin() (gas: 95770)
[PASS] testMetadataIsCorrect() (gas: 40325)
[PASS] testMintByMinterWorks() (gas: 75768)
[PASS] testMintByNonMinterReverts() (gas: 19272)
[PASS] testMintRevertsForZeroAddress() (gas: 17640)
[PASS] testPauseBlocksTransfers() (gas: 105583)
[PASS] testPauseByNonPauserReverts() (gas: 16891)
[PASS] testTransferWorksWhenNotPaused() (gas: 110909)
[PASS] testUnpauseByNonPauserReverts() (gas: 16339)
[PASS] testUnpauseRestoresTransfers() (gas: 120238)
[PASS] testUpdateAssetProofURI() (gas: 32079)
[PASS] testUpdateAssetProofURIByNonAdminReverts() (gas: 17602)
Suite result: ok. 17 passed; 0 failed; 0 skipped; finished in 14.39ms (13.54ms CPU time)

Ran 15 tests for test/unit/RWATreasury.t.sol:RWATreasuryTest
[PASS] testConstructorRevertsForZeroAdmin() (gas: 62029)
[PASS] testConstructorSetsRoles() (gas: 21323)
[PASS] testERC20Balance() (gas: 17383)
[PASS] testERC20BalanceRevertsForZeroToken() (gas: 11187)
[PASS] testEtherBalance() (gas: 7615)
[PASS] testReceiveEtherWorks() (gas: 21978)
[PASS] testWithdrawERC20ByNonManagerReverts() (gas: 28245)
[PASS] testWithdrawERC20RevertsForZeroAmount() (gas: 29268)
[PASS] testWithdrawERC20RevertsForZeroReceiver() (gas: 27075)
[PASS] testWithdrawERC20RevertsForZeroToken() (gas: 26336)
[PASS] testWithdrawERC20Works() (gas: 71814)
[PASS] testWithdrawEtherByNonManagerReverts() (gas: 26229)
[PASS] testWithdrawEtherRevertsForZeroAddress() (gas: 24131)
[PASS] testWithdrawEtherRevertsForZeroAmount() (gas: 26600)
[PASS] testWithdrawEtherWorks() (gas: 62059)
Suite result: ok. 15 passed; 0 failed; 0 skipped; finished in 12.55ms (11.71ms CPU time)

Ran 3 tests for test/security/ReentrancyCaseStudy.t.sol:ReentrancyCaseStudyTest
[PASS] testFixedVaultBlocksReentrancy() (gas: 105470)
[PASS] testFixedVaultNormalWithdrawWorks() (gas: 54311)
[PASS] testVulnerableVaultCanBeDrainedByReentrancy() (gas: 100574)
Suite result: ok. 3 passed; 0 failed; 0 skipped; finished in 2.62ms (1.93ms CPU time)

Ran 12 tests for test/unit/RWAYieldVault.t.sol:RWAYieldVaultTest
[PASS] testConstructorRevertsForZeroAdmin() (gas: 122395)
[PASS] testConstructorSetsValues() (gas: 35295)
[PASS] testDepositWorks() (gas: 127039)
[PASS] testMintSharesWorks() (gas: 122439)
[PASS] testPauseBlocksDeposit() (gas: 36305)
[PASS] testRedeemWorks() (gas: 152627)
[PASS] testUnpauseRestoresDeposit() (gas: 137822)
[PASS] testUpdatePerformanceFeeTooHighReverts() (gas: 16964)
[PASS] testUpdatePerformanceFeeWorks() (gas: 46084)
[PASS] testUpdateTreasuryByNonAdminReverts() (gas: 17280)
[PASS] testUpdateTreasuryWorks() (gas: 26864)
[PASS] testWithdrawWorks() (gas: 158680)
Suite result: ok. 12 passed; 0 failed; 0 skipped; finished in 17.12ms (15.70ms CPU time)

Ran 4 tests for test/fuzz/AMMFuzz.t.sol:AMMFuzzTest
[PASS] testFuzzAddLiquidity(uint256,uint256) (runs: 256, μ: 121491, ~: 121846)
[PASS] testFuzzSlippageProtection(uint256,uint256) (runs: 256, μ: 35757, ~: 35974)
[PASS] testFuzzSwapToken0ForToken1(uint256) (runs: 256, μ: 107804, ~: 107954)
[PASS] testFuzzSwapToken1ForToken0(uint256) (runs: 256, μ: 107792, ~: 107942)
Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 734.82ms (731.14ms CPU time)

Ran 8 tests for test/security/AccessControlCaseStudy.t.sol:AccessControlCaseStudyTest
[PASS] testFixedTokenAdminCanGrantMinterRole() (gas: 102670)
[PASS] testFixedTokenAllowsAuthorizedMinter() (gas: 65445)
[PASS] testFixedTokenBlocksUnauthorizedMint() (gas: 25977)
[PASS] testFixedTokenNonMinterCannotMint() (gas: 19429)
[PASS] testFixedTokenRevertsForZeroAddressMint() (gas: 14218)
[PASS] testFixedTokenRevertsForZeroAdmin() (gas: 38626)
[PASS] testFixedTokenRevertsForZeroAmountMint() (gas: 16618)
[PASS] testVulnerableTokenAllowsAnyoneToMint() (gas: 66044)
Suite result: ok. 8 passed; 0 failed; 0 skipped; finished in 2.79ms (2.13ms CPU time)

Ran 4 tests for test/fuzz/GovernanceFuzz.t.sol:GovernanceFuzzTest
[PASS] testFuzzDelegateToAnotherAddress(uint256) (runs: 256, μ: 150761, ~: 150071)
[PASS] testFuzzDelegateVotingPower(uint256) (runs: 256, μ: 143404, ~: 142714)
[PASS] testFuzzTransferGovernanceTokens(uint256) (runs: 256, μ: 65424, ~: 64734)
[PASS] testFuzzVotingPowerMovesAfterTransfer(uint256) (runs: 256, μ: 236453, ~: 235686)
Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 619.43ms (618.38ms CPU time)

Ran 1 test for test/fork/ChainlinkFork.t.sol:ChainlinkForkTest
[PASS] testForkReadChainlinkEthUsdFeed() (gas: 30638)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 1.55s (637.17ms CPU time)

Ran 2 tests for test/invariant/TreasuryInvariant.t.sol:TreasuryInvariantTest
[PASS] invariant_EtherAccounting() (runs: 128, calls: 4096, reverts: 0)

╭-----------------+---------------+-------+---------+----------╮
| Contract        | Selector      | Calls | Reverts | Discards |
+==============================================================+
| TreasuryHandler | withdrawEther | 2116  | 0       | 0        |
|-----------------+---------------+-------+---------+----------|
| TreasuryHandler | withdrawToken | 1980  | 0       | 0        |
╰-----------------+---------------+-------+---------+----------╯

[PASS] invariant_TokenAccounting() (runs: 128, calls: 4096, reverts: 0)

╭-----------------+---------------+-------+---------+----------╮
| Contract        | Selector      | Calls | Reverts | Discards |
+==============================================================+
| TreasuryHandler | withdrawEther | 2116  | 0       | 0        |
|-----------------+---------------+-------+---------+----------|
| TreasuryHandler | withdrawToken | 1980  | 0       | 0        |
╰-----------------+---------------+-------+---------+----------╯

Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 1.61s (1.61s CPU time)

Ran 2 tests for test/fork/UniswapFork.t.sol:UniswapForkTest
[PASS] testForkGetAmountsOutWethToUsdc() (gas: 24253)
[PASS] testForkReadUniswapRouter() (gas: 13847)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 637.30ms (308.87ms CPU time)

Ran 22 tests for test/unit/UpgradeableAssetManager.t.sol:UpgradeableAssetManagerTest
[PASS] testAddAssetByNonAdminReverts() (gas: 22508)
[PASS] testAddAssetRevertsForDuplicateAsset() (gas: 99939)
[PASS] testAddAssetRevertsForInvalidRatio() (gas: 25568)
[PASS] testAddAssetRevertsForZeroAddress() (gas: 20522)
[PASS] testAddAssetWorks() (gas: 102262)
[PASS] testInitializeRevertsForZeroAdmin() (gas: 1888577)
[PASS] testInitializeSetsRoles() (gas: 29187)
[PASS] testRemoveAssetRevertsForUnsupportedAsset() (gas: 21675)
[PASS] testRemoveAssetWorks() (gas: 78240)
[PASS] testUpdateCollateralRatioRevertsForInvalidRatioTooHigh() (gas: 99377)
[PASS] testUpdateCollateralRatioRevertsForUnsupportedAsset() (gas: 22212)
[PASS] testUpdateCollateralRatioWorks() (gas: 107676)
[PASS] testUpdateOracleRevertsForUnsupportedAsset() (gas: 22177)
[PASS] testUpdateOracleRevertsForZeroOracle() (gas: 99094)
[PASS] testUpdateOracleWorks() (gas: 107788)
[PASS] testV2FreezeWorks() (gas: 132291)
[PASS] testV2RiskScoreWorks() (gas: 129625)
[PASS] testV2SetAssetFrozenRevertsForUnsupportedAsset() (gas: 21653)
[PASS] testV2SetRiskScoreRevertsForInvalidRiskScore() (gas: 99100)
[PASS] testV2SetRiskScoreRevertsForUnsupportedAsset() (gas: 21613)
[PASS] testVersionV1() (gas: 13042)
[PASS] testVersionV2() (gas: 13731)
Suite result: ok. 22 passed; 0 failed; 0 skipped; finished in 37.14ms (36.12ms CPU time)

Ran 1 test for test/fork/USDCFork.t.sol:USDCForkTest
[PASS] testForkReadUSDCMetadata() (gas: 34192)
Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 815.83ms (734.83ms CPU time)

Ran 5 tests for test/fuzz/VaultFuzz.t.sol:VaultFuzzTest
[PASS] testFuzzDeposit(uint256) (runs: 256, μ: 128277, ~: 127510)
[PASS] testFuzzMintShares(uint256) (runs: 256, μ: 128452, ~: 127685)
[PASS] testFuzzPerformanceFee(uint256,uint256) (runs: 256, μ: 52247, ~: 51944)
[PASS] testFuzzRedeemAfterDeposit(uint256,uint256) (runs: 256, μ: 156246, ~: 155998)
[PASS] testFuzzWithdrawAfterDeposit(uint256,uint256) (runs: 256, μ: 163546, ~: 163310)
Suite result: ok. 5 passed; 0 failed; 0 skipped; finished in 1.12s (1.12s CPU time)

Ran 2 tests for test/invariant/VaultInvariant.t.sol:VaultInvariantTest
[PASS] invariant_TotalAssetsEqualsVaultBalance() (runs: 128, calls: 4096, reverts: 0)

╭--------------+----------+-------+---------+----------╮
| Contract     | Selector | Calls | Reverts | Discards |
+======================================================+
| VaultHandler | deposit  | 1404  | 0       | 0        |
|--------------+----------+-------+---------+----------|
| VaultHandler | redeem   | 1322  | 0       | 0        |
|--------------+----------+-------+---------+----------|
| VaultHandler | withdraw | 1370  | 0       | 0        |
╰--------------+----------+-------+---------+----------╯

[PASS] invariant_TotalSupplyNeverExceedsTotalAssetsWhenOneToOne() (runs: 128, calls: 4096, reverts: 0)

╭--------------+----------+-------+---------+----------╮
| Contract     | Selector | Calls | Reverts | Discards |
+======================================================+
| VaultHandler | deposit  | 1404  | 0       | 0        |
|--------------+----------+-------+---------+----------|
| VaultHandler | redeem   | 1322  | 0       | 0        |
|--------------+----------+-------+---------+----------|
| VaultHandler | withdraw | 1370  | 0       | 0        |
╰--------------+----------+-------+---------+----------╯

Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 3.80s (7.01s CPU time)

Ran 2 tests for test/invariant/AMMInvariant.t.sol:AMMInvariantTest
[PASS] invariant_KNeverDecreases() (runs: 128, calls: 4096, reverts: 0)

╭------------+---------------------+-------+---------+----------╮
| Contract   | Selector            | Calls | Reverts | Discards |
+===============================================================+
| AMMHandler | swapToken0ForToken1 | 2116  | 0       | 0        |
|------------+---------------------+-------+---------+----------|
| AMMHandler | swapToken1ForToken0 | 1980  | 0       | 0        |
╰------------+---------------------+-------+---------+----------╯

[PASS] invariant_ReservesEqualBalances() (runs: 128, calls: 4096, reverts: 0)

╭------------+---------------------+-------+---------+----------╮
| Contract   | Selector            | Calls | Reverts | Discards |
+===============================================================+
| AMMHandler | swapToken0ForToken1 | 2116  | 0       | 0        |
|------------+---------------------+-------+---------+----------|
| AMMHandler | swapToken1ForToken0 | 1980  | 0       | 0        |
╰------------+---------------------+-------+---------+----------╯

Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 6.70s (8.52s CPU time)

Ran 25 test suites in 6.82s (17.82s CPU time): 207 tests passed, 0 failed, 0 skipped (207 total tests)

╭-----------------------------------------------+------------------+------------------+----------------+-----------------╮
| File                                          | % Lines          | % Statements     | % Branches     | % Funcs         |
+========================================================================================================================+
| src/amm/RWAAMM.sol                            | 94.05% (79/84)   | 95.10% (97/102)  | 89.47% (17/19) | 100.00% (9/9)   |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| src/amm/RWALPToken.sol                        | 100.00% (13/13)  | 100.00% (10/10)  | 100.00% (3/3)  | 100.00% (3/3)   |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| src/factory/RWAFactory.sol                    | 100.00% (18/18)  | 100.00% (20/20)  | 100.00% (2/2)  | 100.00% (4/4)   |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| src/governance/RWAGovernor.sol                | 30.00% (6/20)    | 31.58% (6/19)    | 100.00% (0/0)  | 30.00% (3/10)   |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| src/issuer/IssuerRegistry.sol                 | 94.12% (16/17)   | 92.86% (13/14)   | 66.67% (2/3)   | 100.00% (4/4)   |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| src/issuer/MintingManager.sol                 | 94.12% (32/34)   | 94.29% (33/35)   | 100.00% (7/7)  | 100.00% (5/5)   |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| src/math/AssemblyMath.sol                     | 62.50% (5/8)     | 40.00% (2/5)     | 100.00% (1/1)  | 100.00% (3/3)   |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| src/math/SolidityMath.sol                     | 100.00% (8/8)    | 100.00% (8/8)    | 100.00% (1/1)  | 100.00% (3/3)   |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| src/mocks/MockV3Aggregator.sol                | 88.89% (16/18)   | 92.31% (12/13)   | 100.00% (0/0)  | 80.00% (4/5)    |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| src/oracle/RWAOracleAdapter.sol               | 97.30% (36/37)   | 97.37% (37/38)   | 100.00% (8/8)  | 100.00% (6/6)   |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| src/token/AssetCertificateNFT.sol             | 100.00% (15/15)  | 100.00% (12/12)  | 0.00% (0/4)    | 100.00% (4/4)   |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| src/token/GovernanceToken.sol                 | 71.43% (5/7)     | 60.00% (3/5)     | 0.00% (0/2)    | 66.67% (2/3)    |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| src/token/RWAAssetToken.sol                   | 93.10% (27/29)   | 90.91% (20/22)   | 100.00% (4/4)  | 100.00% (7/7)   |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| src/treasury/RWATreasury.sol                  | 96.55% (28/29)   | 96.30% (26/27)   | 85.71% (6/7)   | 100.00% (6/6)   |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| src/upgradeable/UpgradeableAssetManager.sol   | 91.30% (42/46)   | 92.86% (39/42)   | 90.00% (9/10)  | 88.89% (8/9)    |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| src/upgradeable/UpgradeableAssetManagerV2.sol | 95.45% (21/22)   | 100.00% (15/15)  | 100.00% (4/4)  | 83.33% (5/6)    |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| src/vault/RWAYieldVault.sol                   | 90.91% (30/33)   | 89.29% (25/28)   | 66.67% (2/3)   | 100.00% (10/10) |
|-----------------------------------------------+------------------+------------------+----------------+-----------------|
| Total                                         | 90.64% (397/438) | 91.08% (378/415) | 84.62% (66/78) | 88.66% (86/97)  |
╰-----------------------------------------------+------------------+------------------+----------------+-----------------╯
