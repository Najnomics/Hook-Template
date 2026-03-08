# Security

## Trust Model
Assumed honest:
- Uniswap v4 `PoolManager` core execution semantics

Adversarial:
- traders, searchers, and MEV actors

## Key Controls
- `onlyPoolManager` protection on hook entrypoints
- unsupported pool rejection
- admin-gated config updates with optional delay
- rate-limit, cooldown, max-trade guards
- template-specific controls (allowlist/session/launch-mode)

## Threat Coverage (non-exhaustive)
- Stablecoin depeg toxic flow: fee elevation + circuit-breaker-lite cooldown
- RWA manipulation windows: allowlist + trading session + tick/slippage bounds
- Long-tail sniping volatility: launch-mode fee/trade restrictions + per-block flow caps

## Remaining Risks
- oracle-free fee proxies rely on internal state/tick behavior
- operational risk in config misconfiguration
- off-chain automation/frontends may introduce integration risk

System is not attack-proof.
