.PHONY: bootstrap build test coverage coverage-gate lint verify-deps verify-commits demo-local demo-testnet demo-all

bootstrap:
	bash scripts/bootstrap.sh

build:
	forge build
	npm run build --workspace frontend

test:
	forge test -vvv

coverage:
	forge coverage --report lcov

coverage-gate:
	bash scripts/coverage_gate.sh

lint:
	forge fmt --check
	npm run lint --workspace frontend

verify-deps:
	bash scripts/verify_dependencies.sh

verify-commits:
	bash scripts/verify_commits.sh

demo-local:
	bash scripts/demo_local.sh all

demo-testnet:
	bash scripts/demo_testnet.sh all

demo-all:
	bash scripts/demo_local.sh all
	bash scripts/demo_testnet.sh all
