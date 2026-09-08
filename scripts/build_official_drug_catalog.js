#!/usr/bin/env node
/**
 * Builds the canonical official drug catalog from the existing Flutter source.
 * This intentionally fails closed: the import file is generated only when the
 * source contains exactly 300 records with unique IDs.
 */
const fs = require('fs');
const path = require('path');

const sourcePath = path.resolve(__dirname, '../lib/core/data/medicines_data.dart');
const outputDir = path.resolve(__dirname, '../functions/data');
const outputPath = path.join(outputDir, 'official_drug_catalog.json');

const source = fs.readFileSync(sourcePath, 'utf8');
const recordRe = /\{\s*'id':\s*'([^']+)'\s*,\s*'name':\s*'([^']+)'\s*,\s*'category':\s*'([^']*)'\s*,\s*'subcategory':\s*'([^']*)'\s*,\s*'price':\s*([0-9]+(?:\.[0-9]+)?)\s*,\s*'description':\s*'([^']*)'\s*,\s*'image':\s*'([^']*)'\s*,\s*'inStock':\s*(true|false)\s*,\s*'requiresPrescription':\s*(true|false)\s*,\s*'rating':\s*([0-9]+(?:\.[0-9]+)?)\s*\}/g;

const rows = [];
let match;
while ((match = recordRe.exec(source)) !== null) {
  const [, id, name, category, subcategory, price, description, image, inStock, requiresPrescription, rating] = match;
  rows.push({
    id,
    name,
    category,
    subcategory,
    price: Number(price),
    description,
    image,
    inStock: inStock === 'true',
    requiresPrescription: requiresPrescription === 'true',
    rating: Number(rating),
  });
}

const ids = new Set();
const duplicates = [];
for (const row of rows) {
  if (ids.has(row.id)) duplicates.push(row.id);
  ids.add(row.id);
}

if (rows.length !== 300) {
  throw new Error(`Catalog validation failed: expected 300 records, found ${rows.length}. No output was written.`);
}
if (duplicates.length) {
  throw new Error(`Catalog validation failed: duplicate IDs: ${duplicates.join(', ')}`);
}

const catalog = rows.map((row) => ({
  drugId: row.id,
  name: row.name,
  genericName: null,
  activeIngredient: null,
  strength: null,
  dosageForm: null,
  category: row.category,
  subcategory: row.subcategory,
  manufacturer: null,
  requiresPrescription: row.requiresPrescription,
  imageAsset: row.image,
  description: row.description,
  legacyPrice: row.price,
  legacyRating: row.rating,
  legacyInStock: row.inStock,
  isOfficial: true,
  isActive: true,
  verificationStatus: 'unverified_source',
}));

fs.mkdirSync(outputDir, { recursive: true });
fs.writeFileSync(outputPath, JSON.stringify(catalog, null, 2) + '\n', 'utf8');
console.log(`Generated ${catalog.length} official catalog records: ${outputPath}`);
