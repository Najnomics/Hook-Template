// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {GuardState} from "./TemplateTypes.sol";

library TemplateGuards {
    function abs(int256 value) internal pure returns (uint256) {
        if (value >= 0) return uint256(value);
        return uint256(-value);
    }

    function enforceRateLimit(
        GuardState storage state,
        uint32 rateLimitWindow,
        uint16 maxSwapsPerWindow,
        bytes32 guardCode,
        function(bytes32) internal pure reverter
    ) internal {
        if (rateLimitWindow == 0 || maxSwapsPerWindow == 0) return;

        if (state.windowStart == 0 || block.timestamp >= uint256(state.windowStart) + rateLimitWindow) {
            state.windowStart = uint64(block.timestamp);
            state.swapsInWindow = 0;
        }

        if (state.swapsInWindow >= maxSwapsPerWindow) {
            reverter(guardCode);
        }

        unchecked {
            state.swapsInWindow += 1;
        }
    }

    function enforceCooldown(
        GuardState storage state,
        uint32 cooldownSeconds,
        bytes32 guardCode,
        function(bytes32) internal pure reverter
    ) internal {
        if (cooldownSeconds == 0 || state.lastSwapTimestamp == 0) return;

        if (block.timestamp < uint256(state.lastSwapTimestamp) + cooldownSeconds) {
            reverter(guardCode);
        }
    }

    function enforceMaxTradeSize(
        uint256 maxTradeSize,
        uint256 tradeSize,
        bytes32 guardCode,
        function(bytes32) internal pure reverter
    ) internal pure {
        if (maxTradeSize == 0) return;
        if (tradeSize > maxTradeSize) {
            reverter(guardCode);
        }
    }

    function updateAfterSwap(GuardState storage state, uint256 tradeSize) internal {
        state.lastSwapTimestamp = uint64(block.timestamp);
        state.cumulativeVolume += tradeSize;

        if (state.lastSwapBlock == uint64(block.number)) {
            state.blockVolume += tradeSize;
        } else {
            state.lastSwapBlock = uint64(block.number);
            state.blockVolume = tradeSize;
        }
    }

    function currentSecondsOfDay() internal view returns (uint32) {
        return uint32(block.timestamp % 1 days);
    }

    function inSession(uint32 startSeconds, uint32 endSeconds) internal view returns (bool) {
        uint32 nowSeconds = currentSecondsOfDay();

        if (startSeconds == endSeconds) return true;
        if (startSeconds < endSeconds) {
            return nowSeconds >= startSeconds && nowSeconds <= endSeconds;
        }

        // Overnight window: e.g. 22:00 -> 06:00
        return nowSeconds >= startSeconds || nowSeconds <= endSeconds;
    }
}
