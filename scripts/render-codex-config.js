#!/usr/bin/env node

const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { execFileSync } = require("node:child_process");

const repoRoot = path.resolve(__dirname, "..");
const basePath = path.join(repoRoot, "codex", ".codex", "config.base.toml");
const generatedPath = path.join(repoRoot, "codex", ".codex", "config.toml");
const homeConfigPath = path.join(os.homedir(), ".codex", "config.toml");
const marker = "# -- END BASE CONFIG --";
const localScaffold = [
  "# Add machine-specific Codex overrides and trusted projects below.",
  "# Anything after the marker is preserved by scripts/render-codex-config.js.",
  "#",
  "# Example:",
  '# [projects."/Users/your-user/src/iaf"]',
  '# trust_level = "trusted"',
].join("\n");

function readFileIfExists(filePath) {
  try {
    return fs.readFileSync(filePath, "utf8");
  } catch (error) {
    if (error.code === "ENOENT") {
      return null;
    }
    throw error;
  }
}

function extractLocalSection(text) {
  const markerIndex = text.indexOf(marker);
  if (markerIndex === -1) {
    return null;
  }

  return text
    .slice(markerIndex + marker.length)
    .replace(/^\s+/, "")
    .trimEnd();
}

function extractProjectBlocks(text) {
  const lines = text.split(/\r?\n/);
  const captured = [];
  let capture = false;

  for (const line of lines) {
    if (/^\[projects\."/.test(line)) {
      capture = true;
    } else if (/^\[[^]]+\]/.test(line)) {
      capture = false;
    }

    if (capture) {
      captured.push(line);
    }
  }

  return captured.join("\n").trim();
}

function readLegacyTrackedConfig() {
  try {
    const commit = execFileSync(
      "git",
      ["-C", repoRoot, "log", "-n", "1", "--format=%H", "--", "codex/.codex/config.toml"],
      { encoding: "utf8" },
    ).trim();

    if (!commit) {
      return null;
    }

    return execFileSync(
      "git",
      ["-C", repoRoot, "show", `${commit}:codex/.codex/config.toml`],
      { encoding: "utf8" },
    );
  } catch {
    return null;
  }
}

function resolveLocalSection() {
  const generatedConfig = readFileIfExists(generatedPath);
  if (generatedConfig) {
    const preserved = extractLocalSection(generatedConfig);
    if (preserved !== null) {
      return preserved;
    }
  }

  const homeConfig = readFileIfExists(homeConfigPath);
  if (homeConfig) {
    const preserved = extractLocalSection(homeConfig);
    if (preserved !== null) {
      return preserved;
    }

    const projectsOnly = extractProjectBlocks(homeConfig);
    if (projectsOnly) {
      return [
        "# Migrated trusted projects from ~/.codex/config.toml.",
        "",
        projectsOnly,
      ].join("\n");
    }
  }

  const legacyTrackedConfig = readLegacyTrackedConfig();
  if (legacyTrackedConfig) {
    const projectsOnly = extractProjectBlocks(legacyTrackedConfig);
    if (projectsOnly) {
      return [
        "# Migrated trusted projects from the previously tracked codex/.codex/config.toml.",
        "",
        projectsOnly,
      ].join("\n");
    }
  }

  return localScaffold;
}

const baseConfig = readFileIfExists(basePath);
if (!baseConfig) {
  console.error(`Missing base Codex config: ${basePath}`);
  process.exit(1);
}

const localSection = resolveLocalSection();
const renderedConfig = `${baseConfig.trimEnd()}\n\n${marker}\n${localSection.trimEnd()}\n`;

fs.mkdirSync(path.dirname(generatedPath), { recursive: true });
fs.writeFileSync(generatedPath, renderedConfig);

console.log(`Rendered ${path.relative(repoRoot, generatedPath)}`);
