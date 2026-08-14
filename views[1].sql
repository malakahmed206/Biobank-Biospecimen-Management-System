-- =====================================================================
-- views.sql -- Database views
-- =====================================================================

-- View 1: Sample inventory overview -- one row per sample with donor,
-- type, and current aliquot count/volume remaining. Useful for lab staff
-- checking stock without needing to know the underlying join logic.
CREATE OR REPLACE VIEW vw_sample_inventory AS
SELECT
    s.sample_id,
    d.donor_code,
    st.type_name,
    s.collection_date,
    s.status AS sample_status,
    COUNT(a.aliquot_id)               AS aliquot_count,
    COALESCE(SUM(a.volume_ml), 0)     AS total_aliquot_volume_ml
FROM Sample s
JOIN Donor d       ON s.donor_id = d.donor_id
JOIN SampleType st ON s.sample_type_id = st.sample_type_id
LEFT JOIN Aliquot a ON a.sample_id = s.sample_id
GROUP BY s.sample_id, d.donor_code, st.type_name, s.collection_date, s.status;

-- View 2: Researcher activity summary -- number of requests submitted,
-- completed, and total volume of material consumed across all their
-- requests. Useful for lab management reporting and defense demo.
CREATE OR REPLACE VIEW vw_researcher_activity AS
SELECT
    r.researcher_id,
    r.full_name,
    r.department,
    COUNT(DISTINCT tr.request_id)                                   AS total_requests,
    COUNT(DISTINCT tr.request_id) FILTER (WHERE tr.status = 'Completed') AS completed_requests,
    COALESCE(SUM(su.quantity_used_ml), 0)                           AS total_volume_used_ml
FROM Researcher r
LEFT JOIN TestRequest tr ON tr.researcher_id = r.researcher_id
LEFT JOIN SampleUsage su ON su.request_id = tr.request_id
GROUP BY r.researcher_id, r.full_name, r.department;

-- Note: the FILTER clause is PostgreSQL syntax. For MySQL, replace with:
-- SUM(CASE WHEN tr.status = 'Completed' THEN 1 ELSE 0 END)
