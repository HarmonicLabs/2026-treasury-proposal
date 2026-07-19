import { Blaze, Provider, Wallet } from "@blaze-cardano/sdk";
import { confirm, input } from "@inquirer/prompts";
import { ETransactionEvent, Treasury } from "../../src";
import {
  IInitialize,
  IOutput,
} from "../../src/metadata/types/initialize-reorganize";
import {
  getBlazeInstance,
  getConfigs,
  getOptional,
  getOutputs,
  getTransactionMetadata,
  getWithdrawableLovelace,
  maybeInput,
  transactionDialog,
} from "../shared";

export async function withdraw(
  blazeInstance: Blaze<Provider, Wallet> | undefined = undefined,
): Promise<void> {
  if (!blazeInstance) {
    blazeInstance = await getBlazeInstance();
  }
  const { configs, scripts } = await getConfigs(blazeInstance);

  // Preliminary question: derive everything from on-chain state + the configured
  // wallet, so no further prompts are needed. Withdraws the full reward balance
  // into a single output and uses the wallet's payment credential as the author.
  const express = await confirm({
    message:
      "Auto-derive from on-chain state? (withdraw the full reward balance into a single output, author = wallet payment credential)",
    default: true,
  });

  let amounts: bigint[];
  let outputs: Record<number, IOutput>;
  let reason: string | undefined;
  let withdrawAmount: bigint | undefined;
  let nonInteractiveMeta: { txAuthor: string; comment?: string } | undefined;

  if (express) {
    const rewardAccount = scripts.treasuryScript.rewardAccount;
    if (!rewardAccount) {
      throw new Error("Treasury script has no reward account to withdraw from");
    }
    const walletAddress = process.env.WALLET_ADDRESS;
    if (!walletAddress) {
      throw new Error(
        "WALLET_ADDRESS is not set; required to derive the transaction author in express mode",
      );
    }

    const balance = await getWithdrawableLovelace(rewardAccount.toString());
    if (balance <= 0n) {
      throw new Error(
        `Nothing to withdraw: reward account ${rewardAccount} has 0 withdrawable lovelace`,
      );
    }

    amounts = [balance];
    withdrawAmount = balance;
    outputs = {
      0: {
        identifier: `initialize-${configs.treasury.registry_token.slice(0, 8)}`,
        label: "Treasury initialization",
      } as IOutput,
    };
    reason = undefined;
    // txAuthor accepts a bech32 address; getTransactionMetadata extracts the
    // payment credential (and throws if it isn't a key-hash credential).
    nonInteractiveMeta = { txAuthor: walletAddress, comment: undefined };

    console.log(
      `Express mode: withdrawing ${balance} lovelace from ${rewardAccount} into a single output at the treasury script; author = payment credential of ${walletAddress}.`,
    );
  } else {
    ({ amounts, outputs } = await getOutputs());
    reason = await maybeInput({
      message: "Enter a reason for the withdrawal (optional)",
    });
    const withdrawAmountOpt = await getOptional(
      "Do you want to specify a withdrawal amount? (optional)",
      { message: "Enter withdrawal amount in lovelace:" },
      input,
    );
    withdrawAmount =
      withdrawAmountOpt !== undefined
        ? BigInt(parseInt(withdrawAmountOpt))
        : undefined;
  }

  const body: IInitialize = {
    event: ETransactionEvent.INITIALIZE,
    reason,
    outputs,
  };

  const txMetadata = await getTransactionMetadata(
    configs.treasury.registry_token,
    body,
    nonInteractiveMeta,
  );

  const tx = await Treasury.withdraw({
    configsOrScripts: { configs, scripts },
    amounts,
    blaze: blazeInstance,
    metadata: txMetadata,
    withdrawAmount,
  });
  const finalTx = await tx.complete();
  await transactionDialog(
    blazeInstance.provider.network,
    finalTx.toCbor().toString(),
    false,
  );
}
