/**
 * Show all the relevant on/off-chain info for the treasury and vendor contracts
 * of a saved instance.
 *
 * Usage (from the offchain dir):
 *   bun run utils/showContracts.ts                 # the only instance, or the first
 *   bun run utils/showContracts.ts "Hlabs Treasury" # by metadata label or instance key
 *
 * Reconstructs the scripts from metadata.json exactly like the CLI does, so the
 * derived addresses/hashes match what the contracts actually resolve to. If
 * BLOCKFROST_KEY is set, it also fetches live reward-account and address
 * balances (best-effort; the network is inferred from the key prefix).
 */
import "../cli/load-env"; // loads .env/.env.local (anchored to the offchain root)
import { readFile } from "fs/promises";
import path from "path";
import { constructScriptsFromBytes, ICompiledScripts } from "../src/shared";

const LOVELACE_PER_ADA = 1_000_000n;

function ada(lovelace: bigint): string {
  const whole = lovelace / LOVELACE_PER_ADA;
  const frac = (lovelace % LOVELACE_PER_ADA).toString().padStart(6, "0");
  return `${whole.toLocaleString("en-US")}.${frac} ADA`;
}

function asDate(msMaybe: unknown): string {
  if (msMaybe === undefined || msMaybe === null) return "(unset)";
  const ms = Number(msMaybe);
  if (!Number.isFinite(ms)) return String(msMaybe);
  return `${msMaybe} (${new Date(ms).toISOString()})`;
}

interface OnDiskScript {
  config: Record<string, unknown>;
  script: string;
  network: number;
}
interface Instance {
  scripts?: { treasuryScript: OnDiskScript; vendorScript: OnDiskScript };
  metadata?: { body?: { label?: string } };
}

async function blockfrost(
  base: string,
  key: string,
  endpoint: string,
): Promise<unknown | undefined> {
  const resp = await fetch(`${base}${endpoint}`, {
    headers: { project_id: key },
  });
  if (resp.status === 404) return undefined; // never seen on-chain yet
  if (!resp.ok) {
    console.warn(`  (blockfrost ${endpoint} -> ${resp.status})`);
    return undefined;
  }
  return resp.json();
}

async function onChainSummary(
  base: string,
  key: string,
  rewardAccount: string | undefined,
  address: string,
): Promise<void> {
  if (rewardAccount) {
    const acct = (await blockfrost(
      base,
      key,
      `/accounts/${rewardAccount}`,
    )) as { withdrawable_amount?: string; active?: boolean } | undefined;
    if (acct === undefined) {
      console.log("  reward account:    not registered on-chain");
    } else {
      console.log(
        `  reward account:    withdrawable ${ada(BigInt(acct.withdrawable_amount ?? "0"))}` +
          ` (blockfrost active: ${acct.active ?? "?"})`,
      );
    }
  }

  const utxos = (await blockfrost(
    base,
    key,
    `/addresses/${address}/utxos?count=100`,
  )) as
    | { amount: { unit: string; quantity: string }[] }[]
    | undefined;
  if (utxos === undefined) {
    console.log("  address UTxOs:      none (address unused on-chain)");
  } else {
    const lovelace = utxos.reduce(
      (acc, u) =>
        acc +
        BigInt(
          u.amount.find((a) => a.unit === "lovelace")?.quantity ?? "0",
        ),
      0n,
    );
    const more = utxos.length === 100 ? "+ (first 100 only)" : "";
    console.log(
      `  address UTxOs:      ${utxos.length}${more} holding ${ada(lovelace)}`,
    );
  }
}

function printContract(
  title: string,
  s: ICompiledScripts["treasuryScript"] | ICompiledScripts["vendorScript"],
): void {
  const cfg = s.config as Record<string, unknown>;
  console.log(`\n=== ${title} ===`);
  console.log(`  script hash:        ${s.credential.hash}`);
  console.log(`  address (bech32):   ${s.scriptAddress.toBech32()}`);
  console.log(`  reward account:     ${s.rewardAccount ?? "(none)"}`);
  console.log(`  registry token:     ${cfg.registry_token ?? "(none)"}`);
  if ("expiration" in cfg) {
    console.log(`  expiration:         ${asDate(cfg.expiration)}`);
  }
  if ("payout_upperbound" in cfg) {
    console.log(`  payout upperbound:  ${asDate(cfg.payout_upperbound)}`);
  }
  if ("permissions" in cfg) {
    console.log(`  permissions:`);
    console.log(
      JSON.stringify(cfg.permissions, null, 2)
        .split("\n")
        .map((l) => `    ${l}`)
        .join("\n"),
    );
  }
}

void (async function main() {
  const metadataPath = path.join(import.meta.dir, "..", "metadata.json");
  const raw = await readFile(metadataPath, "utf-8");
  const instances = JSON.parse(raw) as Record<string, Instance>;

  const wanted = process.argv[2];
  const entries = Object.entries(instances);
  if (entries.length === 0) {
    throw new Error(`No instances found in ${metadataPath}`);
  }
  const match = wanted
    ? entries.find(
        ([key, inst]) => key === wanted || inst.metadata?.body?.label === wanted,
      )
    : entries[0];
  if (!match) {
    throw new Error(
      `Instance "${wanted}" not found. Available: ${entries
        .map(([k, i]) => i.metadata?.body?.label ?? k)
        .join(", ")}`,
    );
  }
  const [key, instance] = match;
  if (!instance.scripts) {
    throw new Error(`Instance "${key}" has no compiled scripts saved`);
  }

  const { treasuryScript, vendorScript } = instance.scripts;
  const networkId = treasuryScript.network;
  const scripts = constructScriptsFromBytes(
    networkId,
    treasuryScript.config as any,
    treasuryScript.script,
    vendorScript.config as any,
    vendorScript.script,
  );

  console.log(`Instance:             ${instance.metadata?.body?.label ?? key}`);
  console.log(`  key:                ${key}`);
  console.log(`  network:            ${networkId === 1 ? "mainnet" : "testnet"} (id ${networkId})`);

  printContract("TREASURY CONTRACT", scripts.treasuryScript);
  printContract("VENDOR CONTRACT", scripts.vendorScript);

  const key_ = process.env.BLOCKFROST_KEY;
  if (!key_) {
    console.log(
      "\n(Set BLOCKFROST_KEY to also show live on-chain balances.)",
    );
    return;
  }
  const base = key_.startsWith("preprod")
    ? "https://cardano-preprod.blockfrost.io/api/v0"
    : "https://cardano-mainnet.blockfrost.io/api/v0";

  console.log("\n--- on-chain (treasury) ---");
  await onChainSummary(
    base,
    key_,
    scripts.treasuryScript.rewardAccount?.toString(),
    scripts.treasuryScript.scriptAddress.toBech32(),
  );
  console.log("\n--- on-chain (vendor) ---");
  await onChainSummary(
    base,
    key_,
    scripts.vendorScript.rewardAccount?.toString(),
    scripts.vendorScript.scriptAddress.toBech32(),
  );
})();
