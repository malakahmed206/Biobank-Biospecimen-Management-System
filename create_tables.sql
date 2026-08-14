-- =====================================================================
-- Biobank and Biospecimen Management System
-- create_tables.sql  -- DDL: tables, keys, and constraints
-- Target DBMS: PostgreSQL (adjust AUTO_INCREMENT/SERIAL syntax for MySQL)
-- =====================================================================

DROP TABLE IF EXISTS SampleUsage CASCADE;
DROP TABLE IF EXISTS TestRequest CASCADE;
DROP TABLE IF EXISTS Aliquot CASCADE;
DROP TABLE IF EXISTS Sample CASCADE;
DROP TABLE IF EXISTS StorageLocation CASCADE;
DROP TABLE IF EXISTS SampleType CASCADE;
DROP TABLE IF EXISTS CollectionEvent CASCADE;
DROP TABLE IF EXISTS ConsentForm CASCADE;
DROP TABLE IF EXISTS Researcher CASCADE;
DROP TABLE IF EXISTS Donor CASCADE;

-- ---------------------------------------------------------------------
-- Donor: anonymized identifiers only, no direct patient names required
-- ---------------------------------------------------------------------
CREATE TABLE Donor (
    donor_id        SERIAL PRIMARY KEY,
    donor_code      VARCHAR(20)  NOT NULL UNIQUE,           -- anonymized public code
    date_of_birth   DATE         NOT NULL,
    sex             VARCHAR(10)  NOT NULL CHECK (sex IN ('Male','Female','Other','Unknown')),
    contact_email   VARCHAR(120),
    enrollment_date DATE         NOT NULL DEFAULT CURRENT_DATE
);

-- ---------------------------------------------------------------------
-- Researcher
-- ---------------------------------------------------------------------
CREATE TABLE Researcher (
    researcher_id   SERIAL PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    department      VARCHAR(100) NOT NULL,
    email           VARCHAR(120) NOT NULL UNIQUE
);

-- ---------------------------------------------------------------------
-- ConsentForm: 1 donor -> many consent forms (renewals, withdrawals)
-- ---------------------------------------------------------------------
CREATE TABLE ConsentForm (
    consent_id      SERIAL PRIMARY KEY,
    donor_id        INT NOT NULL REFERENCES Donor(donor_id) ON DELETE CASCADE,
    consent_type    VARCHAR(50) NOT NULL CHECK (consent_type IN ('Research','Commercial','Broad','Restricted')),
    date_signed     DATE NOT NULL,
    expiry_date     DATE,
    status          VARCHAR(20) NOT NULL DEFAULT 'Active' CHECK (status IN ('Active','Withdrawn','Expired')),
    CONSTRAINT chk_consent_dates CHECK (expiry_date IS NULL OR expiry_date > date_signed)
);

-- ---------------------------------------------------------------------
-- CollectionEvent: a visit/session during which sample(s) are collected
-- ---------------------------------------------------------------------
CREATE TABLE CollectionEvent (
    event_id        SERIAL PRIMARY KEY,
    donor_id        INT NOT NULL REFERENCES Donor(donor_id) ON DELETE CASCADE,
    collected_by    INT NOT NULL REFERENCES Researcher(researcher_id),
    event_date      DATE NOT NULL,
    location        VARCHAR(100) NOT NULL
);

-- ---------------------------------------------------------------------
-- SampleType: lookup table (blood, saliva, tissue, plasma, ...)
-- ---------------------------------------------------------------------
CREATE TABLE SampleType (
    sample_type_id      SERIAL PRIMARY KEY,
    type_name            VARCHAR(50) NOT NULL UNIQUE,
    storage_requirements VARCHAR(100) NOT NULL
);

-- ---------------------------------------------------------------------
-- Sample: physical specimen collected during a CollectionEvent
-- ---------------------------------------------------------------------
CREATE TABLE Sample (
    sample_id       SERIAL PRIMARY KEY,
    donor_id        INT NOT NULL REFERENCES Donor(donor_id) ON DELETE CASCADE,
    sample_type_id  INT NOT NULL REFERENCES SampleType(sample_type_id),
    event_id        INT NOT NULL REFERENCES CollectionEvent(event_id) ON DELETE CASCADE,
    collection_date DATE NOT NULL,
    volume_ml       DECIMAL(6,2) NOT NULL CHECK (volume_ml > 0),
    status          VARCHAR(20) NOT NULL DEFAULT 'Available'
                      CHECK (status IN ('Available','Depleted','Quarantined','Disposed'))
);

-- ---------------------------------------------------------------------
-- StorageLocation: physical freezer/rack/position
-- ---------------------------------------------------------------------
CREATE TABLE StorageLocation (
    location_id     SERIAL PRIMARY KEY,
    freezer_id      VARCHAR(20) NOT NULL,
    shelf           VARCHAR(10) NOT NULL,
    rack            VARCHAR(10) NOT NULL,
    position         VARCHAR(10) NOT NULL,
    temperature_c   DECIMAL(5,1) NOT NULL,
    UNIQUE (freezer_id, shelf, rack, position)
);

-- ---------------------------------------------------------------------
-- Aliquot: a sample is split into one or more aliquots for storage/use
-- ---------------------------------------------------------------------
CREATE TABLE Aliquot (
    aliquot_id      SERIAL PRIMARY KEY,
    sample_id       INT NOT NULL REFERENCES Sample(sample_id) ON DELETE CASCADE,
    location_id     INT NOT NULL REFERENCES StorageLocation(location_id),
    volume_ml       DECIMAL(6,2) NOT NULL CHECK (volume_ml > 0),
    creation_date   DATE NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'Stored'
                      CHECK (status IN ('Stored','InUse','Depleted','Discarded'))
);

-- ---------------------------------------------------------------------
-- TestRequest: a researcher requests testing/analysis on a sample
-- ---------------------------------------------------------------------
CREATE TABLE TestRequest (
    request_id      SERIAL PRIMARY KEY,
    sample_id       INT NOT NULL REFERENCES Sample(sample_id) ON DELETE CASCADE,
    researcher_id   INT NOT NULL REFERENCES Researcher(researcher_id),
    test_type       VARCHAR(80) NOT NULL,
    request_date    DATE NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'Pending'
                      CHECK (status IN ('Pending','Approved','Completed','Rejected'))
);

-- ---------------------------------------------------------------------
-- SampleUsage: associative table resolving the M:N relationship
-- between Aliquot and TestRequest (each usage event consumes part of
-- an aliquot to fulfil a specific test request)
-- ---------------------------------------------------------------------
CREATE TABLE SampleUsage (
    usage_id          SERIAL PRIMARY KEY,
    aliquot_id        INT NOT NULL REFERENCES Aliquot(aliquot_id) ON DELETE CASCADE,
    request_id        INT NOT NULL REFERENCES TestRequest(request_id) ON DELETE CASCADE,
    usage_date        DATE NOT NULL,
    quantity_used_ml  DECIMAL(6,2) NOT NULL CHECK (quantity_used_ml > 0),
    purpose           VARCHAR(150),
    UNIQUE (aliquot_id, request_id, usage_date)
);

-- Helpful indexes for frequent lookups / joins
CREATE INDEX idx_sample_donor        ON Sample(donor_id);
CREATE INDEX idx_aliquot_sample      ON Aliquot(sample_id);
CREATE INDEX idx_testrequest_sample  ON TestRequest(sample_id);
CREATE INDEX idx_usage_aliquot       ON SampleUsage(aliquot_id);
CREATE INDEX idx_usage_request       ON SampleUsage(request_id);
