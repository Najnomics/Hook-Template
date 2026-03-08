# Frontend

The launcher (`/frontend`) supports:
1. Template selection
2. Config JSON editing
3. Deploy step
4. Create-pool step
5. Demo-swaps step
6. Execution feed with tx hash/explorer links

The frontend consumes shared artifacts from `/shared` and uses `viem` for contract interaction.

Run:
```bash
npm run dev --workspace frontend
```
