# Contoso Retail Analytics — Data Dictionary

## Overview
- **Source**: Microsoft Contoso Retail Dataset (~1M records)
- **Pipeline**: AWS S3 → Snowflake → dbt
- **Architecture**: Bronze → Silver → Gold (Medallion)
- **Database**: DEV_CONTOSO_RETAIL

---

## Fact Tables

### `fact_sales`
- **Grain**: One row per order line item
- **Schema**: GOLD
- **Records**: 2,349,091+
- **Materialization**: Table

| Column | Type | Description |
|---|---|---|
| `order_key` | NUMBER | FK to dim_orders / natural key |
| `line_number` | NUMBER | Line item number within order |
| `date_key` | NUMBER | FK to dim_date |
| `customer_key` | NUMBER | FK to dim_customers |
| `product_key` | NUMBER | FK to dim_products |
| `store_key` | NUMBER | FK to dim_stores |
| `currency_code` | VARCHAR | Transaction currency (USD/GBP/EUR/AUD/CAD) |
| `order_date` | DATE | Date order was placed |
| `delivery_date` | DATE | Date order was delivered |
| `delivery_days` | NUMBER | Days between order and delivery |
| `quantity` | NUMBER | Units ordered |
| `unit_price` | DECIMAL | Price per unit before discount |
| `net_price` | DECIMAL | Price per unit after discount |
| `unit_cost` | DECIMAL | Cost per unit |
| `gross_revenue` | DECIMAL | Revenue before discount (unit_price × quantity) |
| `net_revenue` | DECIMAL | Revenue after discount (net_price × quantity) |
| `total_cost` | DECIMAL | Total cost (unit_cost × quantity) |
| `profit` | DECIMAL | Net revenue minus total cost |
| `profit_margin_pct` | DECIMAL | (profit / net_revenue) × 100 |
| `discount_amount` | DECIMAL | gross_revenue minus net_revenue |
| `discount_pct` | DECIMAL | (discount_amount / gross_revenue) × 100 |
| `loaded_at` | TIMESTAMP | Pipeline load timestamp |

---

## Dimension Tables

### `dim_customers`
- **Type**: SCD Type 1 (SCD Type 2 via `snp_customers` snapshot)
- **Schema**: GOLD
- **Records**: 104,990
- **Materialization**: Table

| Column | Type | Description |
|---|---|---|
| `customer_key` | NUMBER | Primary key |
| `geo_area_key` | NUMBER | FK to geographic area |
| `start_dt` | DATE | Record validity start date |
| `end_dt` | DATE | Record validity end date |
| `full_name` | VARCHAR | Concatenated first + last name |
| `first_name` | VARCHAR | Given name |
| `last_name` | VARCHAR | Surname |
| `title` | VARCHAR | Honorific (Mr./Ms./Mrs.) |
| `middle_initial` | VARCHAR | Middle initial |
| `gender` | VARCHAR | Gender (male/female) |
| `birth_date` | DATE | Date of birth |
| `age` | NUMBER | Age in years |
| `continent` | VARCHAR | Continent |
| `country_code` | VARCHAR | ISO 2-letter country code |
| `country_name` | VARCHAR | Full country name |
| `state_code` | VARCHAR | State/province code |
| `state_name` | VARCHAR | Full state/province name |
| `city` | VARCHAR | City name |
| `zip_code` | VARCHAR | Postal/ZIP code |
| `street_address` | VARCHAR | Street address |
| `latitude` | DECIMAL | Geographic latitude |
| `longitude` | DECIMAL | Geographic longitude |
| `occupation` | VARCHAR | Customer occupation |
| `company` | VARCHAR | Employer company |
| `vehicle` | VARCHAR | Vehicle owned |
| `total_orders` | NUMBER | Lifetime order count |
| `total_items_purchased` | NUMBER | Lifetime units purchased |
| `lifetime_gross_revenue` | DECIMAL | Lifetime gross revenue |
| `lifetime_net_revenue` | DECIMAL | Lifetime net revenue |
| `lifetime_profit` | DECIMAL | Lifetime profit |
| `avg_profit_margin_pct` | DECIMAL | Average profit margin % |
| `first_order_date` | DATE | Date of first purchase |
| `last_order_date` | DATE | Date of most recent purchase |
| `days_since_last_order` | NUMBER | Days since last purchase |
| `customer_segment` | VARCHAR | VIP / High Value / Medium Value / Low Value |
| `loaded_at` | TIMESTAMP | Pipeline load timestamp |

---

### `dim_products`
- **Type**: SCD Type 1 (SCD Type 2 via `snp_products` snapshot)
- **Schema**: GOLD
- **Records**: 2,517
- **Materialization**: Table

| Column | Type | Description |
|---|---|---|
| `product_key` | NUMBER | Primary key |
| `product_code` | VARCHAR | Product SKU code |
| `product_name` | VARCHAR | Full product name |
| `manufacturer` | VARCHAR | Manufacturer name |
| `brand` | VARCHAR | Brand name |
| `color` | VARCHAR | Product color |
| `weight_unit` | VARCHAR | Unit of weight (kg/lb) |
| `weight` | DECIMAL | Product weight |
| `cost` | DECIMAL | Unit cost price |
| `price` | DECIMAL | Unit selling price |
| `category_key` | NUMBER | FK to product category |
| `category_name` | VARCHAR | Top-level category |
| `subcategory_key` | NUMBER | FK to product subcategory |
| `subcategory_name` | VARCHAR | Subcategory name |
| `margin_amount` | DECIMAL | price minus cost |
| `margin_pct` | DECIMAL | (margin_amount / price) × 100 |
| `loaded_at` | TIMESTAMP | Pipeline load timestamp |

---

### `dim_stores`
- **Type**: SCD Type 1 (SCD Type 2 via `snp_stores` snapshot)
- **Schema**: GOLD
- **Records**: 74
- **Materialization**: Table

| Column | Type | Description |
|---|---|---|
| `store_key` | NUMBER | Primary key |
| `store_code` | VARCHAR | Store identifier code |
| `geo_area_key` | NUMBER | FK to geographic area |
| `country_code` | VARCHAR | ISO 2-letter country code |
| `country_name` | VARCHAR | Full country name |
| `state` | VARCHAR | State/province |
| `open_date` | DATE | Store opening date |
| `close_date` | DATE | Store closing date (NULL if active) |
| `description` | VARCHAR | Store description |
| `square_meters` | NUMBER | Store floor size in sqm |
| `status` | VARCHAR | Active / Closed / Restructured |
| `is_active` | BOOLEAN | TRUE if currently operating |
| `days_operational` | NUMBER | Total days store has operated |
| `loaded_at` | TIMESTAMP | Pipeline load timestamp |

---

### `dim_date`
- **Type**: Static dimension
- **Schema**: GOLD
- **Records**: 4,018 (2016–2026)
- **Materialization**: Table

| Column | Type | Description |
|---|---|---|
| `date_key` | NUMBER | Primary key (YYYYMMDD format) |
| `date_value` | DATE | Full calendar date |
| `year` | NUMBER | Calendar year |
| `year_quarter` | VARCHAR | e.g. Q1-2016 |
| `year_quarter_number` | NUMBER | Sequential quarter number |
| `quarter` | VARCHAR | Q1 / Q2 / Q3 / Q4 |
| `year_month` | VARCHAR | e.g. January 2016 |
| `year_month_short` | VARCHAR | e.g. Jan 2016 |
| `year_month_number` | NUMBER | Sequential month number |
| `month_name` | VARCHAR | Full month name |
| `month_short` | VARCHAR | 3-letter month abbreviation |
| `month_number` | NUMBER | Month number (1–12) |
| `day_of_week` | VARCHAR | Full day name |
| `day_of_week_short` | VARCHAR | 3-letter day abbreviation |
| `day_of_week_number` | NUMBER | Day number (1=Sun, 7=Sat) |
| `is_working_day` | NUMBER | 1 = working day, 0 = non-working |
| `working_day_number` | NUMBER | Sequential working day count |
| `is_weekend` | BOOLEAN | TRUE if Saturday or Sunday |
| `loaded_at` | TIMESTAMP | Pipeline load timestamp |

---

## Analytics Layer

### `obt_sales` (One Big Table)
- **Schema**: GOLD
- **Records**: 2,349,091+
- **Materialization**: Table
- **Purpose**: Denormalized table combining all dimensions + fact for direct BI consumption

Contains all columns from `fact_sales` enriched with:
- Full customer demographics + segmentation
- Full product hierarchy + margin metrics
- Full store location + operational status
- Full date calendar attributes

---

## Silver Layer (Staging Views)

| Model | Source Table | Records |
|---|---|---|
| `stg_orders` | BRONZE_ORDERS | ~489,000 |
| `stg_orderrows` | BRONZE_ORDERROWS | ~2,349,091 |
| `stg_customers` | BRONZE_CUSTOMER | ~104,990 |
| `stg_product` | BRONZE_PRODUCT | ~2,517 |
| `stg_stores` | BRONZE_STORE | 74 |
| `stg_date` | BRONZE_DATE | 4,018 |
| `stg_currencyexchange` | BRONZE_CURRENCYEXCHANGE | ~46,000 |

---

## Seeds

### `seed_currency_lookup`
| Column | Type | Description |
|---|---|---|
| `currency_code` | VARCHAR | ISO currency code |
| `currency_name` | VARCHAR | Full currency name |
| `symbol` | VARCHAR | Currency symbol |
| `region` | VARCHAR | Geographic region |

---

## Snapshots

| Snapshot | Source | Strategy | Tracked Columns |
|---|---|---|---|
| `snp_customers` | stg_customers | check | city, state, country, occupation, company, vehicle, age |
| `snp_products` | stg_product | check | cost, price, color, weight |
| `snp_stores` | stg_stores | check | status, square_meters, close_date |

All snapshots include dbt SCD columns: `DBT_SCD_ID`, `DBT_UPDATED_AT`, `DBT_VALID_FROM`, `DBT_VALID_TO`

---

## Data Quality Tests

**Total: 46/46 ✅ All Passing**

### Generic Tests (41)

| Test Type | Count | Models Covered |
|---|---|---|
| `not_null` | 22 | stg_orders, stg_orderrows, stg_customers, stg_product, stg_stores, stg_date, stg_currencyexchange, fact_sales, dim_date |
| `unique` | 7 | stg_orders, stg_customers, stg_product, stg_stores, stg_date, dim_date |
| `accepted_values` | 4 | stg_orders (currency_code), stg_customers (country_code), stg_stores (status), stg_currencyexchange (from_currency) |
| `relationships` | 3 | stg_orders → stg_customers, stg_orders → stg_stores, stg_orderrows → stg_product |
| `not_null` (Gold) | 5 | fact_sales (order_key, customer_key, product_key, store_key, net_revenue, quantity) |

### Singular Tests (5)

| Test | Description | Model |
|---|---|---|
| `assert_positive_revenue` | Net revenue must be ≥ 0 | fact_sales |
| `assert_positive_quantity` | Quantity must be > 0 | fact_sales |
| `assert_delivery_after_order` | Delivery date must be ≥ order date | stg_orders |
| `assert_exchange_rate_positive` | Exchange rate must be > 0 | stg_currencyexchange |
| `assert_profit_margin_range` | Margin must be between -100% and 100% | fact_sales |

### Accepted Values Verified

| Column | Allowed Values |
|---|---|
| `currency_code` | USD, GBP, EUR, AUD, CAD |
| `from_currency` | USD, GBP, EUR, AUD, CAD |
| `country_code` | AU, CA, DE, FR, IT, NL, GB, US |
| `status` | Active, Closed, Restructured |

