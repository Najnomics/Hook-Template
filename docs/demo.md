# Demo Flows

The canonical runner is `scripts/demo_e2e.sh`.
It prints a phased workflow, per-transaction hashes, explorer URLs, and receipt-level event proof.

## Local (Anvil)
```bash
# start anvil in another terminal
anvil

# full local lifecycle broadcast for all templates
make demo-local

# single template local report from existing broadcast artifacts
bash scripts/demo_local.sh stable report
```

Defaults used in local mode:
- `RPC_URL=http://127.0.0.1:8545`
- `CHAIN_ID=31337`
- `EXPLORER_PREFIX=http://localhost:8545/tx/`

## Testnet (Unichain Sepolia)
```bash
# uses .env values (RPC_URL, PRIVATE_KEY, CHAIN_ID=1301)
make demo-testnet

# force fresh testnet broadcast for all templates
bash scripts/demo_testnet.sh all deploy

# report-only proof from latest testnet broadcast files
bash scripts/demo_testnet.sh all report
```

Testnet mode defaults:
- `RPC_URL` from `.env`
- `CHAIN_ID=1301`
- `EXPLORER_PREFIX=https://sepolia.uniscan.xyz/tx/`

## Combined
```bash
make demo-all
```

## Generate Markdown Proof Artifact
```bash
# runs report mode and writes docs/demo-proof.md
make demo-proof

# optional explicit command
bash scripts/generate_demo_report.sh testnet all report
```

## Last Demo Run Tx URLs (Explained)
From the latest Unichain Sepolia run:
- Stablecoin:
  - Hook deploy: [0xac536ceaccdd71ef5d5224c06248b0bf258220ab8557c77f7d62f571b32bb1b2](https://sepolia.uniscan.xyz/tx/0xac536ceaccdd71ef5d5224c06248b0bf258220ab8557c77f7d62f571b32bb1b2) - deploys the template hook.
  - Pool init: [0xfcf67b95035bca0349d612cb170e567a854f0bfb4a285ec8b57cfb84feb5c1bc](https://sepolia.uniscan.xyz/tx/0xfcf67b95035bca0349d612cb170e567a854f0bfb4a285ec8b57cfb84feb5c1bc) - initializes pool on canonical Uniswap PoolManager.
  - Liquidity: [0x431d9cebc3201dbc9cdba4d373d43bd2ec91ef5652ddb95551ea8e1133a69e43](https://sepolia.uniscan.xyz/tx/0x431d9cebc3201dbc9cdba4d373d43bd2ec91ef5652ddb95551ea8e1133a69e43) - seeds executable liquidity.
  - Swaps: [1](https://sepolia.uniscan.xyz/tx/0x2c88fc1df5ba3f76ca336a967f972e8b6ebb1e86b33afdb7d097da8373e44aaa), [2](https://sepolia.uniscan.xyz/tx/0xef814dcfddf1e2ff77be9333137d8ce21fa6e00233727d2ee00a2a3254cfd285), [3](https://sepolia.uniscan.xyz/tx/0x483669b7e972552c9d505b561b6f88d72d067fc6fd57f26d917b93180c9269c3) - shows guard + dynamic-fee behavior in stress path.
- RWA:
  - Hook deploy: [0xaae65100414391c4c5972caf8ff95adf78a445e34f6c935039a8b045a57f1b3f](https://sepolia.uniscan.xyz/tx/0xaae65100414391c4c5972caf8ff95adf78a445e34f6c935039a8b045a57f1b3f)
  - Allowlist setup: [0x4f16ad104ec46478f5d705e6ad669cfe3346fe643e0a488ad2f07e0fcb1b4b4a](https://sepolia.uniscan.xyz/tx/0x4f16ad104ec46478f5d705e6ad669cfe3346fe643e0a488ad2f07e0fcb1b4b4a)
  - Pool init: [0xe01c597c7261ef5a7aee1269d9beb99845a6f1ea678f4e56797c206bd947dfbe](https://sepolia.uniscan.xyz/tx/0xe01c597c7261ef5a7aee1269d9beb99845a6f1ea678f4e56797c206bd947dfbe)
  - Liquidity: [0x3f2ee21b0ca6d9ef9528b5236bc4d56411bddf1d8f07a6b78326ae2234561a62](https://sepolia.uniscan.xyz/tx/0x3f2ee21b0ca6d9ef9528b5236bc4d56411bddf1d8f07a6b78326ae2234561a62)
  - Swaps: [1](https://sepolia.uniscan.xyz/tx/0xc08201525d9825700b2c395e723ac2f7f443ab35a1d1a759686cd211ce631f1e), [2](https://sepolia.uniscan.xyz/tx/0x9b1f2ac6640ac1f8af8bef0f771e371ab6f62962e7813d5f639fdf92a602949b), [3](https://sepolia.uniscan.xyz/tx/0xb06fed9fbf5200278286a98a2bbeedf006ff696fe62b9f38d807b1a6a11de4b9) - valid allowlisted path.
- Long-Tail:
  - Hook deploy: [0xef1367e0f0bd2fa6dcc1c0c85de347da876568b2ced48fcc87ca9a374164e4ce](https://sepolia.uniscan.xyz/tx/0xef1367e0f0bd2fa6dcc1c0c85de347da876568b2ced48fcc87ca9a374164e4ce)
  - Pool init: [0xc5b2832ba9def9657f836a1d27767c04552513d8833e25dea6edbb493ba71ca1](https://sepolia.uniscan.xyz/tx/0xc5b2832ba9def9657f836a1d27767c04552513d8833e25dea6edbb493ba71ca1)
  - Liquidity: [0xd40f871a787f54768da54ba97546bfc9f2e3bd458264811be8267f30c001a50d](https://sepolia.uniscan.xyz/tx/0xd40f871a787f54768da54ba97546bfc9f2e3bd458264811be8267f30c001a50d)
  - Swaps: [1](https://sepolia.uniscan.xyz/tx/0xeaa0df6856489ee8a40be30a12016660c8682e4df0b53e5dd8afce496cb42104), [2](https://sepolia.uniscan.xyz/tx/0x9ffb38e868b799ef0da8defa655c82b6d46b6fb270a706a9ba0d9193c503fc79), [3](https://sepolia.uniscan.xyz/tx/0x3d6afd9bcab28a0188a4c33eae2c6de88ad5b0c60622ab25df6b185ff1dc47b5) - launch fee updates and mode transition proof.

For complete registry and all component addresses:
- `docs/deployments.md`
- `docs/demo-proof.md`

## Output Proof Structure
For each template, the script prints:
- workflow phases (user perspective)
- every tx hash and explorer URL
- event counts in receipts (`GuardTriggered`, `FeeUpdated`, `ModeTransitioned`, `ConfigUpdated`, `TemplateDeployed`)
- summary addresses (`PoolManager`, hook, routers, tokens)

In testnet mode, deployment metadata is persisted into `.env` as:
- `TESTNET_<TEMPLATE>_HOOK_ADDRESS`
- `TESTNET_<TEMPLATE>_POOL_MANAGER_ADDRESS`
- `TESTNET_<TEMPLATE>_HOOK_DEPLOY_TX`
- `TESTNET_<TEMPLATE>_POOL_INIT_TX`
- `TESTNET_<TEMPLATE>_SWAP_TX_1..3`
- corresponding `*_URL` fields

The generated proof file includes:
- user-perspective workflow phases
- per-template deployed addresses
- tx hash + explorer links
- receipt event counts
- full raw demo log output
