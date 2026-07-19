import { Address, CredentialType, StakeCredentialsType } from "@harmoniclabs/buildooor";
import { readFile } from "fs/promises";
import path from "path";

void async function main() {
    const addr = Address.fromString(
        process.argv[2]
        ?? "addr1xx3n2krrld46qms4f4hzqqxzjgaf59u3fecvl6eh8scmaaarx4vx87mt5php2ntwyqqv9y36ngteznnsel4nw0p3hmms6g0tdg"
    );
    console.log(JSON.stringify({
        bech32: addr.toString(),
        payment: {
            kind: CredentialType[addr.paymentCreds.type],
            hash: addr.paymentCreds.hash.toString()
        },
        stake: addr.stakeCreds ? {
            kind: addr.stakeCreds.type as any as keyof typeof StakeCredentialsType,
            hash: addr.stakeCreds.hash.toString()
        } : null,
        sameCreds: addr.paymentCreds.hash.toString() === addr.stakeCreds?.hash.toString()
    }, undefined, 2))
}();