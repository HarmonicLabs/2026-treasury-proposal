import { config as loadEnv } from "dotenv";
import path from "path";

// Load env vars anchored to the offchain root, not the cwd, so the CLI picks up
// the same files no matter which directory it's invoked from. `.env.local` is
// loaded last and overrides `.env` (and any values Bun auto-loaded from cwd).
//
// This lives in its own module, imported first by cli.ts, so it runs before any
// other module is evaluated (ES module imports execute in source order).
const envRoot = path.resolve(import.meta.dir, "..");
loadEnv({ path: path.join(envRoot, ".env"), quiet: true });
loadEnv({ path: path.join(envRoot, ".env.local"), override: true, quiet: true });
