-- ============================================================
-- create_tables_mssql.sql
-- Biobank and Biospecimen Management System
-- Microsoft SQL Server
-- ============================================================

SET NOCOUNT ON;
GO

-- ============================================================
-- DROP TABLES
-- ============================================================

IF OBJECT_ID('dbo.SampleUsage','U') IS NOT NULL
    DROP TABLE dbo.SampleUsage;

IF OBJECT_ID('dbo.TestRequest','U') IS NOT NULL
    DROP TABLE dbo.TestRequest;

IF OBJECT_ID('dbo.Aliquot','U') IS NOT NULL
    DROP TABLE dbo.Aliquot;

IF OBJECT_ID('dbo.Sample','U') IS NOT NULL
    DROP TABLE dbo.Sample;

IF OBJECT_ID('dbo.StorageLocation','U') IS NOT NULL
    DROP TABLE dbo.StorageLocation;

IF OBJECT_ID('dbo.SampleType','U') IS NOT NULL
    DROP TABLE dbo.SampleType;

IF OBJECT_ID('dbo.CollectionEvent','U') IS NOT NULL
    DROP TABLE dbo.CollectionEvent;

IF OBJECT_ID('dbo.ConsentForm','U') IS NOT NULL
    DROP TABLE dbo.ConsentForm;

IF OBJECT_ID('dbo.Researcher','U') IS NOT NULL
    DROP TABLE dbo.Researcher;

IF OBJECT_ID('dbo.Donor','U') IS NOT NULL
    DROP TABLE dbo.Donor;
GO


-- ============================================================
-- DONOR
-- ============================================================

CREATE TABLE dbo.Donor
(
    donor_id        INT IDENTITY(1,1) PRIMARY KEY,
    donor_code      VARCHAR(20) NOT NULL UNIQUE,
    date_of_birth   DATE NOT NULL,
    sex             VARCHAR(10) NOT NULL
                    CHECK (sex IN ('Male','Female','Other','Unknown')),
    contact_email   VARCHAR(120) NULL,
    enrollment_date DATE NOT NULL
                    DEFAULT (CAST(GETDATE() AS DATE))
);
GO


-- ============================================================
-- RESEARCHER
-- ============================================================

CREATE TABLE dbo.Researcher
(
    researcher_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    department    VARCHAR(100) NOT NULL,
    email         VARCHAR(120) NOT NULL UNIQUE
);
GO


-- ============================================================
-- CONSENT FORM
-- ============================================================

CREATE TABLE dbo.ConsentForm
(
    consent_id   INT IDENTITY(1,1) PRIMARY KEY,
    donor_id     INT NOT NULL,
    consent_type VARCHAR(50) NOT NULL
                 CHECK (consent_type IN
                 ('Research','Commercial','Broad','Restricted')),
    date_signed  DATE NOT NULL,
    expiry_date  DATE NULL,
    status       VARCHAR(20) NOT NULL DEFAULT 'Active'
                 CHECK (status IN
                 ('Active','Withdrawn','Expired')),

    CONSTRAINT FK_Consent_Donor
        FOREIGN KEY (donor_id)
        REFERENCES dbo.Donor(donor_id)
        ON DELETE CASCADE,

    CONSTRAINT chk_consent_dates_sqlserver
        CHECK (expiry_date IS NULL OR expiry_date > date_signed)
);
GO


-- ============================================================
-- COLLECTION EVENT
-- ============================================================

CREATE TABLE dbo.CollectionEvent
(
    event_id     INT IDENTITY(1,1) PRIMARY KEY,
    donor_id     INT NOT NULL,
    collected_by INT NOT NULL,
    event_date   DATE NOT NULL,
    location     VARCHAR(100) NOT NULL,

    CONSTRAINT FK_Event_Donor
        FOREIGN KEY (donor_id)
        REFERENCES dbo.Donor(donor_id)
        ON DELETE NO ACTION,

    CONSTRAINT FK_Event_Researcher
        FOREIGN KEY (collected_by)
        REFERENCES dbo.Researcher(researcher_id)
        ON DELETE NO ACTION
);
GO


-- ============================================================
-- SAMPLE TYPE
-- ============================================================

CREATE TABLE dbo.SampleType
(
    sample_type_id     INT IDENTITY(1,1) PRIMARY KEY,
    type_name          VARCHAR(50) NOT NULL UNIQUE,
    storage_requirements VARCHAR(100) NOT NULL
);
GO


-- ============================================================
-- SAMPLE
-- ============================================================

CREATE TABLE dbo.Sample
(
    sample_id       INT IDENTITY(1,1) PRIMARY KEY,
    donor_id        INT NOT NULL,
    sample_type_id  INT NOT NULL,
    event_id        INT NOT NULL,
    collection_date DATE NOT NULL,
    volume_ml       DECIMAL(6,2) NOT NULL
                    CHECK (volume_ml > 0),

    status          VARCHAR(20) NOT NULL DEFAULT 'Available'
                    CHECK (status IN
                    ('Available','Depleted','Quarantined','Disposed')),

    CONSTRAINT FK_Sample_Donor
        FOREIGN KEY (donor_id)
        REFERENCES dbo.Donor(donor_id)
        ON DELETE NO ACTION,

    CONSTRAINT FK_Sample_SampleType
        FOREIGN KEY (sample_type_id)
        REFERENCES dbo.SampleType(sample_type_id)
        ON DELETE NO ACTION,

    CONSTRAINT FK_Sample_Event
        FOREIGN KEY (event_id)
        REFERENCES dbo.CollectionEvent(event_id)
        ON DELETE NO ACTION
);
GO


-- ============================================================
-- STORAGE LOCATION
-- ============================================================

CREATE TABLE dbo.StorageLocation
(
    location_id   INT IDENTITY(1,1) PRIMARY KEY,
    freezer_id    VARCHAR(20) NOT NULL,
    shelf         VARCHAR(10) NOT NULL,
    rack          VARCHAR(10) NOT NULL,
    position      VARCHAR(10) NOT NULL,
    temperature_c DECIMAL(5,1) NOT NULL,

    CONSTRAINT UQ_StorageLocation
        UNIQUE (freezer_id, shelf, rack, position)
);
GO


-- ============================================================
-- ALIQUOT
-- ============================================================

CREATE TABLE dbo.Aliquot
(
    aliquot_id    INT IDENTITY(1,1) PRIMARY KEY,
    sample_id     INT NOT NULL,
    location_id   INT NOT NULL,
    volume_ml     DECIMAL(6,2) NOT NULL
                  CHECK (volume_ml > 0),
    creation_date DATE NOT NULL,

    status        VARCHAR(20) NOT NULL DEFAULT 'Stored'
                  CHECK (status IN
                  ('Stored','InUse','Depleted','Discarded')),

    CONSTRAINT FK_Aliquot_Sample
        FOREIGN KEY (sample_id)
        REFERENCES dbo.Sample(sample_id)
        ON DELETE CASCADE,

    CONSTRAINT FK_Aliquot_Storage
        FOREIGN KEY (location_id)
        REFERENCES dbo.StorageLocation(location_id)
        ON DELETE NO ACTION
);
GO


-- ============================================================
-- TEST REQUEST
-- ============================================================

CREATE TABLE dbo.TestRequest
(
    request_id   INT IDENTITY(1,1) PRIMARY KEY,
    sample_id    INT NOT NULL,
    researcher_id INT NOT NULL,
    test_type    VARCHAR(80) NOT NULL,
    request_date DATE NOT NULL,

    status       VARCHAR(20) NOT NULL DEFAULT 'Pending'
                 CHECK (status IN
                 ('Pending','Approved','Completed','Rejected')),

    CONSTRAINT FK_Request_Sample
        FOREIGN KEY (sample_id)
        REFERENCES dbo.Sample(sample_id)
        ON DELETE NO ACTION,

    CONSTRAINT FK_Request_Researcher
        FOREIGN KEY (researcher_id)
        REFERENCES dbo.Researcher(researcher_id)
        ON DELETE NO ACTION
);
GO


-- ============================================================
-- SAMPLE USAGE
-- ============================================================

CREATE TABLE dbo.SampleUsage
(
    usage_id          INT IDENTITY(1,1) PRIMARY KEY,
    aliquot_id        INT NOT NULL,
    request_id        INT NOT NULL,
    usage_date        DATE NOT NULL,
    quantity_used_ml  DECIMAL(6,2) NOT NULL
                      CHECK (quantity_used_ml > 0),
    purpose           VARCHAR(150) NULL,

    CONSTRAINT FK_Usage_Aliquot
        FOREIGN KEY (aliquot_id)
        REFERENCES dbo.Aliquot(aliquot_id)
        ON DELETE CASCADE,

    CONSTRAINT FK_Usage_Request
        FOREIGN KEY (request_id)
        REFERENCES dbo.TestRequest(request_id)
        ON DELETE NO ACTION,

    CONSTRAINT UQ_Usage
        UNIQUE (aliquot_id, request_id, usage_date)
);
GO


-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_sample_donor
    ON dbo.Sample(donor_id);

CREATE INDEX idx_aliquot_sample
    ON dbo.Aliquot(sample_id);

CREATE INDEX idx_testrequest_sample
    ON dbo.TestRequest(sample_id);

CREATE INDEX idx_usage_aliquot
    ON dbo.SampleUsage(aliquot_id);

CREATE INDEX idx_usage_request
    ON dbo.SampleUsage(request_id);
GO


-- ============================================================
-- CHECK THAT ALL TABLES WERE CREATED
-- ============================================================

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN
  (
      'Donor',
      'Researcher',
      'ConsentForm',
      'CollectionEvent',
      'SampleType',
      'Sample',
      'StorageLocation',
      'Aliquot',
      'TestRequest',
      'SampleUsage'
  )
ORDER BY TABLE_NAME;
GO