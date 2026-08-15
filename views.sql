-- ============================================================
-- views_mssql.sql
-- Views for the Biobank and Biospecimen Management System
-- Microsoft SQL Server / T-SQL
-- ============================================================

USE biobank;
GO

SET NOCOUNT ON;
GO


-- ============================================================
-- VIEW 1
-- Donors enrolled in 2022
-- Based on Query 1
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_donors_2022
AS
SELECT
    donor_id,
    donor_code,
    sex,
    enrollment_date
FROM dbo.Donor
WHERE YEAR(enrollment_date) = 2022;
GO


-- ============================================================
-- VIEW 2
-- Complete sample information
-- Donor + Sample Type + Status
-- Based on Query 2
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_sample_overview
AS
SELECT
    s.sample_id,
    d.donor_code,
    st.type_name,
    s.collection_date,
    s.status
FROM dbo.Sample s
JOIN dbo.Donor d
    ON s.donor_id = d.donor_id
JOIN dbo.SampleType st
    ON s.sample_type_id = st.sample_type_id;
GO


-- ============================================================
-- VIEW 3
-- Aliquot storage information
-- Sample + Donor + Type + Storage Location
-- Based on Query 3
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_aliquot_storage
AS
SELECT
    a.aliquot_id,
    a.sample_id,
    d.donor_code,
    st.type_name,
    sl.freezer_id,
    sl.shelf,
    sl.rack,
    sl.position,
    sl.temperature_c,
    a.volume_ml,
    a.status
FROM dbo.Aliquot a
JOIN dbo.Sample s
    ON a.sample_id = s.sample_id
JOIN dbo.Donor d
    ON s.donor_id = d.donor_id
JOIN dbo.SampleType st
    ON s.sample_type_id = st.sample_type_id
JOIN dbo.StorageLocation sl
    ON a.location_id = sl.location_id;
GO


-- ============================================================
-- VIEW 4
-- Number of samples per sample type
-- Based on Query 4
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_samples_by_type
AS
SELECT
    st.type_name,
    COUNT(s.sample_id) AS total_samples
FROM dbo.SampleType st
LEFT JOIN dbo.Sample s
    ON st.sample_type_id = s.sample_type_id
GROUP BY
    st.type_name;
GO


-- ============================================================
-- VIEW 5
-- Researchers with more than one test request
-- Based on Query 5
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_researcher_requests
AS
SELECT
    r.researcher_id,
    r.full_name,
    r.department,
    COUNT(tr.request_id) AS request_count
FROM dbo.Researcher r
JOIN dbo.TestRequest tr
    ON r.researcher_id = tr.researcher_id
GROUP BY
    r.researcher_id,
    r.full_name,
    r.department
HAVING COUNT(tr.request_id) > 1;
GO


-- ============================================================
-- VIEW 6
-- Donors with quarantined samples
-- Based on Query 6
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_quarantined_donors
AS
SELECT DISTINCT
    d.donor_id,
    d.donor_code
FROM dbo.Donor d
JOIN dbo.Sample s
    ON d.donor_id = s.donor_id
WHERE s.status = 'Quarantined';
GO


-- ============================================================
-- VIEW 7
-- Aliquots where more than 50% of original volume was used
-- Based on Query 7
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_aliquots_over_50_percent_used
AS
SELECT
    a.aliquot_id,
    a.sample_id,
    a.volume_ml AS original_volume_ml,
    ISNULL(
        (
            SELECT SUM(su.quantity_used_ml)
            FROM dbo.SampleUsage su
            WHERE su.aliquot_id = a.aliquot_id
        ),
        0
    ) AS total_used_ml
FROM dbo.Aliquot a
WHERE
    ISNULL(
        (
            SELECT SUM(su.quantity_used_ml)
            FROM dbo.SampleUsage su
            WHERE su.aliquot_id = a.aliquot_id
        ),
        0
    ) > 0.5 * a.volume_ml;
GO


-- ============================================================
-- VIEW 8
-- Sample types whose average volume is above
-- the overall average sample volume
-- Based on Query 8
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_high_average_volume_types
AS
SELECT
    st.type_name,
    AVG(CAST(s.volume_ml AS FLOAT)) AS avg_volume
FROM dbo.Sample s
JOIN dbo.SampleType st
    ON s.sample_type_id = st.sample_type_id
GROUP BY
    st.type_name
HAVING
    AVG(CAST(s.volume_ml AS FLOAT)) >
    (
        SELECT AVG(CAST(volume_ml AS FLOAT))
        FROM dbo.Sample
    );
GO


-- ============================================================
-- VIEW 9
-- Test requests and aliquot usage
-- Many-to-many report
-- Based on Query 9
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_test_request_usage
AS
SELECT
    tr.request_id,
    tr.test_type,
    r.full_name AS requested_by,
    SUM(su.quantity_used_ml) AS total_used_ml
FROM dbo.TestRequest tr
JOIN dbo.Researcher r
    ON tr.researcher_id = r.researcher_id
JOIN dbo.SampleUsage su
    ON tr.request_id = su.request_id
GROUP BY
    tr.request_id,
    tr.test_type,
    r.full_name;
GO


-- ============================================================
-- BONUS VIEW
-- Complete sample inventory
-- Useful for the application/demo
-- ============================================================

CREATE OR ALTER VIEW dbo.vw_sample_inventory
AS
SELECT
    s.sample_id,
    d.donor_code,
    st.type_name,
    s.collection_date,
    s.status AS sample_status,
    COUNT(a.aliquot_id) AS aliquot_count,
    ISNULL(SUM(a.volume_ml), 0) AS total_aliquot_volume_ml
FROM dbo.Sample s
JOIN dbo.Donor d
    ON s.donor_id = d.donor_id
JOIN dbo.SampleType st
    ON s.sample_type_id = st.sample_type_id
LEFT JOIN dbo.Aliquot a
    ON a.sample_id = s.sample_id
GROUP BY
    s.sample_id,
    d.donor_code,
    st.type_name,
    s.collection_date,
    s.status;
GO


-- ============================================================
-- CHECK THAT THE VIEWS WERE CREATED
-- ============================================================

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'dbo'
ORDER BY TABLE_NAME;
GO