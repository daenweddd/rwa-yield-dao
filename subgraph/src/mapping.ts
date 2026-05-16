import {
  Transfer,
  AssetProofURIUpdated
} from "../generated/RWAAssetToken/RWAAssetToken";

import {
  Deposit,
  Withdraw,
  TreasuryUpdated,
  PerformanceFeeUpdated
} from "../generated/RWAYieldVault/RWAYieldVault";

import {
  LiquidityAdded as LiquidityAddedEvent,
  LiquidityRemoved as LiquidityRemovedEvent,
  Swap as SwapEvent
} from "../generated/RWAAMM/RWAAMM";

import {
  EtherReceived,
  EtherWithdrawn,
  ERC20Withdrawn
} from "../generated/RWATreasury/RWATreasury";

import {
  TokenTransfer,
  TokenMint,
  TokenBurn,
  AssetProofUpdate,
  VaultDeposit,
  VaultWithdraw,
  TreasuryUpdate,
  PerformanceFeeUpdate,
  LiquidityAdded,
  LiquidityRemoved,
  Swap,
  TreasuryETHReceived,
  TreasuryETHWithdrawn,
  TreasuryERC20Withdrawn
} from "../generated/schema";

function makeEventId(txHash: string, logIndex: string): string {
  return txHash.concat("-").concat(logIndex);
}

export function handleTransfer(event: Transfer): void {
  const id = makeEventId(
    event.transaction.hash.toHexString(),
    event.logIndex.toString()
  );

  const transfer = new TokenTransfer(id);
  transfer.from = event.params.from;
  transfer.to = event.params.to;
  transfer.amount = event.params.value;
  transfer.blockNumber = event.block.number;
  transfer.blockTimestamp = event.block.timestamp;
  transfer.transactionHash = event.transaction.hash;
  transfer.save();

  if (event.params.from.toHexString() == "0x0000000000000000000000000000000000000000") {
    const mint = new TokenMint(id);
    mint.to = event.params.to;
    mint.amount = event.params.value;
    mint.blockNumber = event.block.number;
    mint.blockTimestamp = event.block.timestamp;
    mint.transactionHash = event.transaction.hash;
    mint.save();
  }

  if (event.params.to.toHexString() == "0x0000000000000000000000000000000000000000") {
    const burn = new TokenBurn(id);
    burn.from = event.params.from;
    burn.amount = event.params.value;
    burn.blockNumber = event.block.number;
    burn.blockTimestamp = event.block.timestamp;
    burn.transactionHash = event.transaction.hash;
    burn.save();
  }
}

export function handleAssetProofURIUpdated(event: AssetProofURIUpdated): void {
  const id = makeEventId(
    event.transaction.hash.toHexString(),
    event.logIndex.toString()
  );

  const update = new AssetProofUpdate(id);
  update.oldURI = event.params.oldURI;
  update.newURI = event.params.newURI;
  update.blockNumber = event.block.number;
  update.blockTimestamp = event.block.timestamp;
  update.transactionHash = event.transaction.hash;
  update.save();
}

export function handleDeposit(event: Deposit): void {
  const id = makeEventId(
    event.transaction.hash.toHexString(),
    event.logIndex.toString()
  );

  const deposit = new VaultDeposit(id);
  deposit.caller = event.params.sender;
  deposit.owner = event.params.owner;
  deposit.assets = event.params.assets;
  deposit.shares = event.params.shares;
  deposit.blockNumber = event.block.number;
  deposit.blockTimestamp = event.block.timestamp;
  deposit.transactionHash = event.transaction.hash;
  deposit.save();
}

export function handleWithdraw(event: Withdraw): void {
  const id = makeEventId(
    event.transaction.hash.toHexString(),
    event.logIndex.toString()
  );

  const withdraw = new VaultWithdraw(id);
  withdraw.caller = event.params.sender;
  withdraw.receiver = event.params.receiver;
  withdraw.owner = event.params.owner;
  withdraw.assets = event.params.assets;
  withdraw.shares = event.params.shares;
  withdraw.blockNumber = event.block.number;
  withdraw.blockTimestamp = event.block.timestamp;
  withdraw.transactionHash = event.transaction.hash;
  withdraw.save();
}

export function handleTreasuryUpdated(event: TreasuryUpdated): void {
  const id = makeEventId(
    event.transaction.hash.toHexString(),
    event.logIndex.toString()
  );

  const update = new TreasuryUpdate(id);
  update.oldTreasury = event.params.oldTreasury;
  update.newTreasury = event.params.newTreasury;
  update.blockNumber = event.block.number;
  update.blockTimestamp = event.block.timestamp;
  update.transactionHash = event.transaction.hash;
  update.save();
}

export function handlePerformanceFeeUpdated(event: PerformanceFeeUpdated): void {
  const id = makeEventId(
    event.transaction.hash.toHexString(),
    event.logIndex.toString()
  );

  const update = new PerformanceFeeUpdate(id);
  update.oldFeeBps = event.params.oldFeeBps;
  update.newFeeBps = event.params.newFeeBps;
  update.blockNumber = event.block.number;
  update.blockTimestamp = event.block.timestamp;
  update.transactionHash = event.transaction.hash;
  update.save();
}

export function handleLiquidityAdded(event: LiquidityAddedEvent): void {
  const id = makeEventId(
    event.transaction.hash.toHexString(),
    event.logIndex.toString()
  );

  const entity = new LiquidityAdded(id);
  entity.provider = event.params.provider;
  entity.amount0 = event.params.amount0;
  entity.amount1 = event.params.amount1;
  entity.liquidity = event.params.liquidity;
  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;
  entity.save();
}

export function handleLiquidityRemoved(event: LiquidityRemovedEvent): void {
  const id = makeEventId(
    event.transaction.hash.toHexString(),
    event.logIndex.toString()
  );

  const entity = new LiquidityRemoved(id);
  entity.provider = event.params.provider;
  entity.amount0 = event.params.amount0;
  entity.amount1 = event.params.amount1;
  entity.liquidity = event.params.liquidity;
  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;
  entity.save();
}

export function handleSwap(event: SwapEvent): void {
  const id = makeEventId(
    event.transaction.hash.toHexString(),
    event.logIndex.toString()
  );

  const entity = new Swap(id);
  entity.trader = event.params.user;
  entity.tokenIn = event.params.tokenIn;
  entity.tokenOut = event.params.tokenOut;
  entity.amountIn = event.params.amountIn;
  entity.amountOut = event.params.amountOut;
  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;
  entity.save();
}



export function handleEtherReceived(event: EtherReceived): void {
  const id = makeEventId(
    event.transaction.hash.toHexString(),
    event.logIndex.toString()
  );

  const entity = new TreasuryETHReceived(id);
  entity.sender = event.params.sender;
  entity.amount = event.params.amount;
  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;
  entity.save();
}

export function handleEtherWithdrawn(event: EtherWithdrawn): void {
  const id = makeEventId(
    event.transaction.hash.toHexString(),
    event.logIndex.toString()
  );

  const entity = new TreasuryETHWithdrawn(id);
  entity.to = event.params.to;
  entity.amount = event.params.amount;
  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;
  entity.save();
}

export function handleERC20Withdrawn(event: ERC20Withdrawn): void {
  const id = makeEventId(
    event.transaction.hash.toHexString(),
    event.logIndex.toString()
  );

  const entity = new TreasuryERC20Withdrawn(id);
  entity.token = event.params.token;
  entity.to = event.params.to;
  entity.amount = event.params.amount;
  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;
  entity.save();
}