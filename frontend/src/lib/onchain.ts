import {
  createPublicClient,
  createWalletClient,
  custom,
  http,
  isAddress,
  type Address,
  type Hex,
} from "viem";
import { baseSepolia } from "viem/chains";
import factoryAbi from "@shared/abis/TemplateFactory.json";
import {
  BASE_SEPOLIA_CHAIN_ID,
  KNOWN_ADDRESSES,
  type TemplateKind,
} from "@shared/constants/templates";

export type FlowStep = {
  step: string;
  hash: Address;
  explorerUrl?: string;
  status: "confirmed" | "simulated";
};

const RPC_URL = import.meta.env.VITE_RPC_URL || "https://sepolia.base.org";
const EXPLORER = "https://sepolia.basescan.org/tx/";

const publicClient = createPublicClient({
  chain: baseSepolia,
  transport: http(RPC_URL),
});

function randomHash(seed: string): Address {
  const encoded = new TextEncoder().encode(`${seed}-${Date.now()}`);
  const bytes = Array.from(encoded.slice(0, 20));
  while (bytes.length < 20) bytes.push(0);
  const hex = bytes.map((b) => b.toString(16).padStart(2, "0")).join("");
  return `0x${hex}` as Address;
}

function simulated(step: string): FlowStep {
  const hash = randomHash(step);
  return {
    step,
    hash,
    explorerUrl: `${EXPLORER}${hash}`,
    status: "simulated",
  };
}

async function getWallet() {
  const ethereum = (window as Window & { ethereum?: unknown }).ethereum;
  if (!ethereum) {
    throw new Error("No injected wallet found. Install a wallet extension.");
  }

  const walletClient = createWalletClient({
    chain: baseSepolia,
    transport: custom(ethereum),
  });

  const [account] = await walletClient.requestAddresses();
  const chainId = await walletClient.getChainId();
  if (chainId !== BASE_SEPOLIA_CHAIN_ID) {
    throw new Error(`Switch wallet network to Base Sepolia (${BASE_SEPOLIA_CHAIN_ID}).`);
  }

  return { walletClient, account };
}

function getDeployFn(template: TemplateKind): "deployStablecoin" | "deployRWA" | "deployLongTail" {
  if (template === "stablecoin") return "deployStablecoin";
  if (template === "rwa") return "deployRWA";
  return "deployLongTail";
}

function getMineFn(template: TemplateKind): "mineStablecoinSalt" | "mineRWASalt" | "mineLongTailSalt" {
  if (template === "stablecoin") return "mineStablecoinSalt";
  if (template === "rwa") return "mineRWASalt";
  return "mineLongTailSalt";
}

export async function deployTemplate(template: TemplateKind, config: unknown): Promise<FlowStep[]> {
  const factory = KNOWN_ADDRESSES.baseSepolia.factory;
  const manager = KNOWN_ADDRESSES.baseSepolia.poolManager;

  if (!factory || !manager || !isAddress(factory) || !isAddress(manager)) {
    return [
      simulated(`deploy:${template}:factory-missing`),
      simulated(`deploy:${template}:hook`),
    ];
  }

  const { walletClient, account } = await getWallet();

  const mineFunction = getMineFn(template);
  const deployFunction = getDeployFn(template);

  const [predictedHook, salt] = (await publicClient.readContract({
    address: factory,
    abi: factoryAbi,
    functionName: mineFunction,
    args: [manager, account, config],
  })) as [Address, Hex];

  const hash = await walletClient.writeContract({
    account,
    address: factory,
    abi: factoryAbi,
    functionName: deployFunction,
    args: [manager, config, salt],
  });

  await publicClient.waitForTransactionReceipt({ hash });

  return [
    {
      step: `deploy:${template}:hook` ,
      hash,
      explorerUrl: `${EXPLORER}${hash}`,
      status: "confirmed",
    },
    {
      step: `predicted:${template}:hook`,
      hash: predictedHook,
      explorerUrl: undefined,
      status: "simulated",
    },
  ];
}

export async function createPool(template: TemplateKind): Promise<FlowStep[]> {
  return [simulated(`pool:create:${template}`)];
}

export async function runDemoSwaps(template: TemplateKind): Promise<FlowStep[]> {
  return [
    simulated(`swap:${template}:1`),
    simulated(`swap:${template}:2`),
    simulated(`swap:${template}:3`),
  ];
}
