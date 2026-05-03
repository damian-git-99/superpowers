/**
 * Superpowers plugin for OpenCode.ai
 *
 * Registers skills directory for discovery and registers superpowers agents
 * from the agents/ directory into the OpenCode agent config.
 */

import path from 'path';
import fs from 'fs';
import os from 'os';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Parse YAML frontmatter into a JS object (handles nested structures)
const parseYamlFrontmatter = (yaml) => {
  const obj = {};
  const pathStack = [obj];
  const indents = [-1];

  const parseScalar = (value) => {
    if (value === 'true') return true;
    if (value === 'false') return false;
    if (value === 'null' || value === '~') return null;
    const num = Number(value);
    if (!isNaN(num) && value.trim() !== '') return num;
    const q = value[0];
    if ((q === '"' || q === "'") && value.endsWith(q)) return value.slice(1, -1);
    return value;
  };

  for (const rawLine of yaml.split('\n')) {
    const line = rawLine.replace(/\s+$/, '');
    if (!line.trim() || line.trim().startsWith('#')) continue;

    const indent = line.search(/\S/);
    const content = line.trim();
    const colonIdx = content.indexOf(':');
    if (colonIdx === -1) continue;

    const key = content.slice(0, colonIdx).trim().replace(/^"(.*)"$/, '$1').replace(/^'(.*)'$/, '$1');
    const val = content.slice(colonIdx + 1).trim();

    while (pathStack.length > 1 && indents[indents.length - 1] >= indent) {
      pathStack.pop();
      indents.pop();
    }

    if (val === '') {
      const child = {};
      pathStack[pathStack.length - 1][key] = child;
      pathStack.push(child);
      indents.push(indent);
    } else {
      pathStack[pathStack.length - 1][key] = parseScalar(val);
    }
  }

  return obj;
};

// Strip YAML frontmatter from markdown content, return { frontmatter, body }
const extractFrontmatter = (content) => {
  const match = content.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
  if (!match) return { frontmatter: {}, body: content };
  return {
    frontmatter: parseYamlFrontmatter(match[1]),
    body: match[2].trim(),
  };
};

export const SuperpowersPlugin = async ({ client, directory }) => {
  const superpowersSkillsDir = path.resolve(__dirname, '../../skills');
  const superpowersAgentsDir = path.resolve(__dirname, '../../agents');
  const homeDir = os.homedir();
  const envConfigDir = (() => {
    const p = process.env.OPENCODE_CONFIG_DIR;
    if (!p || typeof p !== 'string') return null;
    let normalized = p.trim();
    if (!normalized) return null;
    if (normalized.startsWith('~/')) normalized = path.join(homeDir, normalized.slice(2));
    else if (normalized === '~') normalized = homeDir;
    return path.resolve(normalized);
  })();
  const configDir = envConfigDir || path.join(homeDir, '.config/opencode');

  return {
    config: async (config) => {
      // Register skills path so OpenCode discovers superpowers skills
      config.skills = config.skills || {};
      config.skills.paths = config.skills.paths || [];
      if (!config.skills.paths.includes(superpowersSkillsDir)) {
        config.skills.paths.push(superpowersSkillsDir);
      }

      // Register agents from agents/*.md into config.agent
      config.agent = config.agent || {};
      try {
        const files = fs.readdirSync(superpowersAgentsDir);
        for (const file of files) {
          if (!file.endsWith('.md')) continue;
          const agentName = file.replace(/\.md$/, '');
          const fullPath = path.join(superpowersAgentsDir, file);
          const content = fs.readFileSync(fullPath, 'utf8');
          const { frontmatter, body } = extractFrontmatter(content);

          config.agent[agentName] = {
            description: frontmatter.description || '',
            mode: frontmatter.mode || 'subagent',
            ...(frontmatter.temperature !== undefined && { temperature: frontmatter.temperature }),
            ...(frontmatter.tools && { tools: frontmatter.tools }),
            ...(frontmatter.permission && { permission: frontmatter.permission }),
            ...(frontmatter.model && { model: frontmatter.model }),
            ...(frontmatter.hidden !== undefined && { hidden: frontmatter.hidden }),
            ...(frontmatter.steps !== undefined && { steps: frontmatter.steps }),
            ...(frontmatter.color && { color: frontmatter.color }),
            prompt: body,
          };
        }
      } catch (e) {
        console.error('[superpowers] Failed to register agents:', e.message);
      }
    },
  };
};
