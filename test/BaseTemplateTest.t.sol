// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {PoolManager} from "@uniswap/v4-core/src/PoolManager.sol";
import {PoolSwapTest} from "@uniswap/v4-core/src/test/PoolSwapTest.sol";
import {PoolModifyLiquidityTest} from "@uniswap/v4-core/src/test/PoolModifyLiquidityTest.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {ModifyLiquidityParams, SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";
import {Constants} from "@uniswap/v4-core/test/utils/Constants.sol";

abstract contract BaseTemplateTest is Test {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;

    PoolManager internal manager;
    PoolSwapTest internal swapRouter;
    PoolModifyLiquidityTest internal liquidityRouter;

    MockERC20 internal token0;
    MockERC20 internal token1;

    Currency internal currency0;
    Currency internal currency1;
    bool internal forceBootstrapSwap;
    bool internal lastBootstrapSwapped;

    PoolKey internal poolKey;
    PoolId internal poolId;

    address internal alice = address(0xA11CE);
    address internal bob = address(0xB0B);

    uint256 internal constant STARTING_BALANCE = 10_000_000 ether;
    int24 internal constant TICK_LOWER = -120;
    int24 internal constant TICK_UPPER = 120;

    function _bootstrapCore() internal {
        lastBootstrapSwapped = false;
        manager = new PoolManager(address(this));
        swapRouter = new PoolSwapTest(manager);
        liquidityRouter = new PoolModifyLiquidityTest(manager);

        token0 = new MockERC20("Token0", "TK0", 18);
        token1 = new MockERC20("Token1", "TK1", 18);

        if (forceBootstrapSwap || address(token0) > address(token1)) {
            lastBootstrapSwapped = true;
            (token0, token1) = (token1, token0);
        }

        currency0 = Currency.wrap(address(token0));
        currency1 = Currency.wrap(address(token1));

        token0.mint(address(this), STARTING_BALANCE);
        token1.mint(address(this), STARTING_BALANCE);

        token0.approve(address(liquidityRouter), type(uint256).max);
        token1.approve(address(liquidityRouter), type(uint256).max);
        token0.approve(address(swapRouter), type(uint256).max);
        token1.approve(address(swapRouter), type(uint256).max);
    }

    function _setForceBootstrapSwap(bool forced) internal {
        forceBootstrapSwap = forced;
    }

    function _initializePool(IHooks hook, uint128 liquidity) internal {
        poolKey = PoolKey({
            currency0: currency0, currency1: currency1, fee: LPFeeLibrary.DYNAMIC_FEE_FLAG, tickSpacing: 60, hooks: hook
        });

        manager.initialize(poolKey, Constants.SQRT_PRICE_1_1);

        if (liquidity > 0) {
            liquidityRouter.modifyLiquidity(
                poolKey,
                ModifyLiquidityParams({
                    tickLower: TICK_LOWER,
                    tickUpper: TICK_UPPER,
                    liquidityDelta: int256(uint256(liquidity)),
                    salt: bytes32(0)
                }),
                bytes("")
            );
        }

        poolId = poolKey.toId();
    }

    function _mintAndApprove(address trader, uint256 amount) internal {
        token0.mint(trader, amount);
        token1.mint(trader, amount);

        vm.startPrank(trader);
        token0.approve(address(swapRouter), type(uint256).max);
        token1.approve(address(swapRouter), type(uint256).max);
        vm.stopPrank();
    }

    function _swapExactIn(address trader, uint256 amountIn, bool zeroForOne, bytes memory hookData)
        internal
        returns (BalanceDelta delta)
    {
        vm.startPrank(trader);
        delta = swapRouter.swap(
            poolKey,
            SwapParams({
                zeroForOne: zeroForOne,
                amountSpecified: -int256(amountIn),
                sqrtPriceLimitX96: zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
            }),
            PoolSwapTest.TestSettings({takeClaims: false, settleUsingBurn: false}),
            hookData
        );
        vm.stopPrank();
    }

    function _swapExactOut(address trader, uint256 amountOut, bool zeroForOne, bytes memory hookData)
        internal
        returns (BalanceDelta delta)
    {
        vm.startPrank(trader);
        delta = swapRouter.swap(
            poolKey,
            SwapParams({
                zeroForOne: zeroForOne,
                amountSpecified: int256(amountOut),
                sqrtPriceLimitX96: zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1
            }),
            PoolSwapTest.TestSettings({takeClaims: false, settleUsingBurn: false}),
            hookData
        );
        vm.stopPrank();
    }
}
