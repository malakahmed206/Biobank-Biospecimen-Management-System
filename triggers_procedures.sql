-- =====================================================================
-- triggers_procedures.sql -- Advanced database objects (PostgreSQL syntax)
-- =====================================================================

-- ---------------------------------------------------------------------
-- Business rule: a Sample cannot be used in a TestRequest (via
-- SampleUsage/Aliquot) once its ConsentForm has been Withdrawn.
-- This trigger enforces that rule at insert time on SampleUsage.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_check_consent_before_usage()
RETURNS TRIGGER AS $$
DECLARE
    v_donor_id   INT;
    v_consent_ok BOOLEAN;
BEGIN
    SELECT s.donor_id INTO v_donor_id
    FROM Aliquot a
    JOIN Sample s ON a.sample_id = s.sample_id
    WHERE a.aliquot_id = NEW.aliquot_id;

    SELECT EXISTS (
        SELECT 1 FROM ConsentForm c
        WHERE c.donor_id = v_donor_id
          AND c.status = 'Active'
    ) INTO v_consent_ok;

    IF NOT v_consent_ok THEN
        RAISE EXCEPTION 'Cannot record sample usage: donor % has no active consent', v_donor_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_consent_before_usage ON SampleUsage;
CREATE TRIGGER trg_check_consent_before_usage
BEFORE INSERT ON SampleUsage
FOR EACH ROW
EXECUTE FUNCTION fn_check_consent_before_usage();

-- ---------------------------------------------------------------------
-- Trigger: automatically mark an Aliquot as 'Depleted' once its total
-- recorded usage reaches or exceeds its original volume.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_update_aliquot_status()
RETURNS TRIGGER AS $$
DECLARE
    v_total_used   DECIMAL(6,2);
    v_orig_volume  DECIMAL(6,2);
BEGIN
    SELECT COALESCE(SUM(quantity_used_ml), 0) INTO v_total_used
    FROM SampleUsage
    WHERE aliquot_id = NEW.aliquot_id;

    SELECT volume_ml INTO v_orig_volume
    FROM Aliquot
    WHERE aliquot_id = NEW.aliquot_id;

    IF v_total_used >= v_orig_volume THEN
        UPDATE Aliquot
        SET status = 'Depleted'
        WHERE aliquot_id = NEW.aliquot_id;
    ELSE
        UPDATE Aliquot
        SET status = 'InUse'
        WHERE aliquot_id = NEW.aliquot_id AND status = 'Stored';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_aliquot_status ON SampleUsage;
CREATE TRIGGER trg_update_aliquot_status
AFTER INSERT ON SampleUsage
FOR EACH ROW
EXECUTE FUNCTION fn_update_aliquot_status();

-- ---------------------------------------------------------------------
-- Stored procedure: register a new sample usage and return the aliquot's
-- remaining volume, encapsulating a common lab-workflow operation.
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sp_record_sample_usage(
    p_aliquot_id   INT,
    p_request_id   INT,
    p_quantity_ml  DECIMAL,
    p_purpose      VARCHAR
)
RETURNS DECIMAL AS $$
DECLARE
    v_remaining DECIMAL(6,2);
BEGIN
    INSERT INTO SampleUsage (aliquot_id, request_id, usage_date, quantity_used_ml, purpose)
    VALUES (p_aliquot_id, p_request_id, CURRENT_DATE, p_quantity_ml, p_purpose);

    SELECT volume_ml - (
        SELECT COALESCE(SUM(quantity_used_ml), 0)
        FROM SampleUsage
        WHERE aliquot_id = p_aliquot_id
    ) INTO v_remaining
    FROM Aliquot
    WHERE aliquot_id = p_aliquot_id;

    RETURN v_remaining;
END;
$$ LANGUAGE plpgsql;

-- Example call:
-- SELECT sp_record_sample_usage(8, 8, 2.5, 'Additional tumor marker replicate');
