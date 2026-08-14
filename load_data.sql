-- =====================================================================
-- load_data.sql -- Test data (>=10 rows per main table)
-- Run AFTER create_tables.sql
-- =====================================================================

-- Donor (10)
INSERT INTO Donor (donor_code, date_of_birth, sex, contact_email, enrollment_date) VALUES
('DNR-0001','1985-02-11','Female','d0001@example.org','2022-01-10'),
('DNR-0002','1990-07-23','Male','d0002@example.org','2022-01-12'),
('DNR-0003','1978-11-02','Female','d0003@example.org','2022-02-01'),
('DNR-0004','1995-05-30','Male','d0004@example.org','2022-02-15'),
('DNR-0005','1966-09-19','Other','d0005@example.org','2022-03-03'),
('DNR-0006','2000-01-08','Female','d0006@example.org','2022-03-20'),
('DNR-0007','1972-12-25','Male','d0007@example.org','2022-04-05'),
('DNR-0008','1988-03-14','Female','d0008@example.org','2022-04-18'),
('DNR-0009','1993-06-06','Male','d0009@example.org','2022-05-01'),
('DNR-0010','1960-10-27','Unknown','d0010@example.org','2022-05-22');

-- Researcher (10)
INSERT INTO Researcher (full_name, department, email) VALUES
('Dr. Amina Youssef','Genomics','a.youssef@lab.org'),
('Dr. Karim Fathy','Immunology','k.fathy@lab.org'),
('Dr. Laila Hassan','Oncology','l.hassan@lab.org'),
('Dr. Omar Said','Biobanking Core','o.said@lab.org'),
('Dr. Nourhan Adel','Genomics','n.adel@lab.org'),
('Dr. Youssef Tarek','Immunology','y.tarek@lab.org'),
('Dr. Sara Mostafa','Oncology','s.mostafa@lab.org'),
('Dr. Hany Kamal','Biobanking Core','h.kamal@lab.org'),
('Dr. Mona Reda','Genomics','m.reda@lab.org'),
('Dr. Tamer Ali','Immunology','t.ali@lab.org');

-- ConsentForm (10)
INSERT INTO ConsentForm (donor_id, consent_type, date_signed, expiry_date, status) VALUES
(1,'Broad','2022-01-10','2027-01-10','Active'),
(2,'Research','2022-01-12','2027-01-12','Active'),
(3,'Restricted','2022-02-01', NULL,'Active'),
(4,'Broad','2022-02-15','2027-02-15','Active'),
(5,'Commercial','2022-03-03','2027-03-03','Active'),
(6,'Research','2022-03-20','2027-03-20','Active'),
(7,'Broad','2022-04-05', NULL,'Active'),
(8,'Restricted','2022-04-18','2027-04-18','Active'),
(9,'Research','2022-05-01','2027-05-01','Active'),
(10,'Broad','2022-05-22','2024-05-22','Expired');

-- CollectionEvent (10)
INSERT INTO CollectionEvent (donor_id, collected_by, event_date, location) VALUES
(1,4,'2022-01-15','Main Clinic Room A'),
(2,4,'2022-01-18','Main Clinic Room B'),
(3,8,'2022-02-05','Mobile Unit 1'),
(4,4,'2022-02-20','Main Clinic Room A'),
(5,8,'2022-03-08','Main Clinic Room C'),
(6,4,'2022-03-25','Mobile Unit 2'),
(7,8,'2022-04-10','Main Clinic Room B'),
(8,4,'2022-04-22','Main Clinic Room A'),
(9,8,'2022-05-05','Mobile Unit 1'),
(10,4,'2022-05-27','Main Clinic Room C');

-- SampleType (6 -- small lookup table)
INSERT INTO SampleType (type_name, storage_requirements) VALUES
('Whole Blood','-80C freezer'),
('Plasma','-80C freezer'),
('Saliva','-20C freezer'),
('Tissue Biopsy','Liquid nitrogen (-196C)'),
('DNA Extract','-20C freezer'),
('Urine','-20C freezer');

-- Sample (10)
INSERT INTO Sample (donor_id, sample_type_id, event_id, collection_date, volume_ml, status) VALUES
(1,1,1,'2022-01-15',10.0,'Available'),
(2,2,2,'2022-01-18',5.0,'Available'),
(3,3,3,'2022-02-05',3.0,'Available'),
(4,1,4,'2022-02-20',10.0,'Available'),
(5,4,5,'2022-03-08',1.5,'Quarantined'),
(6,5,6,'2022-03-25',0.5,'Available'),
(7,1,7,'2022-04-10',10.0,'Available'),
(8,6,8,'2022-04-22',20.0,'Available'),
(9,2,9,'2022-05-05',5.0,'Depleted'),
(10,1,10,'2022-05-27',10.0,'Available');

-- StorageLocation (10)
INSERT INTO StorageLocation (freezer_id, shelf, rack, position, temperature_c) VALUES
('FRZ-1','S1','R1','P1',-80.0),
('FRZ-1','S1','R1','P2',-80.0),
('FRZ-1','S1','R2','P1',-80.0),
('FRZ-2','S1','R1','P1',-20.0),
('FRZ-2','S1','R1','P2',-20.0),
('FRZ-3','S1','R1','P1',-196.0),
('FRZ-1','S2','R1','P1',-80.0),
('FRZ-2','S2','R1','P1',-20.0),
('FRZ-1','S2','R2','P1',-80.0),
('FRZ-2','S2','R2','P1',-20.0);

-- Aliquot (10)
INSERT INTO Aliquot (sample_id, location_id, volume_ml, creation_date, status) VALUES
(1,1,5.0,'2022-01-16','Stored'),
(1,2,5.0,'2022-01-16','Stored'),
(2,4,2.5,'2022-01-19','Stored'),
(3,5,1.5,'2022-02-06','Stored'),
(4,1,5.0,'2022-02-21','Stored'),
(5,6,1.5,'2022-03-09','Stored'),
(6,4,0.5,'2022-03-26','InUse'),
(7,7,10.0,'2022-04-11','Stored'),
(8,8,20.0,'2022-04-23','Stored'),
(9,4,5.0,'2022-05-06','Depleted');

-- TestRequest (10)
INSERT INTO TestRequest (sample_id, researcher_id, test_type, request_date, status) VALUES
(1,1,'Whole Genome Sequencing','2022-02-01','Completed'),
(2,2,'Cytokine Panel','2022-02-03','Completed'),
(3,3,'DNA Methylation Assay','2022-02-20','Approved'),
(4,1,'Whole Genome Sequencing','2022-03-01','Pending'),
(5,3,'Histopathology','2022-03-15','Approved'),
(6,5,'PCR Genotyping','2022-04-01','Completed'),
(7,1,'RNA Sequencing','2022-04-15','Pending'),
(8,7,'Tumor Marker Panel','2022-05-01','Approved'),
(9,2,'Cytokine Panel','2022-05-10','Completed'),
(10,5,'Whole Genome Sequencing','2022-06-01','Pending');

-- SampleUsage (10) -- resolves M:N between Aliquot and TestRequest
INSERT INTO SampleUsage (aliquot_id, request_id, usage_date, quantity_used_ml, purpose) VALUES
(1,1,'2022-02-02',2.0,'WGS library prep'),
(2,1,'2022-02-04',2.0,'WGS replicate'),
(3,2,'2022-02-05',1.0,'Cytokine ELISA'),
(4,3,'2022-02-21',0.5,'Methylation array'),
(5,4,'2022-03-02',2.0,'WGS library prep'),
(6,5,'2022-03-16',1.0,'Histology slide prep'),
(7,6,'2022-04-02',0.3,'PCR run 1'),
(8,7,'2022-04-16',3.0,'RNA extraction'),
(9,8,'2022-05-02',5.0,'Tumor marker ELISA'),
(10,9,'2022-05-11',1.0,'Cytokine ELISA replicate');
