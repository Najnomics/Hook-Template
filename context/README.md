# Context Sources

The requested `/context/uniswap/**` and `/context/atrium/**` source bundles were not available in this workspace at implementation time.

Assumptions were made using:
- pinned local `lib/v4-core`
- pinned local `lib/v4-periphery` at commit `3779387e5d296f39df543d23524b050f89a62917`

If the original context pack is later added, re-run:

```bash
make verify-deps
forge test -vvv
```
