# Template Authoring Guide

## 1) Start from BaseTemplateHook
Implement a new template by inheriting `BaseTemplateHook` and using:
- `_sharedBeforeSwap`
- `_sharedAfterSwap`
- `_assertSupportedPool`
- `_lpFeeOverride`

## 2) Define config and validation
- Add a strongly-typed config struct in `TemplateTypes.sol`.
- Validate constructor config and update config paths.
- Keep update flow admin-gated and delay-aware.

## 3) Choose hook permissions deliberately
Current templates use:
- `afterInitialize`
- `beforeSwap`
- `afterSwap`

Ensure the deployed hook address bits exactly match your selected permissions.

## 4) Keep hooks minimal
- Avoid external calls in hot paths.
- Reuse shared guard logic.
- Emit standardized events for telemetry.

## 5) Test expectations
Add:
- unit behavior tests
- edge tests for guardrails/access control
- fuzz tests for invariants
- integration lifecycle flow tests
