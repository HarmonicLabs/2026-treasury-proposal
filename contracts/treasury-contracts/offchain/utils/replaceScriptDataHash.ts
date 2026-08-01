import { Tx, ScriptDataHash, toHex } from "@harmoniclabs/buildooor";
import { readFile, writeFile } from "fs/promises";
import path from "path";

void async function main() {
    const exepectedHash = new ScriptDataHash("c9db1c31f94d0521d6d5fe77bcb7232e8996e2c394212d230ff93519b56e250b");

    const fullPath = path.join( import.meta.url.slice( "file:".length ), "../../tx.unsigned" );

    const txJson = JSON.parse( await readFile( fullPath, "utf-8" ) );
    const wrongTx = Tx.fromCbor( txJson.cborHex );
    
    console.log( "wrong hash", wrongTx.body.scriptDataHash?.toString() );
    const rightTx = new Tx({
        ...wrongTx,
        body: {
            ...wrongTx.body,
            scriptDataHash: exepectedHash
        }
    }, undefined);
    rightTx.cborRef = undefined;
    (rightTx.body as any).cborRef = undefined;

    console.log( "right hash", rightTx.body.scriptDataHash?.toString() );

    const prevCborHex = txJson.cborHex;
    const nextCborHex = toHex( rightTx.toCbor() );
    const nextTxJson = {
        ...txJson,
        cborHex: nextCborHex
    };

    console.log( rightTx.body.scriptDataHash?.toString() );
    console.log( exepectedHash.toString() );
    if( prevCborHex === nextCborHex ) throw new Error( "cbor hex is the same" );

    const sanityCheckTx = Tx.fromCbor( nextTxJson.cborHex );
    const sanityCheck = sanityCheckTx.body.scriptDataHash?.toString() === exepectedHash.toString();
    console.log( "sanity check:", sanityCheck );
    if( !sanityCheck ) throw new Error( "sanity check failed" );

    console.log( fullPath );
    await writeFile( fullPath, JSON.stringify( nextTxJson, undefined, 2 ), "utf-8" );

}();