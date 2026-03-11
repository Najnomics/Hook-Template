# Deployment

## Deterministic Bootstrap
```bash
make bootstrap
make verify-deps
```

This enforces pinned Uniswap dependency state and lockfile-based installs.

## Factory Deployment
```bash
forge script script/DeployTemplateFactory.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
```

## Template Lifecycle Deployment (Recommended)
Use the orchestrated demo runner to deploy, initialize, add liquidity, and run swaps with proof logs:

```bash
# local broadcast
bash scripts/demo_local.sh all deploy

# testnet broadcast
bash scripts/demo_testnet.sh all deploy
```

## Testnet Target (Current)
- Network: Unichain Sepolia
- `CHAIN_ID=1301`
- Explorer: `https://sepolia.uniscan.xyz/tx/`
- Canonical v4 PoolManager: `0x00b036b58a818b1bc34d502d3fe730db729e62ac`

Required `.env` keys:
- `RPC_URL`
- `PRIVATE_KEY`
- `CHAIN_ID`
- `EXPLORER_PREFIX`
- `POOL_MANAGER_ADDRESS` (must be canonical Unichain v4 manager)

Optional template-specific signers:
- `STABLE_PRIVATE_KEY`
- `RWA_PRIVATE_KEY`
- `LONGTAIL_PRIVATE_KEY`

Enforcement in `scripts/demo_e2e.sh` (testnet mode):
- fails if `CHAIN_ID != 1301`
- fails if RPC chain-id does not equal `CHAIN_ID`
- fails if `POOL_MANAGER_ADDRESS` is unset or has no code
- sets `REQUIRE_EXTERNAL_POOL_MANAGER=true` so Solidity scripts cannot fall back to deploying a local manager

## Persisted Deployment Metadata
After testnet runs, `scripts/demo_e2e.sh` writes deployment outputs into `.env` under:
- `TESTNET_STABLE_*`
- `TESTNET_RWA_*`
- `TESTNET_LONGTAIL_*`

These include addresses, tx hashes, and prebuilt explorer URLs for judge/demo proof.

## Deployment Registry
For concrete Unichain Sepolia deployed addresses with tx URL proofs, see:
- [deployments.md](./deployments.md)

Refresh command:
```bash
make deployments-docs
```
