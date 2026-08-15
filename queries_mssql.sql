-- queries_mssql.sql
-- Useful queries and reports (T-SQL)
SET NOCOUNT ON;
GO

-- 1. Simple retrieval: all active donors enrolled in 2022
SELECT donor_id, donor_code, sex, enrollment_date
FROM dbo.Donor
WHERE YEAR(enrollment_date) = 2022
ORDER BY enrollment_date;
GO

-- 2. Join: list every sample with its donor code, type, and storage status
SELECT s.sample_id, d.donor_code, st.type_name, s.collection_date, s.status
FROM dbo.Sample s
JOIN dbo.Donor d       ON s.donor_id = d.donor_id
JOIN dbo.SampleType st ON s.sample_type_id = st.sample_type_id
ORDER BY s.collection_date;
GO

-- 3. Multi-table join: aliquots with their sample, donor, and storage location
SELECT a.aliquot_id, d.donor_code, st.type_name, sl.freezer_id, sl.shelf, sl.rack, a.status
FROM dbo.Aliquot a
JOIN dbo.Sample s        ON a.sample_id = s.sample_id
JOIN dbo.Donor d          ON s.donor_id = d.donor_id
JOIN dbo.SampleType st    ON s.sample_type_id = st.sample_type_id
JOIN dbo.StorageLocation sl ON a.location_id = sl.location_id
ORDER BY sl.freezer_id, sl.shelf, sl.rack;
GO

-- 4. Aggregation: number of samples collected per sample type
SELECT st.type_name, COUNT(s.sample_id) AS total_samples
FROM dbo.SampleType st
LEFT JOIN dbo.Sample s ON st.sample_type_id = s.sample_type_id
GROUP BY st.type_name
ORDER BY total_samples DESC;
GO

-- 5. Aggregation with HAVING: researchers who have submitted more than 1 test request
SELECT r.full_name, r.department, COUNT(tr.request_id) AS request_count
FROM dbo.Researcher r
JOIN dbo.TestRequest tr ON r.researcher_id = tr.researcher_id
GROUP BY r.full_name, r.department
HAVING COUNT(tr.request_id) > 1
ORDER BY request_count DESC;
GO

-- 6. Subquery: donors who have at least one sample currently "Quarantined"
SELECT donor_code
FROM dbo.Donor
WHERE donor_id IN (
    SELECT donor_id FROM dbo.Sample WHERE status = 'Quarantined'
);
GO

-- 7. Correlated subquery: aliquots whose used volume
--    exceeds 50% of the aliquot's original volume
SELECT a.aliquot_id, a.volume_ml
FROM dbo.Aliquot a
WHERE (
    SELECT ISNULL(SUM(su.quantity_used_ml), 0)
    FROM dbo.SampleUsage su
    WHERE su.aliquot_id = a.aliquot_id
) > 0.5 * a.volume_ml;
GO

-- 8. Nested query with aggregate: sample types whose average sample volume
--    is above the overall average sample volume
SELECT st.type_name, AVG(CAST(s.volume_ml AS FLOAT)) AS avg_volume
FROM dbo.Sample s
JOIN dbo.SampleType st ON s.sample_type_id = st.sample_type_id
GROUP BY st.type_name
HAVING AVG(CAST(s.volume_ml AS FLOAT)) > (SELECT AVG(CAST(volume_ml AS FLOAT)) FROM dbo.Sample);
GO

-- 9. Many-to-many report: which test requests consumed which aliquots,
--    with total quantity used per request
SELECT tr.request_id, tr.test_type, r.full_name AS requested_by,
       SUM(su.quantity_used_ml) AS total_used_ml
FROM dbo.TestRequest tr
JOIN dbo.Researcher r  ON tr.researcher_id = r.researcher_id
JOIN dbo.SampleUsage su ON tr.request_id = su.request_id
GROUP BY tr.request_id, tr.test_type, r.full_name
ORDER BY tr.request_id;
GO

-- 10. Example INSERT + consent create (use in application logic)
-- INSERT INTO dbo.Donor (donor_code, date_of_birth, sex, contact_email, enrollment_date)
-- VALUES ('DNR-0011','1999-04-02','Female','d0011@example.org', CAST(GETDATE() AS DATE));
--
-- INSERT INTO dbo.ConsentForm (donor_id, consent_type, date_signed, expiry_date, status)
-- VALUES ((SELECT donor_id FROM dbo.Donor WHERE donor_code = 'DNR-0011'), 'Broad', CAST(GETDATE() AS DATE), DATEADD(year,5,CAST(GETDATE() AS DATE)), 'Active');
GO
