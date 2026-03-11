export type TemplateKind = "stablecoin" | "rwa" | "longtail";

export type BaseTemplateConfig = {
  maxTradeSize: bigint;
  rateLimitWindow: number;
  maxSwapsPerWindow: number;
  cooldownSeconds: number;
  configUpdateDelay: number;
};

export const BASE_SEPOLIA_CHAIN_ID = 84532;

export const TEMPLATE_LABELS: Record<TemplateKind, string> = {
  stablecoin: "Stablecoin Market",
  rwa: "RWA Market",
  longtail: "Long-Tail Market",
};

export const DEFAULT_BASE_CONFIG: BaseTemplateConfig = {
  maxTradeSize: 250_000n * 10n ** 18n,
  rateLimitWindow: 120,
  maxSwapsPerWindow: 100,
  cooldownSeconds: 0,
  configUpdateDelay: 0,
};

export const TEMPLATE_DEFAULTS = {
  stablecoin: {
    normalFee: 500,
    stressFee: 1500,
    extremeFee: 3000,
    stressDeviation: 20,
    extremeDeviation: 50,
    circuitBreakerDeviation: 120,
    volatilityThreshold: 25,
    circuitBreakerEnabled: true,
  },
  rwa: {
    sessionFee: 2500,
    maxTickJump: 80,
    maxSlippageBps: 7500,
    sessionOpenSeconds: 0,
    sessionCloseSeconds: 86399,
    permissionedOnly: true,
  },
  longtail: {
    launchFee: 8000,
    normalFee: 3000,
    launchDuration: 12 * 60 * 60,
    initialMaxTrade: 10_000n * 10n ** 18n,
    finalMaxTrade: 250_000n * 10n ** 18n,
    volumeTransitionThreshold: 1_000_000n * 10n ** 18n,
    perBlockVolumeCap: 50_000n * 10n ** 18n,
    segmentedOrderFlow: true,
  },
} as const;

export const KNOWN_ADDRESSES = {
  baseSepolia: {
    factory: undefined as `0x${string}` | undefined,
    poolManager: undefined as `0x${string}` | undefined,
  },
};
