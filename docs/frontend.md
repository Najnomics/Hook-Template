# Frontend

The launcher (`/frontend`) supports:
1. template selection
2. config JSON editing
3. template deployment through `TemplateFactory`
4. pool initialization + liquidity bootstrapping
5. demo swap execution
6. execution feed with tx hash/explorer links

The frontend consumes shared artifacts from `/shared` and uses `viem` for onchain interaction.

Runtime environment variables:
- `VITE_RPC_URL`
- `VITE_CHAIN_ID` (defaults to Unichain Sepolia: `1301`)
- `VITE_EXPLORER_PREFIX`
- `VITE_TEMPLATE_FACTORY_ADDRESS`
- `VITE_POOL_MANAGER_ADDRESS`
- `VITE_LIQUIDITY_ROUTER_ADDRESS`
- `VITE_SWAP_ROUTER_ADDRESS`
- `VITE_TOKEN0_ADDRESS`
- `VITE_TOKEN1_ADDRESS`

If required addresses are missing, pool/deploy/demo actions degrade to simulated feed entries so the UI remains usable.

Run:
```bash
npm run dev --workspace frontend
```
