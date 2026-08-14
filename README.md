# Biobank and Biospecimen Management System

A relational database for managing biobank operations: donors, informed
consent, sample collection, aliquoting, cold-chain storage, researcher
test requests, and sample usage tracking.

## DBMS Used
PostgreSQL (13+). All scripts use standard PostgreSQL syntax
(`SERIAL`, `plpgsql` functions/triggers). Notes on MySQL equivalents are
included as comments where syntax diverges (e.g. `views.sql`).

## Repository Structure
```
├─ README.md
├─ report.docx
├─ presentation.pptx
├─ video_link.txt
├─ diagrams/
│   ├─ erd.dot        (Graphviz source)
│   └─ ERD.png         (rendered ER diagram)
├─ sql/
│   ├─ create_tables.sql       -- DDL: tables, keys, constraints, indexes
│   ├─ load_data.sql           -- test data (>=10 rows per main table)
│   ├─ queries.sql             -- retrieval, joins, aggregation, subqueries, DML
│   ├─ views.sql                -- 2 views
│   └─ triggers_procedures.sql -- 2 triggers + 1 stored function
└─ src/                         -- optional bonus UI (not included in base submission)
```

## Entities
Donor, Researcher, ConsentForm, CollectionEvent, SampleType, Sample,
StorageLocation, Aliquot, TestRequest, SampleUsage (associative table
resolving the M:N relationship between Aliquot and TestRequest).

## How to Run
1. Create a fresh PostgreSQL database:
   ```
   createdb biobank_db
   ```
2. Load the schema:
   ```
   psql -d biobank_db -f sql/create_tables.sql
   ```
3. Load test data:
   ```
   psql -d biobank_db -f sql/load_data.sql
   ```
4. Create views and triggers/procedures:
   ```
   psql -d biobank_db -f sql/views.sql
   psql -d biobank_db -f sql/triggers_procedures.sql
   ```
5. Run sample queries:
   ```
   psql -d biobank_db -f sql/queries.sql
   ```

## Business Rules Enforced
- A sample cannot be marked in active use if the donor's consent has been withdrawn (`trg_check_consent_before_usage`).
- An aliquot automatically flips to `Depleted`/`InUse` status as usage accumulates (`trg_update_aliquot_status`).
- Consent expiry must postdate the signing date (`chk_consent_dates`).
- Volumes must be strictly positive (`CHECK` constraints on `Sample`, `Aliquot`, `SampleUsage`).

## Normalization
All tables are in 3NF: every non-key attribute depends on the whole
primary key and nothing but the key. Lookup data (sample types, storage
locations) is factored into its own table to eliminate repeating groups
and transitive dependencies (e.g. storage requirements are not
duplicated on every `Sample` row).
