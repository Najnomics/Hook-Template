// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

struct BaseTemplateConfig {
    uint256 maxTradeSize;
    uint32 rateLimitWindow;
    uint16 maxSwapsPerWindow;
    uint32 cooldownSeconds;
    uint32 configUpdateDelay;
}

struct GuardState {
    uint64 windowStart;
    uint16 swapsInWindow;
    uint64 lastSwapTimestamp;
    uint64 lastSwapBlock;
    uint256 blockVolume;
    uint256 cumulativeVolume;
}

struct StablecoinTemplateConfig {
    BaseTemplateConfig base;
    uint24 normalFee;
    uint24 stressFee;
    uint24 extremeFee;
    uint24 stressDeviation;
    uint24 extremeDeviation;
    uint24 circuitBreakerDeviation;
    uint24 volatilityThreshold;
    bool circuitBreakerEnabled;
}

struct RWATemplateConfig {
    BaseTemplateConfig base;
    uint24 sessionFee;
    uint16 maxTickJump;
    uint16 maxSlippageBps;
    uint32 sessionOpenSeconds;
    uint32 sessionCloseSeconds;
    bool permissionedOnly;
}

struct LongTailTemplateConfig {
    BaseTemplateConfig base;
    uint24 launchFee;
    uint24 normalFee;
    uint32 launchDuration;
    uint256 initialMaxTrade;
    uint256 finalMaxTrade;
    uint256 volumeTransitionThreshold;
    uint256 perBlockVolumeCap;
    bool segmentedOrderFlow;
}
