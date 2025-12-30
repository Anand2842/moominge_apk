# Moomingle CSV Data Import

Bulk import cattle/buffalo listings from CSV files into Moomingle's database.

## Quick Start

```bash
# 1. Install dependencies
cd data_import
pip install -r requirements.txt

# 2. Test with sample data (dry run)
python import_csv.py sample_template.csv --dry-run

# 3. Import for real
python import_csv.py your_data.csv
```

## CSV Format

### Required Columns
| Column | Description | Example |
|--------|-------------|---------|
| `name` | Listing name/title | "Royal Murrah" |
| `breed` | Breed name (see valid breeds below) | "Murrah" |
| `price` | Price in INR (numbers only) | 85000 |
| `location` | City, State format | "Rohtak, Haryana" |

### Optional Columns
| Column | Description | Default |
|--------|-------------|---------|
| `animal_type` | "Buffalo" or "Cattle" | Auto-detected from breed |
| `age` | Age description | "N/A" |
| `yield_amount` | Milk yield | "N/A" |
| `seller_name` | Seller's name | null |
| `image_url` | Full URL to image | null |
| `is_verified` | true/false | false |

### Valid Breeds

**Buffalo:** Murrah, Jaffarbadi, Mehsana, Bhadawari, Surti

**Cattle:** Gir, Kankrej, Sahiwal, Ongole, Tharparkar

## Usage Examples

```bash
# Validate only (check for errors without importing)
python import_csv.py data.csv --validate-only

# Dry run (validate + preview what would be imported)
python import_csv.py data.csv --dry-run

# Live import
python import_csv.py data.csv
```

## For Partners

### Step 1: Download Template
Use `sample_template.csv` as your starting point.

### Step 2: Fill Your Data
- One row per animal listing
- Keep the header row exactly as-is
- Save as CSV (UTF-8 encoding)

### Step 3: Validate
```bash
python import_csv.py your_file.csv --validate-only
```
Fix any errors reported.

### Step 4: Import
```bash
python import_csv.py your_file.csv
```

## Environment Variables (Production)

For production, set these instead of using defaults:

```bash
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_KEY="your-service-role-key"
```

## Troubleshooting

**"Missing dependency" error:**
```bash
pip install supabase
```

**"Unknown breed" error:**
Check spelling matches exactly (case-sensitive): Murrah, Gir, etc.

**"Invalid price" error:**
Remove currency symbols and commas. Use plain numbers: `85000` not `₹85,000`

**Image not showing in app:**
Ensure `image_url` is a full public URL starting with `https://`
