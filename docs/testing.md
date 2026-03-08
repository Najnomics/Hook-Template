# Testing

Run all Solidity tests:
```bash
forge test -vvv
```

Coverage:
```bash
forge coverage --report lcov
```

Included suites:
- unit tests per template
- edge-case tests (zero liquidity, rate limits, max trade bounds, permission mismatch, unauthorized updates, event checks)
- fuzz/invariant-oriented tests
- integration lifecycle tests on local manager+routers
