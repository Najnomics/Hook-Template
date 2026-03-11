# Demo Proof Report

- Generated: 2026-03-11 08:50:36 UTC
- Mode: `testnet`
- Chain ID: `1301`
- RPC: `https://unichain-sepolia.g.alchemy.com/v2/I-ktCb_HQ70ydindIYbL9`
- Explorer Prefix: `https://sepolia.uniscan.xyz/tx/`
- Command: `bash scripts/generate_demo_report.sh testnet all report`

## End-to-End Workflow (User Perspective)
1. User selects template profile (Stablecoin / RWA / Long-Tail).
2. User enters market policy config (fees, guardrails, launch/session limits).
3. Runner deploys hook + execution stack and initializes liquidity on canonical PoolManager.
4. Demo swaps execute and core hook functions run (`beforeSwap`/`afterSwap`).
5. Script prints transaction hashes and explorer URLs.
6. Script inspects receipts and reports standardized event proofs.

## Deployment Summary

### Stablecoin Template
- Broadcast File: `broadcast/DemoStablecoin.s.sol/1301/run-latest.json`
- Deployer: `0x4b992f2fbf714c0fcbb23bac5130ace48cad00cd`
- PoolManager: `0x00b036b58a818b1bc34d502d3fe730db729e62ac`
- Hook: `0xaf3139361f74e4c46f6782eec04c766d50fc90c0`
- Swap Router: `0xf7c25e78b9a7a74f28aaf1e28a4d85756a80576a`
- Liquidity Router: `0xdc56844cc6d989f318a24d0a18f2e6ce85a60198`
- Token0: `0x177ffa7d583b0c200877d1bade08b062d70c19d7`
- Token1: `0x1c0db6c6512933e4ea6fcbba7a94cacc842afed1`
- Hook Deploy Tx: [0xac536ceaccdd71ef5d5224c06248b0bf258220ab8557c77f7d62f571b32bb1b2](https://sepolia.uniscan.xyz/tx/0xac536ceaccdd71ef5d5224c06248b0bf258220ab8557c77f7d62f571b32bb1b2)
- Pool Init Tx: [0xfcf67b95035bca0349d612cb170e567a854f0bfb4a285ec8b57cfb84feb5c1bc](https://sepolia.uniscan.xyz/tx/0xfcf67b95035bca0349d612cb170e567a854f0bfb4a285ec8b57cfb84feb5c1bc)
- Liquidity Tx: [0x431d9cebc3201dbc9cdba4d373d43bd2ec91ef5652ddb95551ea8e1133a69e43](https://sepolia.uniscan.xyz/tx/0x431d9cebc3201dbc9cdba4d373d43bd2ec91ef5652ddb95551ea8e1133a69e43)
- Swap Tx 1: [0x2c88fc1df5ba3f76ca336a967f972e8b6ebb1e86b33afdb7d097da8373e44aaa](https://sepolia.uniscan.xyz/tx/0x2c88fc1df5ba3f76ca336a967f972e8b6ebb1e86b33afdb7d097da8373e44aaa)
- Swap Tx 2: [0xef814dcfddf1e2ff77be9333137d8ce21fa6e00233727d2ee00a2a3254cfd285](https://sepolia.uniscan.xyz/tx/0xef814dcfddf1e2ff77be9333137d8ce21fa6e00233727d2ee00a2a3254cfd285)
- Swap Tx 3: [0x483669b7e972552c9d505b561b6f88d72d067fc6fd57f26d917b93180c9269c3](https://sepolia.uniscan.xyz/tx/0x483669b7e972552c9d505b561b6f88d72d067fc6fd57f26d917b93180c9269c3)
- Event Counts: GuardTriggered=5 FeeUpdated=1 ModeTransitioned=0 ConfigUpdated=0 TemplateDeployed=0

### RWA Template
- Broadcast File: `broadcast/DemoRWA.s.sol/1301/run-latest.json`
- Deployer: `0x6416c683636631d24ab432e109e638e91a260887`
- PoolManager: `0x00b036b58a818b1bc34d502d3fe730db729e62ac`
- Hook: `0xaf24cb89bb21f57e1fa594956203ccb6c2b210c0`
- Swap Router: `0xe936e3d854ac407e2a6930f8db49ddf987db0909`
- Liquidity Router: `0xd4540f5b5a744517a92f27c4f9ae4eee875fc763`
- Token0: `0xd3eeea42784d547e1e2be9c576d7e845657e1d40`
- Token1: `0x558948122133a77e4e3c0f8eca6c0b7c97ebf0a4`
- Hook Deploy Tx: [0xaae65100414391c4c5972caf8ff95adf78a445e34f6c935039a8b045a57f1b3f](https://sepolia.uniscan.xyz/tx/0xaae65100414391c4c5972caf8ff95adf78a445e34f6c935039a8b045a57f1b3f)
- Pool Init Tx: [0xe01c597c7261ef5a7aee1269d9beb99845a6f1ea678f4e56797c206bd947dfbe](https://sepolia.uniscan.xyz/tx/0xe01c597c7261ef5a7aee1269d9beb99845a6f1ea678f4e56797c206bd947dfbe)
- Liquidity Tx: [0x3f2ee21b0ca6d9ef9528b5236bc4d56411bddf1d8f07a6b78326ae2234561a62](https://sepolia.uniscan.xyz/tx/0x3f2ee21b0ca6d9ef9528b5236bc4d56411bddf1d8f07a6b78326ae2234561a62)
- Swap Tx 1: [0xc08201525d9825700b2c395e723ac2f7f443ab35a1d1a759686cd211ce631f1e](https://sepolia.uniscan.xyz/tx/0xc08201525d9825700b2c395e723ac2f7f443ab35a1d1a759686cd211ce631f1e)
- Swap Tx 2: [0x9b1f2ac6640ac1f8af8bef0f771e371ab6f62962e7813d5f639fdf92a602949b](https://sepolia.uniscan.xyz/tx/0x9b1f2ac6640ac1f8af8bef0f771e371ab6f62962e7813d5f639fdf92a602949b)
- Swap Tx 3: [0xb06fed9fbf5200278286a98a2bbeedf006ff696fe62b9f38d807b1a6a11de4b9](https://sepolia.uniscan.xyz/tx/0xb06fed9fbf5200278286a98a2bbeedf006ff696fe62b9f38d807b1a6a11de4b9)
- Event Counts: GuardTriggered=0 FeeUpdated=0 ModeTransitioned=0 ConfigUpdated=0 TemplateDeployed=0

### Long-Tail Template
- Broadcast File: `broadcast/DemoLongTail.s.sol/1301/run-latest.json`
- Deployer: `0x6416c683636631d24ab432e109e638e91a260887`
- PoolManager: `0x00b036b58a818b1bc34d502d3fe730db729e62ac`
- Hook: `0x7d77e422f59d7afbc0fed4e78d87d29e465e90c0`
- Swap Router: `0x9e50198690fdcc962874ded19316e108c0deffef`
- Liquidity Router: `0xb4bab86a5ad3f700791f74dfdb7a5cd8886e638a`
- Token0: `0xac11f457544338f6c3e9759fb46e8b3b37129502`
- Token1: `0x3275dc14cb72005e8c99df518772ff27357ae99c`
- Hook Deploy Tx: [0xef1367e0f0bd2fa6dcc1c0c85de347da876568b2ced48fcc87ca9a374164e4ce](https://sepolia.uniscan.xyz/tx/0xef1367e0f0bd2fa6dcc1c0c85de347da876568b2ced48fcc87ca9a374164e4ce)
- Pool Init Tx: [0xc5b2832ba9def9657f836a1d27767c04552513d8833e25dea6edbb493ba71ca1](https://sepolia.uniscan.xyz/tx/0xc5b2832ba9def9657f836a1d27767c04552513d8833e25dea6edbb493ba71ca1)
- Liquidity Tx: [0xd40f871a787f54768da54ba97546bfc9f2e3bd458264811be8267f30c001a50d](https://sepolia.uniscan.xyz/tx/0xd40f871a787f54768da54ba97546bfc9f2e3bd458264811be8267f30c001a50d)
- Swap Tx 1: [0xeaa0df6856489ee8a40be30a12016660c8682e4df0b53e5dd8afce496cb42104](https://sepolia.uniscan.xyz/tx/0xeaa0df6856489ee8a40be30a12016660c8682e4df0b53e5dd8afce496cb42104)
- Swap Tx 2: [0x9ffb38e868b799ef0da8defa655c82b6d46b6fb270a706a9ba0d9193c503fc79](https://sepolia.uniscan.xyz/tx/0x9ffb38e868b799ef0da8defa655c82b6d46b6fb270a706a9ba0d9193c503fc79)
- Swap Tx 3: [0x3d6afd9bcab28a0188a4c33eae2c6de88ad5b0c60622ab25df6b185ff1dc47b5](https://sepolia.uniscan.xyz/tx/0x3d6afd9bcab28a0188a4c33eae2c6de88ad5b0c60622ab25df6b185ff1dc47b5)
- Event Counts: GuardTriggered=0 FeeUpdated=3 ModeTransitioned=1 ConfigUpdated=0 TemplateDeployed=0

## Raw Demo Runner Output
```text
[demo-e2e] mode=testnet template=all action=report

[workflow][stable] Phase 1: user selects template and enters market policy parameters in the launcher
[workflow][stable] Phase 2: deployer provisions hook + execution stack (routers, tokens, hook) on canonical PoolManager
[workflow][stable] Phase 3: pool is initialized and seeded with liquidity
[workflow][stable] Phase 4: scripted swaps execute to trigger template-specific hook logic
[workflow][stable] Phase 5: receipts are analyzed for guard/fee/mode events and tx proofs
[workflow][stable] mode=testnet action=report rpc=https://unichain-sepolia.g.alchemy.com/v2/I-ktCb_HQ70ydindIYbL9 chain=1301
[tx-report][stable] file=broadcast/DemoStablecoin.s.sol/1301/run-latest.json chain=1301 tx_count=16
[tx-report][stable] nonce=0x285 type=CREATE contract=PoolSwapTest function=-
[tx-report][stable]   contractAddress=0xf7c25e78b9a7a74f28aaf1e28a4d85756a80576a
[tx-report][stable]   tx=0x61f885d15f759cbd49577c1ca2d6ae712ebf0829861b536b0ce0768f02bd7427
[tx-report][stable]   explorer=https://sepolia.uniscan.xyz/tx/0x61f885d15f759cbd49577c1ca2d6ae712ebf0829861b536b0ce0768f02bd7427
[tx-report][stable] nonce=0x286 type=CREATE contract=PoolModifyLiquidityTest function=-
[tx-report][stable]   contractAddress=0xdc56844cc6d989f318a24d0a18f2e6ce85a60198
[tx-report][stable]   tx=0x67a9736565b20e30ef3572e40b041415cb03521356e3c47e104b5024cc36fba5
[tx-report][stable]   explorer=https://sepolia.uniscan.xyz/tx/0x67a9736565b20e30ef3572e40b041415cb03521356e3c47e104b5024cc36fba5
[tx-report][stable] nonce=0x287 type=CREATE contract=MockERC20 function=-
[tx-report][stable]   contractAddress=0x177ffa7d583b0c200877d1bade08b062d70c19d7
[tx-report][stable]   tx=0xdffc1abbbff51c40590c947962293888953c243ba9610bbeb573500d1c56f0f4
[tx-report][stable]   explorer=https://sepolia.uniscan.xyz/tx/0xdffc1abbbff51c40590c947962293888953c243ba9610bbeb573500d1c56f0f4
[tx-report][stable] nonce=0x288 type=CREATE contract=MockERC20 function=-
[tx-report][stable]   contractAddress=0x1c0db6c6512933e4ea6fcbba7a94cacc842afed1
[tx-report][stable]   tx=0x277039ec42f742b94d27a36fc38082005651cabfcea2a325ad3961847ea7a95f
[tx-report][stable]   explorer=https://sepolia.uniscan.xyz/tx/0x277039ec42f742b94d27a36fc38082005651cabfcea2a325ad3961847ea7a95f
[tx-report][stable] nonce=0x289 type=CALL contract=MockERC20 function=mint(address,uint256)
[tx-report][stable]   contractAddress=0x177ffa7d583b0c200877d1bade08b062d70c19d7
[tx-report][stable]   tx=0x59d04094cd11423c37e8f2f805bb12c86e984bf6ffb2c809182e6a795de00338
[tx-report][stable]   explorer=https://sepolia.uniscan.xyz/tx/0x59d04094cd11423c37e8f2f805bb12c86e984bf6ffb2c809182e6a795de00338
[tx-report][stable] nonce=0x28a type=CALL contract=MockERC20 function=mint(address,uint256)
[tx-report][stable]   contractAddress=0x1c0db6c6512933e4ea6fcbba7a94cacc842afed1
[tx-report][stable]   tx=0x7d47d993444f2a336d608ef830aee342d452eae743c06543ce61e874bc2bdce4
[tx-report][stable]   explorer=https://sepolia.uniscan.xyz/tx/0x7d47d993444f2a336d608ef830aee342d452eae743c06543ce61e874bc2bdce4
[tx-report][stable] nonce=0x28b type=CALL contract=MockERC20 function=approve(address,uint256)
[tx-report][stable]   contractAddress=0x177ffa7d583b0c200877d1bade08b062d70c19d7
[tx-report][stable]   tx=0x951ecdb8da94470957b25173b0f10fb899b27cee80836fd6c01aafb1b2ffb5d5
[tx-report][stable]   explorer=https://sepolia.uniscan.xyz/tx/0x951ecdb8da94470957b25173b0f10fb899b27cee80836fd6c01aafb1b2ffb5d5
[tx-report][stable] nonce=0x28c type=CALL contract=MockERC20 function=approve(address,uint256)
[tx-report][stable]   contractAddress=0x1c0db6c6512933e4ea6fcbba7a94cacc842afed1
[tx-report][stable]   tx=0x5fec2a8f4a7da98bc391746fbe7bcbc8d53b4fbd2dc6e5013dc6e3cfbf6f0f0b
[tx-report][stable]   explorer=https://sepolia.uniscan.xyz/tx/0x5fec2a8f4a7da98bc391746fbe7bcbc8d53b4fbd2dc6e5013dc6e3cfbf6f0f0b
[tx-report][stable] nonce=0x28d type=CALL contract=MockERC20 function=approve(address,uint256)
[tx-report][stable]   contractAddress=0x177ffa7d583b0c200877d1bade08b062d70c19d7
[tx-report][stable]   tx=0xd0405fafaccb78f7afd8959b6f51f8897f27d4661a58645999a0e6b148717d9f
[tx-report][stable]   explorer=https://sepolia.uniscan.xyz/tx/0xd0405fafaccb78f7afd8959b6f51f8897f27d4661a58645999a0e6b148717d9f
[tx-report][stable] nonce=0x28e type=CALL contract=MockERC20 function=approve(address,uint256)
[tx-report][stable]   contractAddress=0x1c0db6c6512933e4ea6fcbba7a94cacc842afed1
[tx-report][stable]   tx=0x532074d5db11d33730ca8b2f61e0e36960bfee07d2063867083f7a10b942649d
[tx-report][stable]   explorer=https://sepolia.uniscan.xyz/tx/0x532074d5db11d33730ca8b2f61e0e36960bfee07d2063867083f7a10b942649d
[tx-report][stable] nonce=0x28f type=CREATE2 contract=StablecoinTemplateHook function=-
[tx-report][stable]   contractAddress=0xaf3139361f74e4c46f6782eec04c766d50fc90c0
[tx-report][stable]   tx=0xac536ceaccdd71ef5d5224c06248b0bf258220ab8557c77f7d62f571b32bb1b2
[tx-report][stable]   explorer=https://sepolia.uniscan.xyz/tx/0xac536ceaccdd71ef5d5224c06248b0bf258220ab8557c77f7d62f571b32bb1b2
[tx-report][stable] nonce=0x290 type=CALL contract=- function=initialize((address,address,uint24,int24,address),uint160)
[tx-report][stable]   contractAddress=0x00b036b58a818b1bc34d502d3fe730db729e62ac
[tx-report][stable]   tx=0xfcf67b95035bca0349d612cb170e567a854f0bfb4a285ec8b57cfb84feb5c1bc
[tx-report][stable]   explorer=https://sepolia.uniscan.xyz/tx/0xfcf67b95035bca0349d612cb170e567a854f0bfb4a285ec8b57cfb84feb5c1bc
[tx-report][stable] nonce=0x291 type=CALL contract=PoolModifyLiquidityTest function=modifyLiquidity((address,address,uint24,int24,address),(int24,int24,int256,bytes32),bytes)
[tx-report][stable]   contractAddress=0xdc56844cc6d989f318a24d0a18f2e6ce85a60198
[tx-report][stable]   tx=0x431d9cebc3201dbc9cdba4d373d43bd2ec91ef5652ddb95551ea8e1133a69e43
[tx-report][stable]   explorer=https://sepolia.uniscan.xyz/tx/0x431d9cebc3201dbc9cdba4d373d43bd2ec91ef5652ddb95551ea8e1133a69e43
[tx-report][stable] nonce=0x292 type=CALL contract=PoolSwapTest function=swap((address,address,uint24,int24,address),(bool,int256,uint160),(bool,bool),bytes)
[tx-report][stable]   contractAddress=0xf7c25e78b9a7a74f28aaf1e28a4d85756a80576a
[tx-report][stable]   tx=0x2c88fc1df5ba3f76ca336a967f972e8b6ebb1e86b33afdb7d097da8373e44aaa
[tx-report][stable]   explorer=https://sepolia.uniscan.xyz/tx/0x2c88fc1df5ba3f76ca336a967f972e8b6ebb1e86b33afdb7d097da8373e44aaa
[tx-report][stable] nonce=0x293 type=CALL contract=PoolSwapTest function=swap((address,address,uint24,int24,address),(bool,int256,uint160),(bool,bool),bytes)
[tx-report][stable]   contractAddress=0xf7c25e78b9a7a74f28aaf1e28a4d85756a80576a
[tx-report][stable]   tx=0xef814dcfddf1e2ff77be9333137d8ce21fa6e00233727d2ee00a2a3254cfd285
[tx-report][stable]   explorer=https://sepolia.uniscan.xyz/tx/0xef814dcfddf1e2ff77be9333137d8ce21fa6e00233727d2ee00a2a3254cfd285
[tx-report][stable] nonce=0x294 type=CALL contract=PoolSwapTest function=swap((address,address,uint24,int24,address),(bool,int256,uint160),(bool,bool),bytes)
[tx-report][stable]   contractAddress=0xf7c25e78b9a7a74f28aaf1e28a4d85756a80576a
[tx-report][stable]   tx=0x483669b7e972552c9d505b561b6f88d72d067fc6fd57f26d917b93180c9269c3
[tx-report][stable]   explorer=https://sepolia.uniscan.xyz/tx/0x483669b7e972552c9d505b561b6f88d72d067fc6fd57f26d917b93180c9269c3
[events][stable] GuardTriggered=5 FeeUpdated=1 ModeTransitioned=0 ConfigUpdated=0 TemplateDeployed=0
[events][stable] guardTx=0x483669b7e972552c9d505b561b6f88d72d067fc6fd57f26d917b93180c9269c3 url=https://sepolia.uniscan.xyz/tx/0x483669b7e972552c9d505b561b6f88d72d067fc6fd57f26d917b93180c9269c3
[events][stable] guardTx=0xef814dcfddf1e2ff77be9333137d8ce21fa6e00233727d2ee00a2a3254cfd285 url=https://sepolia.uniscan.xyz/tx/0xef814dcfddf1e2ff77be9333137d8ce21fa6e00233727d2ee00a2a3254cfd285
[summary][stable] deployer=0x4b992f2fbf714c0fcbb23bac5130ace48cad00cd poolManager=0x00b036b58a818b1bc34d502d3fe730db729e62ac hook=0xaf3139361f74e4c46f6782eec04c766d50fc90c0
[summary][stable] hookDeployTx=0xac536ceaccdd71ef5d5224c06248b0bf258220ab8557c77f7d62f571b32bb1b2

[workflow][rwa] Phase 1: user selects template and enters market policy parameters in the launcher
[workflow][rwa] Phase 2: deployer provisions hook + execution stack (routers, tokens, hook) on canonical PoolManager
[workflow][rwa] Phase 3: pool is initialized and seeded with liquidity
[workflow][rwa] Phase 4: scripted swaps execute to trigger template-specific hook logic
[workflow][rwa] Phase 5: receipts are analyzed for guard/fee/mode events and tx proofs
[workflow][rwa] mode=testnet action=report rpc=https://unichain-sepolia.g.alchemy.com/v2/I-ktCb_HQ70ydindIYbL9 chain=1301
[tx-report][rwa] file=broadcast/DemoRWA.s.sol/1301/run-latest.json chain=1301 tx_count=17
[tx-report][rwa] nonce=0x44 type=CREATE contract=PoolSwapTest function=-
[tx-report][rwa]   contractAddress=0xe936e3d854ac407e2a6930f8db49ddf987db0909
[tx-report][rwa]   tx=0x771a948721428774ecff93f2daf94651c9a88919da5a931763a6f9d61a631334
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0x771a948721428774ecff93f2daf94651c9a88919da5a931763a6f9d61a631334
[tx-report][rwa] nonce=0x45 type=CREATE contract=PoolModifyLiquidityTest function=-
[tx-report][rwa]   contractAddress=0xd4540f5b5a744517a92f27c4f9ae4eee875fc763
[tx-report][rwa]   tx=0xae07b20596ff1699b97f54ce2fe63753da02171ec3de3f06066a919dfaa746a3
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0xae07b20596ff1699b97f54ce2fe63753da02171ec3de3f06066a919dfaa746a3
[tx-report][rwa] nonce=0x46 type=CREATE contract=MockERC20 function=-
[tx-report][rwa]   contractAddress=0xd3eeea42784d547e1e2be9c576d7e845657e1d40
[tx-report][rwa]   tx=0xfb378030e3f932f9169249f234dd214a2a01c43b2c08698c9e092289a69e27f3
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0xfb378030e3f932f9169249f234dd214a2a01c43b2c08698c9e092289a69e27f3
[tx-report][rwa] nonce=0x47 type=CREATE contract=MockERC20 function=-
[tx-report][rwa]   contractAddress=0x558948122133a77e4e3c0f8eca6c0b7c97ebf0a4
[tx-report][rwa]   tx=0x2b520e1b05e74f6d828d5f2197b3c7b989af492ed5f9256817b9f770ee847dea
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0x2b520e1b05e74f6d828d5f2197b3c7b989af492ed5f9256817b9f770ee847dea
[tx-report][rwa] nonce=0x48 type=CALL contract=MockERC20 function=mint(address,uint256)
[tx-report][rwa]   contractAddress=0x558948122133a77e4e3c0f8eca6c0b7c97ebf0a4
[tx-report][rwa]   tx=0xfdcbf73c81a3986e80d6d3975701a8e1b5c04e4b81f9aa60f46cf9c13b48ee61
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0xfdcbf73c81a3986e80d6d3975701a8e1b5c04e4b81f9aa60f46cf9c13b48ee61
[tx-report][rwa] nonce=0x49 type=CALL contract=MockERC20 function=mint(address,uint256)
[tx-report][rwa]   contractAddress=0xd3eeea42784d547e1e2be9c576d7e845657e1d40
[tx-report][rwa]   tx=0x67f90240b7b489afdd43e1082e3502db156e7cfad2411be3b9bead24460db745
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0x67f90240b7b489afdd43e1082e3502db156e7cfad2411be3b9bead24460db745
[tx-report][rwa] nonce=0x4a type=CALL contract=MockERC20 function=approve(address,uint256)
[tx-report][rwa]   contractAddress=0x558948122133a77e4e3c0f8eca6c0b7c97ebf0a4
[tx-report][rwa]   tx=0xcd8eb19ace51ffe60b7d8eb296c66cdb913d7f2b5a14bfeb8f9cc23b9218b198
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0xcd8eb19ace51ffe60b7d8eb296c66cdb913d7f2b5a14bfeb8f9cc23b9218b198
[tx-report][rwa] nonce=0x4b type=CALL contract=MockERC20 function=approve(address,uint256)
[tx-report][rwa]   contractAddress=0xd3eeea42784d547e1e2be9c576d7e845657e1d40
[tx-report][rwa]   tx=0xcd1db52831f1373e95d958bedd5f88ed4166ce2628b464e9bc73b0e7d718cc90
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0xcd1db52831f1373e95d958bedd5f88ed4166ce2628b464e9bc73b0e7d718cc90
[tx-report][rwa] nonce=0x4c type=CALL contract=MockERC20 function=approve(address,uint256)
[tx-report][rwa]   contractAddress=0x558948122133a77e4e3c0f8eca6c0b7c97ebf0a4
[tx-report][rwa]   tx=0x610b3a69367474497435fa664a598aa895de54486d04d896a73cae18619fe2fd
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0x610b3a69367474497435fa664a598aa895de54486d04d896a73cae18619fe2fd
[tx-report][rwa] nonce=0x4d type=CALL contract=MockERC20 function=approve(address,uint256)
[tx-report][rwa]   contractAddress=0xd3eeea42784d547e1e2be9c576d7e845657e1d40
[tx-report][rwa]   tx=0x328740b8e882486afc39bd83cabac558b1e04542b453f9f675a05b7531e55dd1
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0x328740b8e882486afc39bd83cabac558b1e04542b453f9f675a05b7531e55dd1
[tx-report][rwa] nonce=0x4e type=CREATE2 contract=RWATemplateHook function=-
[tx-report][rwa]   contractAddress=0xaf24cb89bb21f57e1fa594956203ccb6c2b210c0
[tx-report][rwa]   tx=0xaae65100414391c4c5972caf8ff95adf78a445e34f6c935039a8b045a57f1b3f
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0xaae65100414391c4c5972caf8ff95adf78a445e34f6c935039a8b045a57f1b3f
[tx-report][rwa] nonce=0x4f type=CALL contract=RWATemplateHook function=setAllowlist(address[],bool)
[tx-report][rwa]   contractAddress=0xaf24cb89bb21f57e1fa594956203ccb6c2b210c0
[tx-report][rwa]   tx=0x4f16ad104ec46478f5d705e6ad669cfe3346fe643e0a488ad2f07e0fcb1b4b4a
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0x4f16ad104ec46478f5d705e6ad669cfe3346fe643e0a488ad2f07e0fcb1b4b4a
[tx-report][rwa] nonce=0x50 type=CALL contract=- function=initialize((address,address,uint24,int24,address),uint160)
[tx-report][rwa]   contractAddress=0x00b036b58a818b1bc34d502d3fe730db729e62ac
[tx-report][rwa]   tx=0xe01c597c7261ef5a7aee1269d9beb99845a6f1ea678f4e56797c206bd947dfbe
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0xe01c597c7261ef5a7aee1269d9beb99845a6f1ea678f4e56797c206bd947dfbe
[tx-report][rwa] nonce=0x51 type=CALL contract=PoolModifyLiquidityTest function=modifyLiquidity((address,address,uint24,int24,address),(int24,int24,int256,bytes32),bytes)
[tx-report][rwa]   contractAddress=0xd4540f5b5a744517a92f27c4f9ae4eee875fc763
[tx-report][rwa]   tx=0x3f2ee21b0ca6d9ef9528b5236bc4d56411bddf1d8f07a6b78326ae2234561a62
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0x3f2ee21b0ca6d9ef9528b5236bc4d56411bddf1d8f07a6b78326ae2234561a62
[tx-report][rwa] nonce=0x52 type=CALL contract=PoolSwapTest function=swap((address,address,uint24,int24,address),(bool,int256,uint160),(bool,bool),bytes)
[tx-report][rwa]   contractAddress=0xe936e3d854ac407e2a6930f8db49ddf987db0909
[tx-report][rwa]   tx=0xc08201525d9825700b2c395e723ac2f7f443ab35a1d1a759686cd211ce631f1e
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0xc08201525d9825700b2c395e723ac2f7f443ab35a1d1a759686cd211ce631f1e
[tx-report][rwa] nonce=0x53 type=CALL contract=PoolSwapTest function=swap((address,address,uint24,int24,address),(bool,int256,uint160),(bool,bool),bytes)
[tx-report][rwa]   contractAddress=0xe936e3d854ac407e2a6930f8db49ddf987db0909
[tx-report][rwa]   tx=0x9b1f2ac6640ac1f8af8bef0f771e371ab6f62962e7813d5f639fdf92a602949b
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0x9b1f2ac6640ac1f8af8bef0f771e371ab6f62962e7813d5f639fdf92a602949b
[tx-report][rwa] nonce=0x54 type=CALL contract=PoolSwapTest function=swap((address,address,uint24,int24,address),(bool,int256,uint160),(bool,bool),bytes)
[tx-report][rwa]   contractAddress=0xe936e3d854ac407e2a6930f8db49ddf987db0909
[tx-report][rwa]   tx=0xb06fed9fbf5200278286a98a2bbeedf006ff696fe62b9f38d807b1a6a11de4b9
[tx-report][rwa]   explorer=https://sepolia.uniscan.xyz/tx/0xb06fed9fbf5200278286a98a2bbeedf006ff696fe62b9f38d807b1a6a11de4b9
[events][rwa] GuardTriggered=0 FeeUpdated=0 ModeTransitioned=0 ConfigUpdated=0 TemplateDeployed=0
[summary][rwa] deployer=0x6416c683636631d24ab432e109e638e91a260887 poolManager=0x00b036b58a818b1bc34d502d3fe730db729e62ac hook=0xaf24cb89bb21f57e1fa594956203ccb6c2b210c0
[summary][rwa] hookDeployTx=0xaae65100414391c4c5972caf8ff95adf78a445e34f6c935039a8b045a57f1b3f

[workflow][longtail] Phase 1: user selects template and enters market policy parameters in the launcher
[workflow][longtail] Phase 2: deployer provisions hook + execution stack (routers, tokens, hook) on canonical PoolManager
[workflow][longtail] Phase 3: pool is initialized and seeded with liquidity
[workflow][longtail] Phase 4: scripted swaps execute to trigger template-specific hook logic
[workflow][longtail] Phase 5: receipts are analyzed for guard/fee/mode events and tx proofs
[workflow][longtail] mode=testnet action=report rpc=https://unichain-sepolia.g.alchemy.com/v2/I-ktCb_HQ70ydindIYbL9 chain=1301
[tx-report][longtail] file=broadcast/DemoLongTail.s.sol/1301/run-latest.json chain=1301 tx_count=16
[tx-report][longtail] nonce=0x55 type=CREATE contract=PoolSwapTest function=-
[tx-report][longtail]   contractAddress=0x9e50198690fdcc962874ded19316e108c0deffef
[tx-report][longtail]   tx=0xd79d36d313e6134140c5ab2117946616aa09cf16ac8d9885b3695d515bdf3cdd
[tx-report][longtail]   explorer=https://sepolia.uniscan.xyz/tx/0xd79d36d313e6134140c5ab2117946616aa09cf16ac8d9885b3695d515bdf3cdd
[tx-report][longtail] nonce=0x56 type=CREATE contract=PoolModifyLiquidityTest function=-
[tx-report][longtail]   contractAddress=0xb4bab86a5ad3f700791f74dfdb7a5cd8886e638a
[tx-report][longtail]   tx=0x3ac09dce15e44a0a782e022f5242681756161455b899b565c83ea5d381a2dcc0
[tx-report][longtail]   explorer=https://sepolia.uniscan.xyz/tx/0x3ac09dce15e44a0a782e022f5242681756161455b899b565c83ea5d381a2dcc0
[tx-report][longtail] nonce=0x57 type=CREATE contract=MockERC20 function=-
[tx-report][longtail]   contractAddress=0xac11f457544338f6c3e9759fb46e8b3b37129502
[tx-report][longtail]   tx=0xf2759e379f5f10d34aa8f360d3821966210d2af5c4eb9ab52ecb770217be1b42
[tx-report][longtail]   explorer=https://sepolia.uniscan.xyz/tx/0xf2759e379f5f10d34aa8f360d3821966210d2af5c4eb9ab52ecb770217be1b42
[tx-report][longtail] nonce=0x58 type=CREATE contract=MockERC20 function=-
[tx-report][longtail]   contractAddress=0x3275dc14cb72005e8c99df518772ff27357ae99c
[tx-report][longtail]   tx=0xae8893c23fbc2ccd369a86417e1c5a83f398914ff189f224ceab83900d88a5f3
[tx-report][longtail]   explorer=https://sepolia.uniscan.xyz/tx/0xae8893c23fbc2ccd369a86417e1c5a83f398914ff189f224ceab83900d88a5f3
[tx-report][longtail] nonce=0x59 type=CALL contract=MockERC20 function=mint(address,uint256)
[tx-report][longtail]   contractAddress=0x3275dc14cb72005e8c99df518772ff27357ae99c
[tx-report][longtail]   tx=0x5c0e429f8815289da5f4430057eb6bfa2578605868a0127209146c0358953b47
[tx-report][longtail]   explorer=https://sepolia.uniscan.xyz/tx/0x5c0e429f8815289da5f4430057eb6bfa2578605868a0127209146c0358953b47
[tx-report][longtail] nonce=0x5a type=CALL contract=MockERC20 function=mint(address,uint256)
[tx-report][longtail]   contractAddress=0xac11f457544338f6c3e9759fb46e8b3b37129502
[tx-report][longtail]   tx=0x9bd40c8bd499260cf4a8b994ee295ff8aa01a139c5b080e769f397b3ba7fec7c
[tx-report][longtail]   explorer=https://sepolia.uniscan.xyz/tx/0x9bd40c8bd499260cf4a8b994ee295ff8aa01a139c5b080e769f397b3ba7fec7c
[tx-report][longtail] nonce=0x5b type=CALL contract=MockERC20 function=approve(address,uint256)
[tx-report][longtail]   contractAddress=0x3275dc14cb72005e8c99df518772ff27357ae99c
[tx-report][longtail]   tx=0x73160e5190ae98a3bc73dc1ecedde88b9a2caef3a6f1ccc2b3d6bcbd3da0a799
[tx-report][longtail]   explorer=https://sepolia.uniscan.xyz/tx/0x73160e5190ae98a3bc73dc1ecedde88b9a2caef3a6f1ccc2b3d6bcbd3da0a799
[tx-report][longtail] nonce=0x5c type=CALL contract=MockERC20 function=approve(address,uint256)
[tx-report][longtail]   contractAddress=0xac11f457544338f6c3e9759fb46e8b3b37129502
[tx-report][longtail]   tx=0x8478cc5f0ea942baa7ec7d7f7eb58b50a94b3aac382cf3e3632ea07dadeb43cb
[tx-report][longtail]   explorer=https://sepolia.uniscan.xyz/tx/0x8478cc5f0ea942baa7ec7d7f7eb58b50a94b3aac382cf3e3632ea07dadeb43cb
[tx-report][longtail] nonce=0x5d type=CALL contract=MockERC20 function=approve(address,uint256)
[tx-report][longtail]   contractAddress=0x3275dc14cb72005e8c99df518772ff27357ae99c
[tx-report][longtail]   tx=0xe3d7f9fa0128b916209fe1a0418c7b623366407cdacd3667dcbddb525df34f74
[tx-report][longtail]   explorer=https://sepolia.uniscan.xyz/tx/0xe3d7f9fa0128b916209fe1a0418c7b623366407cdacd3667dcbddb525df34f74
[tx-report][longtail] nonce=0x5e type=CALL contract=MockERC20 function=approve(address,uint256)
[tx-report][longtail]   contractAddress=0xac11f457544338f6c3e9759fb46e8b3b37129502
[tx-report][longtail]   tx=0x1b80f2e9d122904cb6fe554042880a2ec2771dea4a0a05337ce53d92c44ba0c1
[tx-report][longtail]   explorer=https://sepolia.uniscan.xyz/tx/0x1b80f2e9d122904cb6fe554042880a2ec2771dea4a0a05337ce53d92c44ba0c1
[tx-report][longtail] nonce=0x5f type=CREATE2 contract=LongTailTemplateHook function=-
[tx-report][longtail]   contractAddress=0x7d77e422f59d7afbc0fed4e78d87d29e465e90c0
[tx-report][longtail]   tx=0xef1367e0f0bd2fa6dcc1c0c85de347da876568b2ced48fcc87ca9a374164e4ce
[tx-report][longtail]   explorer=https://sepolia.uniscan.xyz/tx/0xef1367e0f0bd2fa6dcc1c0c85de347da876568b2ced48fcc87ca9a374164e4ce
[tx-report][longtail] nonce=0x60 type=CALL contract=- function=initialize((address,address,uint24,int24,address),uint160)
[tx-report][longtail]   contractAddress=0x00b036b58a818b1bc34d502d3fe730db729e62ac
[tx-report][longtail]   tx=0xc5b2832ba9def9657f836a1d27767c04552513d8833e25dea6edbb493ba71ca1
[tx-report][longtail]   explorer=https://sepolia.uniscan.xyz/tx/0xc5b2832ba9def9657f836a1d27767c04552513d8833e25dea6edbb493ba71ca1
[tx-report][longtail] nonce=0x61 type=CALL contract=PoolModifyLiquidityTest function=modifyLiquidity((address,address,uint24,int24,address),(int24,int24,int256,bytes32),bytes)
[tx-report][longtail]   contractAddress=0xb4bab86a5ad3f700791f74dfdb7a5cd8886e638a
[tx-report][longtail]   tx=0xd40f871a787f54768da54ba97546bfc9f2e3bd458264811be8267f30c001a50d
[tx-report][longtail]   explorer=https://sepolia.uniscan.xyz/tx/0xd40f871a787f54768da54ba97546bfc9f2e3bd458264811be8267f30c001a50d
[tx-report][longtail] nonce=0x62 type=CALL contract=PoolSwapTest function=swap((address,address,uint24,int24,address),(bool,int256,uint160),(bool,bool),bytes)
[tx-report][longtail]   contractAddress=0x9e50198690fdcc962874ded19316e108c0deffef
[tx-report][longtail]   tx=0xeaa0df6856489ee8a40be30a12016660c8682e4df0b53e5dd8afce496cb42104
[tx-report][longtail]   explorer=https://sepolia.uniscan.xyz/tx/0xeaa0df6856489ee8a40be30a12016660c8682e4df0b53e5dd8afce496cb42104
[tx-report][longtail] nonce=0x63 type=CALL contract=PoolSwapTest function=swap((address,address,uint24,int24,address),(bool,int256,uint160),(bool,bool),bytes)
[tx-report][longtail]   contractAddress=0x9e50198690fdcc962874ded19316e108c0deffef
[tx-report][longtail]   tx=0x9ffb38e868b799ef0da8defa655c82b6d46b6fb270a706a9ba0d9193c503fc79
[tx-report][longtail]   explorer=https://sepolia.uniscan.xyz/tx/0x9ffb38e868b799ef0da8defa655c82b6d46b6fb270a706a9ba0d9193c503fc79
[tx-report][longtail] nonce=0x64 type=CALL contract=PoolSwapTest function=swap((address,address,uint24,int24,address),(bool,int256,uint160),(bool,bool),bytes)
[tx-report][longtail]   contractAddress=0x9e50198690fdcc962874ded19316e108c0deffef
[tx-report][longtail]   tx=0x3d6afd9bcab28a0188a4c33eae2c6de88ad5b0c60622ab25df6b185ff1dc47b5
[tx-report][longtail]   explorer=https://sepolia.uniscan.xyz/tx/0x3d6afd9bcab28a0188a4c33eae2c6de88ad5b0c60622ab25df6b185ff1dc47b5
[events][longtail] GuardTriggered=0 FeeUpdated=3 ModeTransitioned=1 ConfigUpdated=0 TemplateDeployed=0
[summary][longtail] deployer=0x6416c683636631d24ab432e109e638e91a260887 poolManager=0x00b036b58a818b1bc34d502d3fe730db729e62ac hook=0x7d77e422f59d7afbc0fed4e78d87d29e465e90c0
[summary][longtail] hookDeployTx=0xef1367e0f0bd2fa6dcc1c0c85de347da876568b2ced48fcc87ca9a374164e4ce

[demo-e2e] complete
[demo-e2e] persisted testnet deployment metadata to .env
```
