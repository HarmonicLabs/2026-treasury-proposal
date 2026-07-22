import { Address, CredentialType } from "@blaze-cardano/core";
import { Blaze, makeValue, Provider, Wallet } from "@blaze-cardano/sdk";
import { input } from "@inquirer/prompts";

import { Treasury } from "../../src";
import { toPermission } from "../../src/metadata/types/permission";
import { loadConfigsAndScripts } from "../../src/shared";
import {
  getActualPermission,
  getBlazeInstance,
  getConfigs,
  getSigners,
  isAddress,
  selectUtxo,
  transactionDialog,
} from "../shared";

export async function disburse(
  blaze: Blaze<Provider, Wallet> | undefined = undefined,
): Promise<void> {
  if (!blaze) {
    blaze = await getBlazeInstance();
  }
  const { configs, scripts, metadata } = await getConfigs(blaze);

  // Resolve the treasury UTxO to spend by querying the treasury script address,
  // as `fund` does. With a single UTxO at the script there is nothing to choose,
  // so we take it and skip the prompt.
  const {
    scripts: {
      treasuryScript: { scriptAddress: treasuryScriptAddress },
    },
  } = loadConfigsAndScripts(blaze, { configs, scripts });

  const utxos = await blaze.provider.getUnspentOutputs(treasuryScriptAddress);
  if (utxos.length === 0) {
    throw new Error(
      `No UTxOs at the treasury script address ${treasuryScriptAddress.toBech32()} (wrong instance, or wrong network?)`,
    );
  }
  const input_ = utxos.length === 1 ? utxos[0] : await selectUtxo(utxos);
  if (utxos.length === 1) {
    console.log(
      `Spending the only treasury UTxO: ${input_.input().transactionId().toString()}#${input_.input().index().toString()} (${input_.output().amount().coin().toString()} lovelace)`,
    );
  }

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
