import { Tx } from "@harmoniclabs/buildooor";
import { readFile } from "fs/promises";
import path from "path";

void async function main() {
    const fullPath = path.join( import.meta.url.slice( "file:".length ), "../../milestone_0_tx.signed" );
    const txJson = JSON.parse( await readFile( fullPath, "utf-8" ) );
    const tx = Tx.fromCbor( txJson.cborHex );
    console.log( JSON.stringify( tx, undefined, 2 ) );
}();