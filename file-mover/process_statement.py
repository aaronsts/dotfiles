#!/usr/bin/env python3
# ============================================================
#  process_statement.py
#  Strips unwanted columns from a bank statement CSV,
#  renames it, and saves it to the destination folder.
#
#  Usage: python3 process_statement.py <src_path> <dest_dir> <filename>
# ============================================================

import sys
import os
import csv
import re
import unicodedata

src_path  = sys.argv[1]
dest_dir  = sys.argv[2]
filename  = sys.argv[3]

# ── Columns to remove ─────────────────────────────────────────
REMOVE_COLS = {
    # Dutch
    "Rekeningnummer", "Rubrieknaam", "Naam", "Afschriftnummer",
    # English
    "Accountnumber", "Heading", "Name", "Statement number",
}

# ── Name columns to extract before removing ───────────────────
NAME_COLS = ["Naam", "Name"]

# ── Auto-detect encoding ──────────────────────────────────────
def detect_encoding_and_delimiter(path):
    for enc in ('utf-8-sig', 'latin-1', 'cp1252', 'utf-8'):
        try:
            with open(path, newline='', encoding=enc) as f:
                sample = f.read(2048)
            delimiter = ';' if sample.count(';') >= sample.count(',') else ','
            return enc, delimiter
        except UnicodeDecodeError:
            continue
    raise ValueError("Could not detect file encoding")

# ── Normalize name for use in filename ────────────────────────
def normalize_name(name):
    # Decompose unicode characters (e.g. ä → a + combining umlaut)
    nfkd = unicodedata.normalize('NFKD', name)
    # Keep only ASCII characters
    ascii_str = nfkd.encode('ascii', 'ignore').decode('ascii')
    # Lowercase and replace spaces/underscores with hyphens
    slugified = re.sub(r'[\s_]+', '-', ascii_str.strip().lower())
    # Remove any remaining non-alphanumeric characters except hyphens
    slugified = re.sub(r'[^a-z0-9-]', '', slugified)
    # Collapse multiple hyphens
    slugified = re.sub(r'-+', '-', slugified)
    return slugified

encoding, delimiter = detect_encoding_and_delimiter(src_path)

# ── Read CSV, extract name, drop unwanted columns ─────────────
account_name = None

# ── Read CSV, drop unwanted columns ──────────────────────────
with open(src_path, newline='', encoding=encoding) as f:
    reader = csv.DictReader(f, delimiter=delimiter)
    fieldnames = [col for col in reader.fieldnames if col not in REMOVE_COLS and col is not None]
    rows = []

    for row in reader:
        if account_name is None:
            for col in NAME_COLS:
                if col in row and row[col]:
                    account_name = row[col]
                    break
        rows.append({k: v for k, v in row.items() if k not in REMOVE_COLS and k is not None})


# ── Build new filename ────────────────────────────────────────
date_match = re.search(r'_(?:tot|until)_(\d{2}-\d{2}-\d{4})', filename, re.IGNORECASE)
date_str   = date_match.group(1) if date_match else "unknown-date"

if date_match:
    name_slug = normalize_name(account_name)
    new_name  = f"{name_slug}-statement-{date_str}.csv"
else:
    new_name  = f"statement-{date_str}.csv"

dest_path = os.path.join(dest_dir, new_name)

# ── Write processed CSV ───────────────────────────────────────
os.makedirs(dest_dir, exist_ok=True)
with open(dest_path, 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames, delimiter=delimiter)
    writer.writeheader()
    writer.writerows(rows)

print(f"SAVED:{dest_path}")
