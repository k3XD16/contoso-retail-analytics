# Snowflake setup guide

All the commands used in this guide can be executed in the Snowflake worksheet. You can access the worksheet by logging into your Snowflake account and navigating to the "Worksheets" tab.

I have been provided in the `example_profiles.yml` file and should be set as environment variables on your local machine or CI/CD environment to ensure secure handling of sensitive information.

Note: Make sure to replace the placeholders in the commands with your actual Snowflake account details.

## Snowflake Account Creation (Quick Steps)
If you don't have a Snowflake account, you can create one by following these steps:
1. Go to https://signup.snowflake.com → Click Start for free
1. Enter firstname, lastname, work email (can be Personal), why are you signing up (just choose one)
1. Choose:
    - Cloud → AWS (recommended)
    - Region → Choose the one closest to you
1. Verify your email
1. Create username & password
1. Save your account URL (important)
1. Login via URL → Opens Snowsight UI



## Creating Warehouse

Create a warehouse for dbt to use when connecting to Snowflake. This warehouse will be used for running dbt models and should be sized according to your needs. In this example, we are creating an XSMALL warehouse.

```SQL
CREATE WAREHOUSE DEV_CONTOSO_DBT_WH_XS
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Warehouse for Contoso retail analytics project';
```

## Creating Database
Create a database for the Contoso retail analytics project. This database will contain all the schemas and tables for the project.

```SQL
CREATE DATABASE DEV_CONTOSO_RETAIL
  COMMENT = 'Database for Contoso retail analytics project';
```

## Creating Schemas
Here we create three schemas for the different layers of our data architecture: Bronze, Silver, and Gold. Each schema will have a comment describing its purpose.

```SQL
CREATE SCHEMA DEV_CONTOSO_RETAIL.BRONZE
  COMMENT = 'Raw ingested layer from S3';

CREATE SCHEMA DEV_CONTOSO_RETAIL.SILVER
  COMMENT = 'Cleaned and transformed layer';

CREATE SCHEMA DEV_CONTOSO_RETAIL.GOLD
  COMMENT = 'Curated analytics layer for marts and reporting';

CREATE SCHEMA IF NOT EXISTS DEV_CONTOSO_RETAIL.SNAPSHOTS
  COMMENT = 'Snapshot layer for data versioning and auditing';
```

## Creating Role
Here we create a role for dbt to use when connecting to Snowflake. This role will be granted the necessary privileges to manage the database and warehouse.

```SQL
CREATE ROLE DEV_CONTOSO_DBT_ROLE;
```

## Granting Privileges to Role
Here we grant the necessary privileges to the role for it to be able to create and manage tables in the database, as well as use the warehouse.

```SQL
GRANT USAGE ON WAREHOUSE DEV_CONTOSO_DBT_WH_XS TO ROLE DEV_CONTOSO_DBT_ROLE;
GRANT USAGE ON DATABASE DEV_CONTOSO_RETAIL TO ROLE DEV_CONTOSO_DBT_ROLE;
GRANT ALL ON SCHEMA DEV_CONTOSO_RETAIL.BRONZE TO ROLE DEV_CONTOSO_DBT_ROLE;
GRANT ALL ON SCHEMA DEV_CONTOSO_RETAIL.SILVER TO ROLE DEV_CONTOSO_DBT_ROLE;
GRANT ALL ON SCHEMA DEV_CONTOSO_RETAIL.GOLD TO ROLE DEV_CONTOSO_DBT_ROLE;
```

## Creating User
Create a user for dbt with the following command. Make sure to replace the password with a secure one.

```SQL
CREATE USER DEV_CONTOSO_DBT_USER
  PASSWORD = 'XXXXXXXXXXXXXXXX'
  DEFAULT_ROLE = DEV_CONTOSO_DBT_ROLE
  DEFAULT_WAREHOUSE = DEV_CONTOSO_DBT_WH_XS
  MUST_CHANGE_PASSWORD = FALSE;
```

## Granting Role to User
You can grant the role to the user with the following command:

```SQL
GRANT ROLE DEV_CONTOSO_DBT_ROLE TO USER DEV_CONTOSO_DBT_USER;
```

## Change from ACCOUNTADMIN to `DEV_CONTOSO_DBT_USER` and verify privileges
you can change to the `DEV_CONTOSO_DBT_USER` role and verify that you have the necessary privileges to access the warehouse, database, and schemas. You can do this by running the following commands:

```SQL
USE ROLE DEV_CONTOSO_DBT_ROLE;

USE WAREHOUSE DEV_CONTOSO_DBT_WH_XS;

USE DATABASE DEV_CONTOSO_RETAIL;

USE SCHEMA BRONZE;
```

## Granting schema privilegest to role
Grant the necessary privileges to the role for it to be able to create and manage tables in the Bronze schema.

```SQL
-- Grant SELECT on ALL existing tables in Bronze schema
GRANT SELECT ON ALL TABLES IN SCHEMA DEV_CONTOSO_RETAIL.BRONZE TO ROLE DEV_CONTOSO_DBT_ROLE;

-- Grant SELECT on ALL future tables in Bronze schema  
GRANT SELECT ON FUTURE TABLES IN SCHEMA DEV_CONTOSO_RETAIL.BRONZE TO ROLE DEV_CONTOSO_DBT_ROLE;

-- Same for Silver and Gold (if you create tables there)
GRANT SELECT ON ALL TABLES IN SCHEMA DEV_CONTOSO_RETAIL.SILVER TO ROLE DEV_CONTOSO_DBT_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA DEV_CONTOSO_RETAIL.SILVER TO ROLE DEV_CONTOSO_DBT_ROLE;

GRANT SELECT ON ALL TABLES IN SCHEMA DEV_CONTOSO_RETAIL.GOLD TO ROLE DEV_CONTOSO_DBT_ROLE;
GRANT SELECT ON FUTURE TABLES IN SCHEMA DEV_CONTOSO_RETAIL.GOLD TO ROLE DEV_CONTOSO_DBT_ROLE;

-- Grant all privileges on the SNAPSHOTS schema to the role
GRANT ALL ON SCHEMA DEV_CONTOSO_RETAIL.SNAPSHOTS TO ROLE DEV_CONTOSO_DBT_ROLE;
```

## Creating File Format

create a file format in Snowflake to specify how the raw data files in S3 should be parsed when they are ingested into the Bronze schema. In this example, we are creating a file format for CSV files with specific settings.

```SQL
CREATE OR REPLACE FILE FORMAT FF_CSV_CONTOSO
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  TRIM_SPACE = TRUE
  EMPTY_FIELD_AS_NULL = TRUE
  NULL_IF = ('NULL', 'null', '')
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;
```

## Creating Storage Integration
To allow Snowflake to access data stored in S3, we need to create a storage integration. This integration will define the necessary credentials and permissions for Snowflake to read from and write to the S3 bucket where our raw data is stored.

```SQL
CREATE OR REPLACE STORAGE INTEGRATION S3_CONTOSO_INTEGRATION
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<account-id>:role/SnowS3Integration'
  STORAGE_ALLOWED_LOCATIONS = ('s3://contoso-dataset/source/');
```

## Creating Stage

Creating the stage in Snowflake to define the location of the raw data files in S3 and associate it with the file format and storage integration we created earlier. This stage will be used by dbt to load data into the Bronze schema.

```SQL
CREATE OR REPLACE STAGE CONTOSO_S3_STAGE
  URL = 's3://contoso-dataset/source/'
  STORAGE_INTEGRATION = S3_CONTOSO_INTEGRATION
  FILE_FORMAT = FF_CSV_CONTOSO;
```

## Listing files in the stage:

Using following commands, you can list the files in the stage to verify that Snowflake can access the data in S3:

```SQL
LIST @CONTOSO_S3_STAGE;
```

## DDL commands for creating tables in Snowflake

Now, we are creating the tables in snowflake for the Bronze layer. These tables will be used to store the raw data ingested from S3. 

```SQL
-- Table 1: Orders
CREATE OR REPLACE TABLE BRONZE_ORDERS (
    OrderKey NUMBER,
    CustomerKey NUMBER,
    StoreKey NUMBER,
    OrderDate DATE,
    DeliveryDate DATE,
    CurrencyCode VARCHAR(10)
);

-- Table 2: Order Rows (Line Items)
DROP TABLE IF EXISTS BRONZE_ORDERSROWS;
CREATE OR REPLACE TABLE BRONZE_ORDERROWS (
    OrderKey NUMBER,
    LineNumber NUMBER,
    ProductKey NUMBER,
    Quantity NUMBER,
    UnitPrice NUMBER(18,5),
    NetPrice NUMBER(18,5),
    UnitCost NUMBER(18,5)
);


-- Table 3: Customers

DROP TABLE BRONZE_CUSTOMER CASCADE
CREATE OR REPLACE TABLE BRONZE_CUSTOMER (
    CustomerKey NUMBER,
    GeoAreaKey NUMBER,
    StartDT DATE,
    EndDT DATE,
    Continent VARCHAR(50),
    Gender VARCHAR(20),
    Title VARCHAR(20),
    GivenName VARCHAR(100),
    MiddleInitial VARCHAR(10),
    Surname VARCHAR(100),
    StreetAddress VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(50),
    StateFull VARCHAR(100),
    ZipCode VARCHAR(20),
    Country VARCHAR(10),
    CountryFull VARCHAR(100),
    Birthday DATE,
    Age NUMBER,
    Occupation VARCHAR(255),
    Company VARCHAR(255),
    Vehicle VARCHAR(255),
    Latitude FLOAT,
    Longitude FLOAT
);


CREATE OR REPLACE TABLE BRONZE_CUSTOMER (
    CustomerKey     INT,
    GeoAreaKey      INT,
    StartDT         VARCHAR(20),
    EndDT           VARCHAR(20),
    Continent       VARCHAR(50),
    Gender          VARCHAR(10),
    Title           VARCHAR(10),
    GivenName       VARCHAR(50),
    MiddleInitial   VARCHAR(5),
    Surname         VARCHAR(50),
    StreetAddress   VARCHAR(200),
    City            VARCHAR(50),
    State           VARCHAR(50),
    StateFull       VARCHAR(50),
    ZipCode         VARCHAR(20),
    Country         VARCHAR(10),
    CountryFull     VARCHAR(50),
    Birthday        VARCHAR(20),
    Age             INT,
    Occupation      VARCHAR(100),
    Company         VARCHAR(200),
    Vehicle         VARCHAR(200),
    Latitude        FLOAT,
    Longitude       FLOAT
);


-- Table 4: Products
CREATE OR REPLACE TABLE BRONZE_PRODUCT (
    ProductKey NUMBER,
    ProductCode VARCHAR(20),
    ProductName VARCHAR(255),
    Manufacturer VARCHAR(255),
    Brand VARCHAR(100),
    Color VARCHAR(50),
    WeightUnit VARCHAR(20),
    Weight FLOAT,
    Cost NUMBER(18,2),
    Price NUMBER(18,2),
    CategoryKey NUMBER,
    CategoryName VARCHAR(100),
    SubCategoryKey NUMBER,
    SubCategoryName VARCHAR(100)
);

-- Table 5: Stores
CREATE OR REPLACE TABLE BRONZE_STORE (
    StoreKey NUMBER,
    StoreCode NUMBER,
    GeoAreaKey NUMBER,
    CountryCode VARCHAR(10),
    CountryName VARCHAR(100),
    State VARCHAR(100),
    OpenDate DATE,
    CloseDate DATE,
    Description VARCHAR(255),
    SquareMeters NUMBER,
    Status VARCHAR(50)
);


-- Table 6: Date Dimension
CREATE OR REPLACE TABLE BRONZE_DATE (
    DATE_VALUE DATE,
    DateKey NUMBER,
    Year NUMBER,
    YearQuarter VARCHAR(20),
    YearQuarterNumber NUMBER,
    Quarter VARCHAR(10),
    YearMonth VARCHAR(30),
    YearMonthShort VARCHAR(20),
    YearMonthNumber NUMBER,
    Month VARCHAR(20),
    MonthShort VARCHAR(10),
    MonthNumber NUMBER,
    DayofWeek VARCHAR(20),
    DayofWeekShort VARCHAR(10),
    DayofWeekNumber NUMBER,
    WorkingDay NUMBER,
    WorkingDayNumber NUMBER
);


-- Table 7: Currency Exchange
CREATE TABLE BRONZE_CURRENCYEXCHANGE (
    EXCHANGE_DATE  DATE,
    FROM_CURRENCY  VARCHAR(10),
    TO_CURRENCY    VARCHAR(10),
    EXCHANGE       NUMBER(18,5)
);
```

## COPY INTO command to load data from S3 to Snowflake

Finally, we can use the COPY INTO command to load the raw data from the S3 stage into the Bronze tables in Snowflake. This command will read the files from the stage, parse them according to the file format, and insert the data into the corresponding tables.

```SQL
-- COPY raw data into bronze layer

COPY INTO BRONZE_ORDERS
FROM @CONTOSO_S3_STAGE/orders.csv
FILE_FORMAT = (FORMAT_NAME = FF_CSV_CONTOSO)
ON_ERROR = 'CONTINUE';

COPY INTO BRONZE_ORDERROWS
FROM @CONTOSO_S3_STAGE/orderrows.csv
FILE_FORMAT = (FORMAT_NAME = FF_CSV_CONTOSO)
ON_ERROR = 'CONTINUE';

COPY INTO BRONZE_CUSTOMER
FROM @CONTOSO_S3_STAGE/customer.csv
FILE_FORMAT = (FORMAT_NAME = FF_CSV_CONTOSO)
ON_ERROR = 'CONTINUE';

COPY INTO BRONZE_PRODUCT
FROM @CONTOSO_S3_STAGE/product.csv
FILE_FORMAT = (FORMAT_NAME = FF_CSV_CONTOSO)
ON_ERROR = 'CONTINUE';

COPY INTO BRONZE_STORE
FROM @CONTOSO_S3_STAGE/store.csv
FILE_FORMAT = (FORMAT_NAME = FF_CSV_CONTOSO)
ON_ERROR = 'CONTINUE';

COPY INTO BRONZE_DATE
FROM @CONTOSO_S3_STAGE/date.csv
FILE_FORMAT = (FORMAT_NAME = FF_CSV_CONTOSO)
ON_ERROR = 'CONTINUE';

COPY INTO BRONZE_CURRENCYEXCHANGE
FROM @CONTOSO_S3_STAGE/currencyexchange.csv
FILE_FORMAT = (FORMAT_NAME = FF_CSV_CONTOSO)
ON_ERROR = 'CONTINUE';
```

## Conclusion

By following the steps outlined in this guide, you have successfully set up your Snowflake environment for the Contoso retail analytics project. You have created the necessary warehouse, database, schemas, role, user, file format, storage integration, and stage to enable dbt to connect to Snowflake and manage your data transformations effectively. You have also loaded the raw data from S3 into the Bronze layer in Snowflake, which is now ready for further processing and transformation using dbt.

