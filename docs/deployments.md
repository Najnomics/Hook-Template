# Deployments (Unichain Sepolia)

Network: `Unichain Sepolia`  
Chain ID: `1301`  
Explorer: `https://sepolia.uniscan.xyz/tx/`

Generated from latest broadcast artifacts.

## Stablecoin Template

Source: `broadcast/DemoStablecoin.s.sol/1301/run-latest.json`

| Component | Address | Deploy Tx |
|---|---|---|
| PoolManager (Canonical) | `0x00b036b58a818b1bc34d502d3fe730db729e62ac` | Predeployed on Unichain (external to this script run) |
| PoolSwapTest | `0xf7c25e78b9a7a74f28aaf1e28a4d85756a80576a` | [0x61f885d15f759cbd49577c1ca2d6ae712ebf0829861b536b0ce0768f02bd7427](https://sepolia.uniscan.xyz/tx/0x61f885d15f759cbd49577c1ca2d6ae712ebf0829861b536b0ce0768f02bd7427) |
| PoolModifyLiquidityTest | `0xdc56844cc6d989f318a24d0a18f2e6ce85a60198` | [0x67a9736565b20e30ef3572e40b041415cb03521356e3c47e104b5024cc36fba5](https://sepolia.uniscan.xyz/tx/0x67a9736565b20e30ef3572e40b041415cb03521356e3c47e104b5024cc36fba5) |
| MockERC20 | `0x177ffa7d583b0c200877d1bade08b062d70c19d7` | [0xdffc1abbbff51c40590c947962293888953c243ba9610bbeb573500d1c56f0f4](https://sepolia.uniscan.xyz/tx/0xdffc1abbbff51c40590c947962293888953c243ba9610bbeb573500d1c56f0f4) |
| MockERC20 | `0x1c0db6c6512933e4ea6fcbba7a94cacc842afed1` | [0x277039ec42f742b94d27a36fc38082005651cabfcea2a325ad3961847ea7a95f](https://sepolia.uniscan.xyz/tx/0x277039ec42f742b94d27a36fc38082005651cabfcea2a325ad3961847ea7a95f) |
| StablecoinTemplateHook | `0xaf3139361f74e4c46f6782eec04c766d50fc90c0` | [0xac536ceaccdd71ef5d5224c06248b0bf258220ab8557c77f7d62f571b32bb1b2](https://sepolia.uniscan.xyz/tx/0xac536ceaccdd71ef5d5224c06248b0bf258220ab8557c77f7d62f571b32bb1b2) |

Lifecycle txs:
- Pool initialize: [0xfcf67b95035bca0349d612cb170e567a854f0bfb4a285ec8b57cfb84feb5c1bc](https://sepolia.uniscan.xyz/tx/0xfcf67b95035bca0349d612cb170e567a854f0bfb4a285ec8b57cfb84feb5c1bc)
- Add liquidity: [0x431d9cebc3201dbc9cdba4d373d43bd2ec91ef5652ddb95551ea8e1133a69e43](https://sepolia.uniscan.xyz/tx/0x431d9cebc3201dbc9cdba4d373d43bd2ec91ef5652ddb95551ea8e1133a69e43)
- Swap 1: [0x2c88fc1df5ba3f76ca336a967f972e8b6ebb1e86b33afdb7d097da8373e44aaa](https://sepolia.uniscan.xyz/tx/0x2c88fc1df5ba3f76ca336a967f972e8b6ebb1e86b33afdb7d097da8373e44aaa)
- Swap 2: [0xef814dcfddf1e2ff77be9333137d8ce21fa6e00233727d2ee00a2a3254cfd285](https://sepolia.uniscan.xyz/tx/0xef814dcfddf1e2ff77be9333137d8ce21fa6e00233727d2ee00a2a3254cfd285)
- Swap 3: [0x483669b7e972552c9d505b561b6f88d72d067fc6fd57f26d917b93180c9269c3](https://sepolia.uniscan.xyz/tx/0x483669b7e972552c9d505b561b6f88d72d067fc6fd57f26d917b93180c9269c3)

## RWA Template

Source: `broadcast/DemoRWA.s.sol/1301/run-latest.json`

| Component | Address | Deploy Tx |
|---|---|---|
| PoolManager (Canonical) | `0x00b036b58a818b1bc34d502d3fe730db729e62ac` | Predeployed on Unichain (external to this script run) |
| PoolSwapTest | `0xe936e3d854ac407e2a6930f8db49ddf987db0909` | [0x771a948721428774ecff93f2daf94651c9a88919da5a931763a6f9d61a631334](https://sepolia.uniscan.xyz/tx/0x771a948721428774ecff93f2daf94651c9a88919da5a931763a6f9d61a631334) |
| PoolModifyLiquidityTest | `0xd4540f5b5a744517a92f27c4f9ae4eee875fc763` | [0xae07b20596ff1699b97f54ce2fe63753da02171ec3de3f06066a919dfaa746a3](https://sepolia.uniscan.xyz/tx/0xae07b20596ff1699b97f54ce2fe63753da02171ec3de3f06066a919dfaa746a3) |
| MockERC20 | `0xd3eeea42784d547e1e2be9c576d7e845657e1d40` | [0xfb378030e3f932f9169249f234dd214a2a01c43b2c08698c9e092289a69e27f3](https://sepolia.uniscan.xyz/tx/0xfb378030e3f932f9169249f234dd214a2a01c43b2c08698c9e092289a69e27f3) |
| MockERC20 | `0x558948122133a77e4e3c0f8eca6c0b7c97ebf0a4` | [0x2b520e1b05e74f6d828d5f2197b3c7b989af492ed5f9256817b9f770ee847dea](https://sepolia.uniscan.xyz/tx/0x2b520e1b05e74f6d828d5f2197b3c7b989af492ed5f9256817b9f770ee847dea) |
| RWATemplateHook | `0xaf24cb89bb21f57e1fa594956203ccb6c2b210c0` | [0xaae65100414391c4c5972caf8ff95adf78a445e34f6c935039a8b045a57f1b3f](https://sepolia.uniscan.xyz/tx/0xaae65100414391c4c5972caf8ff95adf78a445e34f6c935039a8b045a57f1b3f) |

Lifecycle txs:
- Hook allowlist setup: [0x4f16ad104ec46478f5d705e6ad669cfe3346fe643e0a488ad2f07e0fcb1b4b4a](https://sepolia.uniscan.xyz/tx/0x4f16ad104ec46478f5d705e6ad669cfe3346fe643e0a488ad2f07e0fcb1b4b4a)
- Pool initialize: [0xe01c597c7261ef5a7aee1269d9beb99845a6f1ea678f4e56797c206bd947dfbe](https://sepolia.uniscan.xyz/tx/0xe01c597c7261ef5a7aee1269d9beb99845a6f1ea678f4e56797c206bd947dfbe)
- Add liquidity: [0x3f2ee21b0ca6d9ef9528b5236bc4d56411bddf1d8f07a6b78326ae2234561a62](https://sepolia.uniscan.xyz/tx/0x3f2ee21b0ca6d9ef9528b5236bc4d56411bddf1d8f07a6b78326ae2234561a62)
- Swap 1: [0xc08201525d9825700b2c395e723ac2f7f443ab35a1d1a759686cd211ce631f1e](https://sepolia.uniscan.xyz/tx/0xc08201525d9825700b2c395e723ac2f7f443ab35a1d1a759686cd211ce631f1e)
- Swap 2: [0x9b1f2ac6640ac1f8af8bef0f771e371ab6f62962e7813d5f639fdf92a602949b](https://sepolia.uniscan.xyz/tx/0x9b1f2ac6640ac1f8af8bef0f771e371ab6f62962e7813d5f639fdf92a602949b)
- Swap 3: [0xb06fed9fbf5200278286a98a2bbeedf006ff696fe62b9f38d807b1a6a11de4b9](https://sepolia.uniscan.xyz/tx/0xb06fed9fbf5200278286a98a2bbeedf006ff696fe62b9f38d807b1a6a11de4b9)

## Long-Tail Template

Source: `broadcast/DemoLongTail.s.sol/1301/run-latest.json`

| Component | Address | Deploy Tx |
|---|---|---|
| PoolManager (Canonical) | `0x00b036b58a818b1bc34d502d3fe730db729e62ac` | Predeployed on Unichain (external to this script run) |
| PoolSwapTest | `0x9e50198690fdcc962874ded19316e108c0deffef` | [0xd79d36d313e6134140c5ab2117946616aa09cf16ac8d9885b3695d515bdf3cdd](https://sepolia.uniscan.xyz/tx/0xd79d36d313e6134140c5ab2117946616aa09cf16ac8d9885b3695d515bdf3cdd) |
| PoolModifyLiquidityTest | `0xb4bab86a5ad3f700791f74dfdb7a5cd8886e638a` | [0x3ac09dce15e44a0a782e022f5242681756161455b899b565c83ea5d381a2dcc0](https://sepolia.uniscan.xyz/tx/0x3ac09dce15e44a0a782e022f5242681756161455b899b565c83ea5d381a2dcc0) |
| MockERC20 | `0xac11f457544338f6c3e9759fb46e8b3b37129502` | [0xf2759e379f5f10d34aa8f360d3821966210d2af5c4eb9ab52ecb770217be1b42](https://sepolia.uniscan.xyz/tx/0xf2759e379f5f10d34aa8f360d3821966210d2af5c4eb9ab52ecb770217be1b42) |
| MockERC20 | `0x3275dc14cb72005e8c99df518772ff27357ae99c` | [0xae8893c23fbc2ccd369a86417e1c5a83f398914ff189f224ceab83900d88a5f3](https://sepolia.uniscan.xyz/tx/0xae8893c23fbc2ccd369a86417e1c5a83f398914ff189f224ceab83900d88a5f3) |
| LongTailTemplateHook | `0x7d77e422f59d7afbc0fed4e78d87d29e465e90c0` | [0xef1367e0f0bd2fa6dcc1c0c85de347da876568b2ced48fcc87ca9a374164e4ce](https://sepolia.uniscan.xyz/tx/0xef1367e0f0bd2fa6dcc1c0c85de347da876568b2ced48fcc87ca9a374164e4ce) |

Lifecycle txs:
- Pool initialize: [0xc5b2832ba9def9657f836a1d27767c04552513d8833e25dea6edbb493ba71ca1](https://sepolia.uniscan.xyz/tx/0xc5b2832ba9def9657f836a1d27767c04552513d8833e25dea6edbb493ba71ca1)
- Add liquidity: [0xd40f871a787f54768da54ba97546bfc9f2e3bd458264811be8267f30c001a50d](https://sepolia.uniscan.xyz/tx/0xd40f871a787f54768da54ba97546bfc9f2e3bd458264811be8267f30c001a50d)
- Swap 1: [0xeaa0df6856489ee8a40be30a12016660c8682e4df0b53e5dd8afce496cb42104](https://sepolia.uniscan.xyz/tx/0xeaa0df6856489ee8a40be30a12016660c8682e4df0b53e5dd8afce496cb42104)
- Swap 2: [0x9ffb38e868b799ef0da8defa655c82b6d46b6fb270a706a9ba0d9193c503fc79](https://sepolia.uniscan.xyz/tx/0x9ffb38e868b799ef0da8defa655c82b6d46b6fb270a706a9ba0d9193c503fc79)
- Swap 3: [0x3d6afd9bcab28a0188a4c33eae2c6de88ad5b0c60622ab25df6b185ff1dc47b5](https://sepolia.uniscan.xyz/tx/0x3d6afd9bcab28a0188a4c33eae2c6de88ad5b0c60622ab25df6b185ff1dc47b5)

