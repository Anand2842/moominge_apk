#!/usr/bin/env python3
"""
Moomingle CSV Import Script
===========================
Bulk import cattle/buffalo listings from CSV files into Supabase.

Usage:
    python import_csv.py <csv_file> [--dry-run] [--validate-only]

Examples:
    python import_csv.py sample_template.csv --dry-run      # Preview without importing
    python import_csv.py partner_data.csv                    # Import to database
    python import_csv.py data.csv --validate-only           # Only validate, no import
"""

import csv
import sys
import os
import argparse
from datetime import datetime
from typing import List, Dict, Any, Tuple
import json

# Supabase Python client
try:
    from supabase import create_client, Client
except ImportError:
    print("❌ Missing dependency. Install with: pip install supabase")
    sys.exit(1)

# =============================================================================
# CONFIGURATION
# =============================================================================

# Supabase credentials (use environment variables in production!)
SUPABASE_URL = os.environ.get(
    'SUPABASE_URL', 
    'https://igivbuexkliagpyakngf.supabase.co'
)
SUPABASE_KEY = os.environ.get(
    'SUPABASE_KEY',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlnaXZidWV4a2xpYWdweWFrbmdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY2NDcxNTUsImV4cCI6MjA4MjIyMzE1NX0.hSubCrbjs5vxXBaA-gEKdcd2m2u5hKT0waQX4BIvEfg'
)

# Valid breeds supported by Moomingle
VALID_BREEDS = {
    'buffalo': ['Murrah', 'Jaffarbadi', 'Mehsana', 'Bhadawari', 'Surti'],
    'cattle': ['Gir', 'Kankrej', 'Sahiwal', 'Ongole', 'Tharparkar']
}

ALL_BREEDS = VALID_BREEDS['buffalo'] + VALID_BREEDS['cattle']

# Required CSV columns
REQUIRED_COLUMNS = ['name', 'breed', 'price', 'location']
OPTIONAL_COLUMNS = ['animal_type', 'age', 'yield_amount', 'seller_name', 'image_url', 'is_verified']


# =============================================================================
# VALIDATION
# =============================================================================

class ValidationError:
    def __init__(self, row: int, field: str, message: str):
        self.row = row
        self.field = field
        self.message = message
    
    def __str__(self):
        return f"Row {self.row}, '{self.field}': {self.message}"


def validate_row(row_num: int, row: Dict[str, str]) -> List[ValidationError]:
    """Validate a single CSV row and return list of errors."""
    errors = []
    
    # Check required fields
    for field in REQUIRED_COLUMNS:
        if not row.get(field, '').strip():
            errors.append(ValidationError(row_num, field, "Required field is empty"))
    
    # Validate price (must be positive number)
    price_str = row.get('price', '').strip()
    if price_str:
        try:
            price = float(price_str.replace(',', ''))
            if price <= 0:
                errors.append(ValidationError(row_num, 'price', "Price must be positive"))
            if price > 10000000:  # 1 crore max
                errors.append(ValidationError(row_num, 'price', "Price seems too high (max 1 crore)"))
        except ValueError:
            errors.append(ValidationError(row_num, 'price', f"Invalid price format: '{price_str}'"))
    
    # Validate breed
    breed = row.get('breed', '').strip()
    if breed and breed not in ALL_BREEDS:
        errors.append(ValidationError(
            row_num, 'breed', 
            f"Unknown breed '{breed}'. Valid: {', '.join(ALL_BREEDS)}"
        ))
    
    # Validate animal_type
    animal_type = row.get('animal_type', '').strip().lower()
    if animal_type and animal_type not in ['buffalo', 'cattle', 'cow']:
        errors.append(ValidationError(
            row_num, 'animal_type',
            f"Invalid animal type '{animal_type}'. Use 'Buffalo' or 'Cattle'"
        ))
    
    # Auto-detect animal_type from breed if not provided
    if not animal_type and breed:
        if breed in VALID_BREEDS['buffalo']:
            row['animal_type'] = 'Buffalo'
        elif breed in VALID_BREEDS['cattle']:
            row['animal_type'] = 'Cattle'
    
    # Validate image URL format (basic check)
    image_url = row.get('image_url', '').strip()
    if image_url and not (image_url.startswith('http://') or image_url.startswith('https://')):
        errors.append(ValidationError(
            row_num, 'image_url',
            "Image URL must start with http:// or https://"
        ))
    
    return errors


def validate_csv(rows: List[Dict[str, str]]) -> Tuple[List[Dict], List[ValidationError]]:
    """Validate all CSV rows. Returns (valid_rows, all_errors)."""
    all_errors = []
    valid_rows = []
    
    for i, row in enumerate(rows, start=2):  # Start at 2 (row 1 is header)
        errors = validate_row(i, row)
        if errors:
            all_errors.extend(errors)
        else:
            valid_rows.append(row)
    
    return valid_rows, all_errors


# =============================================================================
# DATA TRANSFORMATION
# =============================================================================

def transform_row(row: Dict[str, str]) -> Dict[str, Any]:
    """Transform CSV row to Supabase-compatible format."""
    
    # Parse price
    price_str = row.get('price', '0').strip().replace(',', '')
    price = float(price_str) if price_str else 0
    
    # Parse is_verified
    is_verified_str = row.get('is_verified', 'false').strip().lower()
    is_verified = is_verified_str in ['true', '1', 'yes', 'verified']
    
    # Build the record
    record = {
        'name': row.get('name', '').strip(),
        'breed': row.get('breed', '').strip(),
        'price': price,
        'location': row.get('location', '').strip(),
        'age': row.get('age', 'N/A').strip() or 'N/A',
        'yield_amount': row.get('yield_amount', 'N/A').strip() or 'N/A',
        'seller_name': row.get('seller_name', '').strip() or None,
        'image_url': row.get('image_url', '').strip() or None,
        'is_verified': is_verified,
        'animal_type': row.get('animal_type', '').strip() or None,
        'created_at': datetime.utcnow().isoformat(),
    }
    
    return record


# =============================================================================
# DATABASE OPERATIONS
# =============================================================================

def get_supabase_client() -> Client:
    """Create and return Supabase client."""
    return create_client(SUPABASE_URL, SUPABASE_KEY)


def insert_listings(client: Client, records: List[Dict[str, Any]]) -> Tuple[int, int]:
    """Insert records into Supabase. Returns (success_count, error_count)."""
    success = 0
    errors = 0
    
    # Insert in batches of 100
    batch_size = 100
    for i in range(0, len(records), batch_size):
        batch = records[i:i + batch_size]
        try:
            result = client.table('listings').insert(batch).execute()
            success += len(batch)
            print(f"  ✅ Inserted batch {i//batch_size + 1}: {len(batch)} records")
        except Exception as e:
            errors += len(batch)
            print(f"  ❌ Failed batch {i//batch_size + 1}: {e}")
    
    return success, errors


# =============================================================================
# MAIN IMPORT FUNCTION
# =============================================================================

def import_csv(filepath: str, dry_run: bool = False, validate_only: bool = False) -> bool:
    """
    Main import function.
    
    Args:
        filepath: Path to CSV file
        dry_run: If True, validate and show what would be imported without actually importing
        validate_only: If True, only validate the CSV without importing
    
    Returns:
        True if successful, False otherwise
    """
    print(f"\n{'='*60}")
    print(f"  MOOMINGLE CSV IMPORT")
    print(f"{'='*60}")
    print(f"  File: {filepath}")
    print(f"  Mode: {'DRY RUN' if dry_run else 'VALIDATE ONLY' if validate_only else 'LIVE IMPORT'}")
    print(f"{'='*60}\n")
    
    # Check file exists
    if not os.path.exists(filepath):
        print(f"❌ File not found: {filepath}")
        return False
    
    # Read CSV
    print("📖 Reading CSV file...")
    try:
        with open(filepath, 'r', encoding='utf-8-sig') as f:
            reader = csv.DictReader(f)
            rows = list(reader)
    except Exception as e:
        print(f"❌ Error reading CSV: {e}")
        return False
    
    print(f"   Found {len(rows)} rows\n")
    
    if not rows:
        print("❌ CSV file is empty")
        return False
    
    # Check columns
    print("🔍 Checking columns...")
    first_row = rows[0]
    missing_cols = [col for col in REQUIRED_COLUMNS if col not in first_row]
    if missing_cols:
        print(f"❌ Missing required columns: {', '.join(missing_cols)}")
        print(f"   Required: {', '.join(REQUIRED_COLUMNS)}")
        print(f"   Found: {', '.join(first_row.keys())}")
        return False
    print(f"   ✅ All required columns present\n")
    
    # Validate rows
    print("✅ Validating data...")
    valid_rows, errors = validate_csv(rows)
    
    if errors:
        print(f"\n⚠️  Found {len(errors)} validation errors:\n")
        for error in errors[:20]:  # Show first 20 errors
            print(f"   • {error}")
        if len(errors) > 20:
            print(f"   ... and {len(errors) - 20} more errors")
        print()
    
    print(f"   Valid rows: {len(valid_rows)} / {len(rows)}\n")
    
    if validate_only:
        print("✅ Validation complete (validate-only mode)")
        return len(errors) == 0
    
    if not valid_rows:
        print("❌ No valid rows to import")
        return False
    
    # Transform data
    print("🔄 Transforming data...")
    records = [transform_row(row) for row in valid_rows]
    print(f"   Prepared {len(records)} records\n")
    
    # Preview (dry run or first few records)
    if dry_run or len(records) <= 5:
        print("📋 Preview of records to import:")
        for i, rec in enumerate(records[:5], 1):
            print(f"\n   Record {i}:")
            print(f"      Name: {rec['name']}")
            print(f"      Breed: {rec['breed']} ({rec.get('animal_type', 'Unknown')})")
            print(f"      Price: ₹{rec['price']:,.0f}")
            print(f"      Location: {rec['location']}")
            print(f"      Verified: {rec['is_verified']}")
        if len(records) > 5:
            print(f"\n   ... and {len(records) - 5} more records")
        print()
    
    if dry_run:
        print("✅ Dry run complete. No data was imported.")
        print(f"   Would import {len(records)} records to Supabase.")
        return True
    
    # Import to Supabase
    print("📤 Importing to Supabase...")
    try:
        client = get_supabase_client()
        success, failed = insert_listings(client, records)
        
        print(f"\n{'='*60}")
        print(f"  IMPORT COMPLETE")
        print(f"{'='*60}")
        print(f"  ✅ Successfully imported: {success}")
        print(f"  ❌ Failed: {failed}")
        print(f"  ⚠️  Skipped (validation errors): {len(rows) - len(valid_rows)}")
        print(f"{'='*60}\n")
        
        return failed == 0
        
    except Exception as e:
        print(f"❌ Database error: {e}")
        return False


# =============================================================================
# CLI ENTRY POINT
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Import cattle/buffalo listings from CSV to Moomingle',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python import_csv.py sample_template.csv --dry-run
  python import_csv.py partner_data.csv
  python import_csv.py data.csv --validate-only

CSV Format:
  Required columns: name, breed, price, location
  Optional columns: animal_type, age, yield_amount, seller_name, image_url, is_verified

Valid Breeds:
  Buffalo: Murrah, Jaffarbadi, Mehsana, Bhadawari, Surti
  Cattle: Gir, Kankrej, Sahiwal, Ongole, Tharparkar
        """
    )
    
    parser.add_argument('csv_file', help='Path to CSV file to import')
    parser.add_argument('--dry-run', action='store_true', 
                        help='Validate and preview without importing')
    parser.add_argument('--validate-only', action='store_true',
                        help='Only validate CSV, do not import')
    
    args = parser.parse_args()
    
    success = import_csv(
        args.csv_file, 
        dry_run=args.dry_run, 
        validate_only=args.validate_only
    )
    
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
