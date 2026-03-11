# Testing

## Run Tests
```bash
FOUNDRY_OFFLINE=true forge test -vvv
```

## Coverage
```bash
FOUNDRY_OFFLINE=true forge coverage --report lcov
```

## Coverage Gate
```bash
make coverage-gate
```

Current enforced gate:
- production-contract line coverage `>= 100%`
- excludes `test/` and `script/` from gate scope

Example gate output:
```text
[coverage-gate] OK: line coverage 100.00% >= threshold 100%
```

Note:
- `scripts/coverage_gate.sh` defaults to `FOUNDRY_OFFLINE=true` for deterministic behavior on environments where online signature lookup may panic.

## Included Test Categories
- Unit tests per template and framework components.
- Edge case tests:
  - zero/near-zero liquidity handling
  - extreme movement behavior
  - repeated swap/rate-limit enforcement
  - max trade-size boundaries
  - unauthorized config changes
  - permission and supported-pool mismatch behavior
  - event/topic correctness
- Fuzz/invariant tests:
  - guard rejection properties
  - config invariants
  - transition invariants
- Integration lifecycle tests:
  - deploy, initialize, add liquidity, swap, and hook logic execution.
