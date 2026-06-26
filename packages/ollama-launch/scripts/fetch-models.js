#!/usr/bin/env node
'use strict';

const https = require('https');
const fs = require('fs');
const path = require('path');

const SEARCH_BASE = 'https://ollama.com/search';
const LIBRARY_BASE = 'https://ollama.com/library';
const DELAY_MS = 300;
const DEFAULT_COUNT = 100;

const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const countIdx = args.indexOf('--count');
const maxModels = countIdx !== -1 ? parseInt(args[countIdx + 1], 10) : DEFAULT_COUNT;

function sleep(ms) {
  return new Promise(r => setTimeout(r, ms));
}

function fetchUrl(url) {
  return new Promise((resolve, reject) => {
    const req = https.get(url, {
      headers: {
        'User-Agent': 'ollama-launcher/fetch-models (model data collector)',
        'HX-Request': 'true',
      },
    }, res => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location) {
        const redirectUrl = res.headers.location.startsWith('http')
          ? res.headers.location
          : `https://ollama.com${res.headers.location}`;
        res.resume();
        fetchUrl(redirectUrl).then(resolve).catch(reject);
        return;
      }
      if (res.statusCode !== 200) {
        res.resume();
        reject(new Error(`HTTP ${res.statusCode} for ${url}`));
        return;
      }
      const chunks = [];
      res.on('data', chunk => chunks.push(chunk));
      res.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
      res.on('error', reject);
    });
    req.on('error', reject);
  });
}

// Parse one page of https://ollama.com/search?page=N
// Returns array of { name, description, tags, pulls, tags_count, updated }
function parseSearchPage(html) {
  const models = [];
  // Each model card is inside <a href="/library/{name}" class="group w-full">
  // Split HTML by that anchor to get per-model blocks
  const parts = html.split(/<a href="\/library\/[^"?#]+?" class="group w-full">/);

  for (let i = 1; i < parts.length; i++) {
    const block = parts[i];

    const nameMatch = block.match(/x-test-search-response-title>([^<]+)</);
    if (!nameMatch) continue;
    const name = nameMatch[1].trim();

    const descMatch = block.match(/max-w-lg break-words[^>]+>\s*([^<]*?)\s*<\/p>/);
    const description = descMatch ? descMatch[1].trim() : '';

    const tags = [...block.matchAll(/x-test-capability[^>]+>([^<]+)</g)]
      .map(m => m[1].trim()).filter(Boolean);

    const pullMatch = block.match(/x-test-pull-count>([^<]+)</);
    const pulls = pullMatch ? pullMatch[1].trim() : 'N/A';

    const tagCountMatch = block.match(/x-test-tag-count>([^<]+)</);
    const tags_count = tagCountMatch ? tagCountMatch[1].trim() : 'N/A';

    const updatedMatch = block.match(/x-test-updated>([^<]+)</);
    const updated = updatedMatch ? updatedMatch[1].trim() : 'N/A';

    models.push({ name, description, tags, pulls, tags_count, updated });
  }

  return models;
}

// Parse https://ollama.com/library/{model} for variant details
// Returns array of { name, size, context_window, input_type }
function parseVariants(html) {
  const variants = [];
  const seen = new Set();

  // Mobile-view variant rows have the cleanest format:
  // <a href="/library/model:tag" class="sm:hidden ...">
  //   ...
  //   <p class="flex text-neutral-500">2.0GB · 128K context window · Text · 1 year ago</p>
  // </a>
  const pattern = /href="\/library\/([^"]+:[^"]+)" class="sm:hidden[^"]*"[\s\S]*?<p class="flex text-neutral-500">([^<]+)<\/p>/g;
  const matches = [...html.matchAll(pattern)];

  for (const match of matches) {
    const variantName = match[1].trim();
    if (seen.has(variantName)) continue;
    seen.add(variantName);

    const details = match[2].trim(); // "2.0GB · 128K context window · Text · 1 year ago"
    const parts = details.split(' · ');

    const size = parts[0] || 'N/A';
    const context_window = (parts[1] || '').replace(' context window', '').trim() || 'N/A';
    const input_type = parts[2] || 'Text';

    variants.push({ name: variantName, size, context_window, input_type });
  }

  return variants;
}

async function fetchAllSearchModels(limit) {
  const all = [];
  const seen = new Set();
  let page = 1;

  while (all.length < limit) {
    const url = `${SEARCH_BASE}?page=${page}`;
    process.stderr.write(`Fetching search page ${page}... `);

    const html = await fetchUrl(url);
    const pageModels = parseSearchPage(html);

    if (pageModels.length === 0) {
      process.stderr.write('empty page, stopping\n');
      break;
    }

    let added = 0;
    for (const m of pageModels) {
      if (!seen.has(m.name) && all.length < limit) {
        seen.add(m.name);
        all.push(m);
        added++;
      }
    }

    process.stderr.write(`${added} new (total: ${all.length})\n`);

    // If all models on this page were duplicates, we've reached the end
    if (added === 0) break;

    page++;
    if (all.length < limit) await sleep(DELAY_MS);
  }

  return all;
}

async function main() {
  process.stderr.write(`Collecting top ${maxModels} models from ollama.com\n\n`);

  // Phase 1: build model list from search pages
  const modelList = await fetchAllSearchModels(maxModels);
  process.stderr.write(`\nCollected ${modelList.length} models. Fetching variant details...\n\n`);

  // Phase 2: fetch per-model variant data
  const models = [];
  for (let i = 0; i < modelList.length; i++) {
    const m = modelList[i];
    process.stderr.write(`[${i + 1}/${modelList.length}] ${m.name} ... `);

    let variants = [];
    try {
      const html = await fetchUrl(`${LIBRARY_BASE}/${m.name}`);
      variants = parseVariants(html);
      process.stderr.write(`${variants.length} variants\n`);
    } catch (err) {
      process.stderr.write(`fetch error: ${err.message}\n`);
    }

    models.push({
      rank: i + 1,
      name: m.name,
      description: m.description,
      pulls: m.pulls,
      tags_count: m.tags_count,
      updated: m.updated,
      tags: m.tags,
      variants,
    });

    if (i < modelList.length - 1) await sleep(DELAY_MS);
  }

  const modelsWithVariants = models.filter(m => m.variants.length > 0).length;
  const totalVariants = models.reduce((sum, m) => sum + m.variants.length, 0);
  const allCapTags = [...new Set(models.flatMap(m => m.tags))].sort();

  const output = {
    metadata: {
      total_models: models.length,
      collection_date: new Date().toISOString().split('T')[0],
      source: `${SEARCH_BASE} and ${LIBRARY_BASE}/<model>`,
      collection_method: `HTML scraping — search pages 1-${Math.ceil(models.length / 20)} + per-model variant pages`,
    },
    models,
    summary: {
      total_models: models.length,
      models_with_variants: modelsWithVariants,
      total_variants: totalVariants,
      capability_tags: allCapTags,
    },
  };

  const json = JSON.stringify(output, null, 2);

  if (dryRun) {
    process.stdout.write(json + '\n');
    process.stderr.write(`\n[dry-run] ${models.length} models, ${modelsWithVariants} with variants, ${totalVariants} total variants\n`);
  } else {
    const outPath = path.join(__dirname, '..', 'models.json');
    fs.writeFileSync(outPath, json + '\n');
    process.stderr.write(`\nWrote ${models.length} models to models.json\n`);
    process.stderr.write(`  ${modelsWithVariants} models with variants, ${totalVariants} total variants\n`);
    process.stderr.write(`  Capability tags: ${allCapTags.join(', ')}\n`);
  }
}

main().catch(err => {
  process.stderr.write(`Fatal: ${err.message}\n`);
  process.exitCode = 1;
});
