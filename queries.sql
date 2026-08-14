-- =====================================================================
-- queries.sql -- Required SQL operations
-- =====================================================================

-- 1. Simple retrieval: all active donors enrolled in 2022
SELECT donor_id, donor_code, sex, enrollment_date
FROM Donor
WHERE EXTRACT(YEAR FROM enrollment_date) = 2022
ORDER BY enrollment_date;

-- 2. Join: list every sample with its donor code, type, and storage status
SELECT s.sample_id, d.donor_code, st.type_name, s.collection_date, s.status
FROM Sample s
JOIN Donor d       ON s.donor_id = d.donor_id
JOIN SampleType st ON s.sample_type_id = st.sample_type_id
ORDER BY s.collection_date;

-- 3. Multi-table join: aliquots with their sample, donor, and storage location
SELECT a.aliquot_id, d.donor_code, st.type_name, sl.freezer_id, sl.shelf, sl.rack, a.status
FROM Aliquot a
JOIN Sample s        ON a.sample_id = s.sample_id
JOIN Donor d          ON s.donor_id = d.donor_id
JOIN SampleType st    ON s.sample_type_id = st.sample_type_id
JOIN StorageLocation sl ON a.location_id = sl.location_id
ORDER BY sl.freezer_id, sl.shelf, sl.rack;

-- 4. Aggregation: number of samples collected per sample type
SELECT st.type_name, COUNT(s.sample_id) AS total_samples
FROM SampleType st
LEFT JOIN Sample s ON st.sample_type_id = s.sample_type_id
GROUP BY st.type_name
ORDER BY total_samples DESC;

-- 5. Aggregation with HAVING: researchers who have submitted more than 1 test request
SELECT r.full_name, r.department, COUNT(tr.request_id) AS request_count
FROM Researcher r
JOIN TestRequest tr ON r.researcher_id = tr.researcher_id
GROUP BY r.full_name, r.department
HAVING COUNT(tr.request_id) > 1
ORDER BY request_count DESC;

-- 6. Subquery: donors who have at least one sample currently "Quarantined"
SELECT donor_code
FROM Donor
WHERE donor_id IN (
    SELECT donor_id FROM Sample WHERE status = 'Quarantined'
);

-- 7. Correlated subquery: aliquots whose used volume (via SampleUsage)
--    exceeds 50% of the aliquot's original volume
SELECT a.aliquot_id, a.volume_ml
FROM Aliquot a
WHERE (
    SELECT COALESCE(SUM(su.quantity_used_ml), 0)
    FROM SampleUsage su
    WHERE su.aliquot_id = a.aliquot_id
) > 0.5 * a.volume_ml;

-- 8. Nested query with aggregate: sample types whose average sample volume
--    is above the overall average sample volume
SELECT st.type_name, AVG(s.volume_ml) AS avg_volume
FROM Sample s
JOIN SampleType st ON s.sample_type_id = st.sample_type_id
GROUP BY st.type_name
HAVING AVG(s.volume_ml) > (SELECT AVG(volume_ml) FROM Sample);

-- 9. Many-to-many report: which test requests consumed which aliquots,
--    with total quantity used per request
SELECT tr.request_id, tr.test_type, r.full_name AS requested_by,
       SUM(su.quantity_used_ml) AS total_used_ml
FROM TestRequest tr
JOIN Researcher r  ON tr.researcher_id = r.researcher_id
JOIN SampleUsage su ON tr.request_id = su.request_id
GROUP BY tr.request_id, tr.test_type, r.full_name
ORDER BY tr.request_id;

-- 10. INSERT: register a new donor and their first consent form
INSERT INTO Donor (donor_code, date_of_birth, sex, contact_email, enrollment_date)
VALUES ('DNR-0011','1999-04-02','Female','d0011@example.org', CURRENT_DATE);

INSERT INTO ConsentForm (donor_id, consent_type, date_signed, expiry_date, status)
VALUES (
    (SELECT donor_id FROM Donor WHERE donor_code = 'DNR-0011'),
    'Broad', CURRENT_DATE, CURRENT_DATE + INTERVAL '5 years', 'Active'
);

-- 11. UPDATE: mark a sample as Depleted once all its aliquots are Discarded/Depleted
UPDATE Sample
SET status = 'Depleted'
WHERE sample_id = 9
  AND NOT EXISTS (
      SELECT 1 FROM Aliquot a
      WHERE a.sample_id = Sample.sample_id
        AND a.status NOT IN ('Depleted','Discarded')
  );

-- 12. UPDATE: withdraw a donor's consent and cascade a note (business rule
--     enforcement is also handled by trigger trg_consent_withdrawal, see
--     triggers_procedures.sql)
UPDATE ConsentForm
SET status = 'Withdrawn'
WHERE consent_id = 8;

-- 13. DELETE: remove a rejected test request that has no recorded usage
DELETE FROM TestRequest
WHERE status = 'Rejected'
  AND request_id NOT IN (SELECT DISTINCT request_id FROM SampleUsage);
