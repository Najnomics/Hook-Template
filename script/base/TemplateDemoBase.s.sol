// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {PoolManager} from "@uniswap/v4-core/src/PoolManager.sol";
import {PoolSwapTest} from "@uniswap/v4-core/src/test/PoolSwapTest.sol";
import {PoolModifyLiquidityTest} from "@uniswap/v4-core/src/test/PoolModifyLiquidityTest.sol";
import {HookMiner} from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {ModifyLiquidityParams, SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {Constants} from "@uniswap/v4-core/test/utils/Constants.sol";

abstract contract TemplateDemoBase is Script {
    uint160 internal constant TEMPLATE_FLAGS =
        Hooks.AFTER_INITIALIZE_FLAG | Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG;
    address internal constant CREATE2_DEPLOYER = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    struct DemoStack {
        PoolManager manager;
        PoolSwapTest swapRouter;
        PoolModifyLiquidityTest liquidityRouter;
        MockERC20 token0;
        MockERC20 token1;
        PoolKey poolKey;
    }

    function _deployCore(address trader) internal returns (DemoStack memory stack) {
        stack.manager = new PoolManager(trader);
        stack.swapRouter = new PoolSwapTest(stack.manager);
        stack.liquidityRouter = new PoolModifyLiquidityTest(stack.manager);

        stack.token0 = new MockERC20("DemoToken0", "DT0", 18);
        stack.token1 = new MockERC20("DemoToken1", "DT1", 18);

        if (address(stack.token0) > address(stack.token1)) {
            (stack.token0, stack.token1) = (stack.token1, stack.token0);
        }

        stack.token0.mint(trader, 50_000_000 ether);
        stack.token1.mint(trader, 50_000_000 ether);

        stack.token0.approve(address(stack.liquidityRouter), type(uint256).max);
        stack.token1.approve(address(stack.liquidityRouter), type(uint256).max);
        stack.token0.approve(address(stack.swapRouter), type(uint256).max);
        stack.token1.approve(address(stack.swapRouter), type(uint256).max);
    }

    function _initializePool(DemoStack memory stack, IHooks hook) internal returns (PoolKey memory key) {
        key = PoolKey({
            currency0: Currency.wrap(address(stack.token0)),
            currency1: Currency.wrap(address(stack.token1)),
            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG,
            tickSpacing: 60,
            hooks: hook
        });

        stack.manager.initialize(key, Constants.SQRT_PRICE_1_1);

        stack.liquidityRouter
            .modifyLiquidity(
                key,
                ModifyLiquidityParams({
                    tickLower: -120, tickUpper: 120, liquidityDelta: int256(500_000 ether), salt: bytes32(0)
                }),
                bytes("")
            );
    }

    function _swap(PoolSwapTest router, PoolKey memory key, bool zeroForOne, uint256 amountIn, bytes memory hookData)
        internal
    {
        router.swap(
            key,
            SwapParams({
                zeroForOne: zeroForOne,
                amountSpecified: -int256(amountIn),
                sqrtPriceLimitX96: zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
            }),
            PoolSwapTest.TestSettings({takeClaims: false, settleUsingBurn: false}),
            hookData
        );
    }

    function _mineSalt(bytes memory creationCode, bytes memory constructorArgs) internal view returns (bytes32 salt) {
        (, salt) = HookMiner.find(CREATE2_DEPLOYER, TEMPLATE_FLAGS, creationCode, constructorArgs);
    }

    function _logCore(DemoStack memory stack, address hook) internal view {
        console2.log("PoolManager:", address(stack.manager));
        console2.log("SwapRouter:", address(stack.swapRouter));
        console2.log("LiquidityRouter:", address(stack.liquidityRouter));
        console2.log("Token0:", address(stack.token0));
        console2.log("Token1:", address(stack.token1));
        console2.log("Hook:", hook);
    }
}
