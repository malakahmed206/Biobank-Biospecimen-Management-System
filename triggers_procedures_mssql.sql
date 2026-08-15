-- triggers_procedures_mssql.sql
-- Triggers and stored procedures for Biobank (SQL Server)
SET NOCOUNT ON;
GO

-- Drop existing triggers and procedures if present
IF OBJECT_ID('dbo.trg_check_consent_before_usage','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_check_consent_before_usage ON dbo.SampleUsage;
IF OBJECT_ID('dbo.trg_update_aliquot_status','TR') IS NOT NULL
    DROP TRIGGER dbo.trg_update_aliquot_status ON dbo.SampleUsage;
IF OBJECT_ID('dbo.sp_record_sample_usage','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_record_sample_usage;
GO

-- Trigger: prevent usage insertion when donor has no active consent
CREATE TRIGGER dbo.trg_check_consent_before_usage
ON dbo.SampleUsage
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @bad_donor INT;

    SELECT TOP 1 @bad_donor = s.donor_id
    FROM inserted i
    JOIN dbo.Aliquot a ON a.aliquot_id = i.aliquot_id
    JOIN dbo.Sample s ON s.sample_id = a.sample_id
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.ConsentForm c
        WHERE c.donor_id = s.donor_id AND c.status = 'Active'
    );

    IF @bad_donor IS NOT NULL
    BEGIN
        THROW 50001, 'Cannot record sample usage: donor has no active consent', 1;
    END
END;
GO

-- Trigger: update aliquot status after usage insert (set InUse or Depleted)
CREATE TRIGGER dbo.trg_update_aliquot_status
ON dbo.SampleUsage
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH affected AS (
        SELECT DISTINCT i.aliquot_id AS aliquot_id
        FROM inserted i
    ), totals AS (
        SELECT su.aliquot_id, SUM(su.quantity_used_ml) AS total_used
        FROM dbo.SampleUsage su
        WHERE su.aliquot_id IN (SELECT aliquot_id FROM affected)
        GROUP BY su.aliquot_id
    )
    UPDATE a
    SET a.status = CASE
            WHEN ISNULL(t.total_used,0) >= a.volume_ml THEN 'Depleted'
            WHEN a.status = 'Stored' THEN 'InUse'
            ELSE a.status END
    FROM dbo.Aliquot a
    JOIN affected af ON af.aliquot_id = a.aliquot_id
    LEFT JOIN totals t ON t.aliquot_id = a.aliquot_id;
END;
GO

-- Stored procedure: record usage and return remaining volume
CREATE PROCEDURE dbo.sp_record_sample_usage
    @p_aliquot_id INT,
    @p_request_id INT,
    @p_quantity_ml DECIMAL(6,2),
    @p_purpose VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRAN;
    BEGIN TRY
        INSERT INTO dbo.SampleUsage (aliquot_id, request_id, usage_date, quantity_used_ml, purpose)
        VALUES (@p_aliquot_id, @p_request_id, CAST(GETDATE() AS DATE), @p_quantity_ml, @p_purpose);

        DECLARE @v_remaining DECIMAL(6,2);
        SELECT @v_remaining = a.volume_ml - ISNULL(SUM(su.quantity_used_ml),0)
        FROM dbo.Aliquot a
        LEFT JOIN dbo.SampleUsage su ON su.aliquot_id = a.aliquot_id
        WHERE a.aliquot_id = @p_aliquot_id
        GROUP BY a.volume_ml;

        COMMIT TRAN;
        SELECT @v_remaining AS remaining_volume;
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50002, @ErrMsg, 1;
    END CATCH
END;
GO

PRINT 'Triggers and procedures created.';
GO