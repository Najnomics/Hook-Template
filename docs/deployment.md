# Deployment

## Deterministic bootstrap
```bash
make bootstrap
make verify-deps
```

## Deploy factory
```bash
forge script script/DeployTemplateFactory.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
```

## Deploy template demos
```bash
forge script script/DemoStablecoin.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
forge script script/DemoRWA.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
forge script script/DemoLongTail.s.sol --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
```

## Base Sepolia
Set:
- `RPC_URL=https://sepolia.base.org`
- `CHAIN_ID=84532`
- `EXPLORER_PREFIX=https://sepolia.basescan.org/tx/`
