-- load_data_mssql.sql
-- Seed data for the Biobank SQL Server schema
SET NOCOUNT ON;
GO

-- Donor
SET IDENTITY_INSERT dbo.Donor ON;
INSERT INTO dbo.Donor (donor_id, donor_code, date_of_birth, sex, contact_email, enrollment_date) VALUES
(1,'DNR-0001','1985-02-11','Female','d0001@example.org','2022-01-10'),
(2,'DNR-0002','1990-07-23','Male','d0002@example.org','2022-01-12'),
(3,'DNR-0003','1978-11-02','Female','d0003@example.org','2022-02-01'),
(4,'DNR-0004','1995-05-30','Male','d0004@example.org','2022-02-15'),
(5,'DNR-0005','1966-09-19','Other','d0005@example.org','2022-03-03'),
(6,'DNR-0006','2000-01-08','Female','d0006@example.org','2022-03-20'),
(7,'DNR-0007','1972-12-25','Male','d0007@example.org','2022-04-05'),
(8,'DNR-0008','1988-03-14','Female','d0008@example.org','2022-04-18'),
(9,'DNR-0009','1993-06-06','Male','d0009@example.org','2022-05-01'),
(10,'DNR-0010','1960-10-27','Unknown','d0010@example.org','2022-05-22');
SET IDENTITY_INSERT dbo.Donor OFF;
GO

-- Researcher
SET IDENTITY_INSERT dbo.Researcher ON;
INSERT INTO dbo.Researcher (researcher_id, full_name, department, email) VALUES
(1,'Dr. Amina Youssef','Genomics','a.youssef@lab.org'),
(2,'Dr. Karim Fathy','Immunology','k.fathy@lab.org'),
(3,'Dr. Laila Hassan','Oncology','l.hassan@lab.org'),
(4,'Dr. Omar Said','Biobanking Core','o.said@lab.org'),
(5,'Dr. Nourhan Adel','Genomics','n.adel@lab.org'),
(6,'Dr. Youssef Tarek','Immunology','y.tarek@lab.org'),
(7,'Dr. Sara Mostafa','Oncology','s.mostafa@lab.org'),
(8,'Dr. Hany Kamal','Biobanking Core','h.kamal@lab.org'),
(9,'Dr. Mona Reda','Genomics','m.reda@lab.org'),
(10,'Dr. Tamer Ali','Immunology','t.ali@lab.org');
SET IDENTITY_INSERT dbo.Researcher OFF;
GO

-- ConsentForm
SET IDENTITY_INSERT dbo.ConsentForm ON;
INSERT INTO dbo.ConsentForm (consent_id, donor_id, consent_type, date_signed, expiry_date, status) VALUES
(1,1,'Broad','2022-01-10','2027-01-10','Active'),
(2,2,'Research','2022-01-12','2027-01-12','Active'),
(3,3,'Restricted','2022-02-01', NULL,'Active'),
(4,4,'Broad','2022-02-15','2027-02-15','Active'),
(5,5,'Commercial','2022-03-03','2027-03-03','Active'),
(6,6,'Research','2022-03-20','2027-03-20','Active'),
(7,7,'Broad','2022-04-05', NULL,'Active'),
(8,8,'Restricted','2022-04-18','2027-04-18','Active'),
(9,9,'Research','2022-05-01','2027-05-01','Active'),
(10,10,'Broad','2022-05-22','2024-05-22','Expired');
SET IDENTITY_INSERT dbo.ConsentForm OFF;
GO

-- CollectionEvent
SET IDENTITY_INSERT dbo.CollectionEvent ON;
INSERT INTO dbo.CollectionEvent (event_id, donor_id, collected_by, event_date, location) VALUES
(1,1,4,'2022-01-15','Main Clinic Room A'),
(2,2,4,'2022-01-18','Main Clinic Room B'),
(3,3,8,'2022-02-05','Mobile Unit 1'),
(4,4,4,'2022-02-20','Main Clinic Room A'),
(5,5,8,'2022-03-08','Main Clinic Room C'),
(6,6,4,'2022-03-25','Mobile Unit 2'),
(7,7,8,'2022-04-10','Main Clinic Room B'),
(8,8,4,'2022-04-22','Main Clinic Room A'),
(9,9,8,'2022-05-05','Mobile Unit 1'),
(10,10,4,'2022-05-27','Main Clinic Room C');
SET IDENTITY_INSERT dbo.CollectionEvent OFF;
GO

-- SampleType
SET IDENTITY_INSERT dbo.SampleType ON;
INSERT INTO dbo.SampleType (sample_type_id, type_name, storage_requirements) VALUES
(1,'Whole Blood','-80C freezer'),
(2,'Plasma','-80C freezer'),
(3,'Saliva','-20C freezer'),
(4,'Tissue Biopsy','Liquid nitrogen (-196C)'),
(5,'DNA Extract','-20C freezer'),
(6,'Urine','-20C freezer');
SET IDENTITY_INSERT dbo.SampleType OFF;
GO

-- Sample
SET IDENTITY_INSERT dbo.Sample ON;
INSERT INTO dbo.Sample (sample_id, donor_id, sample_type_id, event_id, collection_date, volume_ml, status) VALUES
(1,1,1,1,'2022-01-15',10.0,'Available'),
(2,1,2,1,'2022-01-08',4.2,'Available'),
(3,2,6,2,'2022-02-14',3.8,'Quarantined'),
(4,3,3,3,'2022-03-05',2.1,'Available'),
(5,4,5,4,'2022-04-12',5.6,'Available'),
(6,2,5,2,'2022-02-14',6.0,'Depleted'),
(7,5,3,5,'2022-03-08',1.5,'Available'),
(8,6,6,6,'2022-03-25',0.5,'Available'),
(9,7,1,7,'2022-04-10',10.0,'Available'),
(10,8,1,8,'2022-04-22',20.0,'Available');
SET IDENTITY_INSERT dbo.Sample OFF;
GO

-- StorageLocation
SET IDENTITY_INSERT dbo.StorageLocation ON;
INSERT INTO dbo.StorageLocation (location_id, freezer_id, shelf, rack, position, temperature_c) VALUES
(1,'FRZ-1','S1','R1','P1',-80.0),
(2,'FRZ-1','S1','R1','P2',-80.0),
(3,'FRZ-1','S1','R2','P1',-80.0),
(4,'FRZ-2','S1','R1','P1',-20.0),
(5,'FRZ-2','S1','R1','P2',-20.0),
(6,'FRZ-3','S1','R1','P1',-196.0),
(7,'FRZ-1','S2','R1','P1',-80.0),
(8,'FRZ-2','S2','R1','P1',-20.0),
(9,'FRZ-1','S2','R2','P1',-80.0),
(10,'FRZ-2','S2','R2','P1',-20.0);
SET IDENTITY_INSERT dbo.StorageLocation OFF;
GO

-- Aliquot
SET IDENTITY_INSERT dbo.Aliquot ON;
INSERT INTO dbo.Aliquot (aliquot_id, sample_id, location_id, volume_ml, creation_date, status) VALUES
(1,1,3,2.40,'2024-01-09','Stored'),
(2,1,1,1.80,'2024-01-09','Stored'),
(3,2,1,1.20,'2024-01-09','InUse'),
(4,3,2,1.00,'2024-02-15','Stored'),
(5,4,5,0.80,'2024-03-06','Stored'),
(6,5,4,2.20,'2024-04-13','Depleted'),
(7,6,3,2.40,'2024-02-20','Stored'),
(8,7,5,0.30,'2024-03-20','Stored'),
(9,8,6,3.50,'2024-04-25','Stored'),
(10,9,4,1.00,'2024-05-11','Stored');
SET IDENTITY_INSERT dbo.Aliquot OFF;
GO

-- TestRequest
SET IDENTITY_INSERT dbo.TestRequest ON;
INSERT INTO dbo.TestRequest (request_id, sample_id, researcher_id, test_type, request_date, status) VALUES
(1,1,1,'Genomic Sequencing','2024-01-20','Pending'),
(2,2,2,'Biomarker Assay','2024-02-01','Approved'),
(3,3,3,'Proteomics Panel','2024-03-12','Completed'),
(4,5,1,'QC Validation','2024-04-15','Pending'),
(5,4,2,'Histopathology','2024-03-15','Approved'),
(6,6,5,'PCR Genotyping','2024-04-01','Completed'),
(7,7,1,'RNA Sequencing','2024-04-15','Pending'),
(8,8,7,'Tumor Marker Panel','2024-05-01','Approved'),
(9,9,2,'Cytokine Panel','2024-05-10','Completed'),
(10,10,5,'WGS','2024-06-01','Pending');
SET IDENTITY_INSERT dbo.TestRequest OFF;
GO

-- SampleUsage
SET IDENTITY_INSERT dbo.SampleUsage ON;
INSERT INTO dbo.SampleUsage (usage_id, aliquot_id, request_id, usage_date, quantity_used_ml, purpose) VALUES
(1,2,2,'2024-02-03',0.40,'Biomarker screening'),
(2,3,3,'2024-03-20',0.30,'Proteome profiling'),
(3,4,1,'2024-01-25',0.25,'Initial quality check'),
(4,1,1,'2024-02-02',2.00,'WGS library prep'),
(5,5,4,'2024-03-02',2.00,'WGS library prep'),
(6,6,5,'2024-03-16',1.00,'Histology slide prep'),
(7,7,6,'2024-04-02',0.30,'PCR run 1'),
(8,8,7,'2024-04-16',3.00,'RNA extraction'),
(9,9,8,'2024-05-02',5.00,'Tumor marker ELISA'),
(10,10,9,'2024-05-11',1.00,'Cytokine ELISA replicate');
SET IDENTITY_INSERT dbo.SampleUsage OFF;
GO

PRINT 'Seed data loaded.';
GO