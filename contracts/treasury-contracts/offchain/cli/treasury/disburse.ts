import {
  Address,
  CredentialType,
  TransactionId,
  TransactionInput,
} from "@blaze-cardano/core";
import { Blaze, makeValue, Provider, Wallet } from "@blaze-cardano/sdk";
import { input } from "@inquirer/prompts";

import { Treasury } from "../../src";
import { toPermission } from "../../src/metadata/types/permission";
import {
  getActualPermission,
  getBlazeInstance,
  getConfigs,
  getSigners,
  isAddress,
  transactionDialog,
} from "../shared";

export async function disburse(
  blaze: Blaze<Provider, Wallet> | undefined = undefined,
): Promise<void> {
  if (!blaze) {
    blaze = await getBlazeInstance();
  }
  const { configs, scripts, metadata } = await getConfigs(blaze);

  // Resolve the treasury UTxO to spend by its "txhash#index" reference.
  // We intentionally resolve by TransactionInput rather than querying by the
  // script Address: the project pins @blaze-cardano/core 0.6.x while the
  // provider bundles 0.8.x, so an Address built here fails the provider's
  // `instanceof Address` check. resolveUnspentOutputs is method-based and
  // unaffected.
  const ref = await input({
    message: "Enter the treasury UTxO to spend (txhash#index)",
    validate: (s) =>
      /^[0-9a-fA-F]{64}#\d+$/.test(s.trim()) ||
      "Must be of the form <64-hex-txhash>#<index>",
  });
  const [txHash, idx] = ref.trim().split("#");
  const utxos = await blaze.provider.resolveUnspentOutputs([
    TransactionInput.fromCore({
      txId: TransactionId(txHash),
      index: Number(idx),
    }),
  ]);
  if (utxos.length === 0) {
    throw new Error(`UTxO ${ref} not found (already spent, or wrong network?)`);
  }
  const input_ = utxos[0];

  // Where the funds go and how much.
  const recipient = Address.fromBech32(
    await input({
      message: "Enter the recipient bech32 address",
      validate: (s) => isAddress(s, CredentialType.KeyHash),
    }),
  );
  const amount = makeValue(
    BigInt(
      await input({
        message: "How much ADA (in lovelace) should be disbursed?",
        validate: (value) => {
          const parsed = BigInt(value || "0");
          return parsed > 0n ? true : "Amount must be a positive value.";
        },
      }),
    ),
  );

  // Disburse requires the `disburse` permission signers (HLabs + a board member
  // for this instance). getSigners prompts for which signers will sign.
  const disbursePermissions = metadata
    ? getActualPermission(
        metadata.body.permissions.disburse,
        metadata.body.permissions,
      )
    : toPermission(configs.treasury.permissions.disburse);
  const signers = await getSigners(disbursePermissions);

  const tx = await (
    await Treasury.disburse({
      configsOrScripts: { configs, scripts },
      blaze,
      input: input_,
      recipient,
      amount,
      signers: [...signers.values()],
    })
  ).complete();

  await transactionDialog(blaze.provider.network, tx.toCbor(), false);
}
