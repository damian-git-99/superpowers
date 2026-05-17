/**
 * Superpowers extension for Pi
 *
 * Registers Superpowers agents as pi-subagents by syncing agent files
 * to ~/.pi/agent/agents/superpowers/ on each session start.
 *
 * Sync strategy (mtime + size):
 * - Compares mtime and file size, not content hashes
 * - Copies only what changed
 * - Removes stale files
 *
 * Uses __dirname (provided by jiti) for reliable path resolution.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";
declare var __dirname: string | undefined;

function getExtensionDir(): string | null {
  if (__dirname && fs.existsSync(path.join(__dirname, "../agents"))) {
    return __dirname;
  }

  // Fallback: search upward for agents/
  const searchPaths = [
    process.cwd(),
    ...(process.argv[1] ? [path.dirname(process.argv[1])] : []),
  ];

  for (const start of searchPaths) {
    let dir = start;
    for (let i = 0; i < 15; i++) {
      for (const candidate of [
        path.join(dir, "agents"),
        path.join(dir, "pi", "agents"),
      ]) {
        if (fs.existsSync(path.join(candidate, "code-reviewer.md"))) {
          const candidateDir = candidate.endsWith("/pi/agents")
            ? path.join(dir, "pi", "extensions")
            : path.join(dir, "extensions");
          if (fs.existsSync(candidateDir)) return candidateDir;
        }
      }
      const parent = path.dirname(dir);
      if (parent === dir) break;
      dir = parent;
    }
  }

  return null;
}

function syncAgents(sourceDir: string, targetDir: string): number {
  let synced = 0;

  // Ensure target directory exists
  fs.mkdirSync(targetDir, { recursive: true });

  // Read source files
  const sourceFiles = fs.readdirSync(sourceDir).filter(f => f.endsWith(".md"));

  // Build set of expected filenames
  const expected = new Set(sourceFiles);

  // Sync each source file
  for (const file of sourceFiles) {
    const src = path.join(sourceDir, file);
    const dst = path.join(targetDir, file);

    const srcStat = fs.statSync(src);

    try {
      const dstStat = fs.statSync(dst);
      // Same mtime + size → skip
      if (dstStat.mtimeMs === srcStat.mtimeMs && dstStat.size === srcStat.size) {
        continue;
      }
    } catch {
      // Destination doesn't exist → will copy
    }

    fs.copyFileSync(src, dst);
    // Preserve mtime so next run can skip if unchanged
    fs.utimesSync(dst, srcStat.atime, srcStat.mtime);
    synced++;
  }

  // Remove stale files (exist in target but not in source)
  const targetFiles = fs.readdirSync(targetDir).filter(f => f.endsWith(".md"));
  for (const file of targetFiles) {
    if (!expected.has(file)) {
      fs.rmSync(path.join(targetDir, file));
      synced++;
    }
  }

  return synced;
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event) => {
    const extDir = getExtensionDir();
    if (!extDir) {
      console.error("[superpowers] Could not find extension directory");
      return;
    }

    const sourceDir = path.resolve(extDir, "../agents");
    if (!fs.existsSync(sourceDir)) {
      console.error("[superpowers] Agents directory not found:", sourceDir);
      return;
    }

    const targetDir = path.join(os.homedir(), ".pi/agent/agents/superpowers");

    try {
      const count = syncAgents(sourceDir, targetDir);
      if (count > 0) {
        console.log(`[superpowers] Synced ${count} agent(s) to ${targetDir}`);
      }
    } catch (e) {
      console.error("[superpowers] Failed to sync agents:", e);
    }
  });
}
