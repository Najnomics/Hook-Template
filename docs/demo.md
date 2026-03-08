# Demo Flows

## Local
```bash
make demo-local
```
Runs all templates on local Anvil and prints transaction hashes + local explorer-format links.

## Testnet
```bash
export RPC_URL="https://sepolia.base.org"
export PRIVATE_KEY="0x..."
make demo-testnet
```
Prints tx hashes and Base Sepolia explorer URLs from Foundry broadcast outputs.

## All
```bash
make demo-all
```
