# Contributing

## Prerequisites
- Foundry (stable)
- Node.js >= 20
- npm

## Setup
```bash
make bootstrap
npm install
```

## Development loop
```bash
forge fmt
forge test -vvv
npm run lint --workspace frontend
```

## Pull request expectations
- include tests for behavior changes
- preserve deterministic dependency strategy
- keep docs updated for new template features
- do not alter `.github/workflows` unless explicitly approved
