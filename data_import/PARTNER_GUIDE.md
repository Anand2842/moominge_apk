# Moomingle Partner Data Integration Guide

Welcome! This guide helps you prepare your cattle/buffalo data for import into Moomingle.

## What We Need From You

A CSV (spreadsheet) file with your livestock listings. You can create this from Excel, Google Sheets, or any database export.

---

## CSV Column Reference

### Required Fields (must have data)

| Field | What to put | Example |
|-------|-------------|---------|
| **name** | A catchy name for the listing | "Premium Murrah #42" |
| **breed** | Exact breed name (see list below) | "Murrah" |
| **price** | Price in Rupees (just the number) | 85000 |
| **location** | City, State | "Karnal, Haryana" |

### Optional Fields (nice to have)

| Field | What to put | Example |
|-------|-------------|---------|
| **animal_type** | "Buffalo" or "Cattle" | "Buffalo" |
| **age** | Age of the animal | "4 Years" or "3.5 Years" |
| **yield_amount** | Daily milk yield | "18L / Day" |
| **seller_name** | Your name or farm name | "Krishna Dairy Farm" |
| **image_url** | Web link to photo | "https://yoursite.com/photo.jpg" |
| **is_verified** | Has this been verified? | "true" or "false" |

---

## Supported Breeds

We currently support these breeds. Please use exact spelling:

### Buffalo Breeds
- Murrah
- Jaffarbadi  
- Mehsana
- Bhadawari
- Surti

### Cattle Breeds
- Gir
- Kankrej
- Sahiwal
- Ongole
- Tharparkar

> **Note:** If your breed isn't listed, contact us to add it!

---

## Common Locations

Here are typical trading regions. Use "City, State" format:

**Haryana:** Karnal, Rohtak, Hisar, Kurukshetra, Panipat
**Punjab:** Ludhiana, Amritsar, Jalandhar, Fazilka, Bathinda
**Gujarat:** Junagadh, Mehsana, Anand, Rajkot, Bhavnagar
**Rajasthan:** Jaipur, Jodhpur, Bikaner, Udaipur, Ajmer
**Uttar Pradesh:** Lucknow, Agra, Varanasi, Meerut, Mathura
**Maharashtra:** Pune, Nagpur, Nashik, Kolhapur, Sangli
**Madhya Pradesh:** Indore, Bhopal, Jabalpur, Gwalior
**Andhra Pradesh:** Ongole, Guntur, Vijayawada, Nellore

---

## Image Guidelines

For best results:
- Use clear, well-lit photos
- Show the full animal from the side
- Minimum 800x600 pixels
- JPEG or PNG format
- Host on a public URL (Google Drive, Imgur, your website)

**No image?** Leave the field empty - we'll use a placeholder.

---

## How to Create Your CSV

### From Excel
1. Open your data in Excel
2. File → Save As → Choose "CSV (Comma delimited)"

### From Google Sheets
1. Open your spreadsheet
2. File → Download → Comma-separated values (.csv)

### From Database
Export to CSV with UTF-8 encoding.

---

## Validation Checklist

Before sending, verify:

- [ ] All required columns have data (name, breed, price, location)
- [ ] Breed names match our list exactly
- [ ] Prices are numbers only (no ₹ symbol, no commas)
- [ ] Image URLs start with https://
- [ ] File is saved as .csv (not .xlsx)

---

## Sending Your Data

Email your CSV file to: [your-email@moomingle.com]

Or use our import tool directly:
```bash
python import_csv.py your_data.csv --validate-only
```

---

## Questions?

Contact the Moomingle team for:
- Adding new breeds
- Bulk image hosting
- Custom data formats
- API integration (for automated sync)

---

## Data Privacy

- Seller contact info is only shared with matched buyers
- We don't sell or share your data with third parties
- You can request data deletion anytime
