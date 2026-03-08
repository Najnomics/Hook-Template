export type Address = `0x${string}`;

export type TxLog = {
  step: string;
  hash: Address;
  explorerUrl?: string;
  status: "pending" | "confirmed" | "simulated";
};
