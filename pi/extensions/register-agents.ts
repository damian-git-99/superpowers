/**
 * Superpowers extension for Pi
 *
 * Registers Superpowers agents as pi-subagents by copying agent files
 * to ~/.pi/agent/agents/superpowers/ on first load.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";
import { fileURLToPath } from "node:url";

function getExtensionDir(): string | null {
  // 1. import.meta.dirname (Node 22+, may be undefined under jiti)
  const dirname = (import.meta as { dirname?: string }).dirname;
  if (dirname && fs.existsSync(path.join(dirname, "../agents"))) {
    return dirname;
  }

  // 2. import.meta.url (file:// scheme)
  const url = (import.meta as { url?: string }).url;
  if (url && url.startsWith("file://")) {
    const extDir = path.dirname(fileURLToPath(url));
    if (fs.existsSync(path.join(extDir, "../agents"))) return extDir;
  }

  // 3. Under jiti, import.meta may be opaque. Search upward for agents/
  const searchPaths = [
    process.cwd(),
    ...(process.argv[1] ? [path.dirname(process.argv[1])] : []),
  ];

  for (const start of searchPaths) {
    let dir = start;
    for (let i = 0; i < 15; i++) {
      // Check <dir>/agents/ and <dir>/pi/agents/
      for (const candidate of [
        path.join(dir, "agents"),
        path.join(dir, "pi", "agents"),
      ]) {
        if (fs.existsSync(path.join(candidate, "code-reviewer.md"))) {
          // Return the extensions dir parallel to agents
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

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event) => {
    const targetDir = path.join(os.homedir(), ".pi/agent/agents/superpowers");

    // Only copy once
    if (fs.existsSync(targetDir)) return;

    const extDir = getExtensionDir();
    if (!extDir) {
      console.error("[superpowers] Could not find extension directory");
      return;
    }

    const agentsDir = path.resolve(extDir, "../agents");
    if (!fs.existsSync(agentsDir)) {
      console.error("[superpowers] Agents directory not found:", agentsDir);
      return;
    }

    try {
      fs.mkdirSync(targetDir, { recursive: true });
      const files = fs.readdirSync(agentsDir);
      let count = 0;
      for (const file of files) {
        if (!file.endsWith(".md")) continue;
        fs.copyFileSync(path.join(agentsDir, file), path.join(targetDir, file));
        count++;
      }
      if (count > 0) {
        console.log(`[superpowers] Registered ${count} agents in ${targetDir}`);
      }
    } catch (e) {
      console.error("[superpowers] Failed to register agents:", e);
    }
  });
}
