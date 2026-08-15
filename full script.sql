/****** Object:  Database [biobank]    Script Date: 8/15/2026 7:08:00 PM ******/
CREATE DATABASE [biobank]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'biobank', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\biobank.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'biobank_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\biobank_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [biobank] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [biobank].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [biobank] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [biobank] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [biobank] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [biobank] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [biobank] SET ARITHABORT OFF 
GO
ALTER DATABASE [biobank] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [biobank] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [biobank] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [biobank] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [biobank] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [biobank] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [biobank] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [biobank] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [biobank] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [biobank] SET  DISABLE_BROKER 
GO
ALTER DATABASE [biobank] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [biobank] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [biobank] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [biobank] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [biobank] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [biobank] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [biobank] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [biobank] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [biobank] SET  MULTI_USER 
GO
ALTER DATABASE [biobank] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [biobank] SET DB_CHAINING OFF 
GO
ALTER DATABASE [biobank] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [biobank] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [biobank] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [biobank] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [biobank] SET QUERY_STORE = ON
GO
ALTER DATABASE [biobank] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
/****** Object:  Table [dbo].[Donor]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Donor](
	[donor_id] [int] IDENTITY(1,1) NOT NULL,
	[donor_code] [varchar](20) NOT NULL,
	[date_of_birth] [date] NOT NULL,
	[sex] [varchar](10) NOT NULL,
	[contact_email] [varchar](120) NULL,
	[enrollment_date] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[donor_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SampleType]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SampleType](
	[sample_type_id] [int] IDENTITY(1,1) NOT NULL,
	[type_name] [varchar](50) NOT NULL,
	[storage_requirements] [varchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[sample_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sample]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sample](
	[sample_id] [int] IDENTITY(1,1) NOT NULL,
	[donor_id] [int] NOT NULL,
	[sample_type_id] [int] NOT NULL,
	[event_id] [int] NOT NULL,
	[collection_date] [date] NOT NULL,
	[volume_ml] [decimal](6, 2) NOT NULL,
	[status] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[sample_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Aliquot]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Aliquot](
	[aliquot_id] [int] IDENTITY(1,1) NOT NULL,
	[sample_id] [int] NOT NULL,
	[location_id] [int] NOT NULL,
	[volume_ml] [decimal](6, 2) NOT NULL,
	[creation_date] [date] NOT NULL,
	[status] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[aliquot_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_sample_inventory]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ============================================================
-- BONUS VIEW
-- Complete sample inventory
-- Useful for the application/demo
-- ============================================================

CREATE   VIEW [dbo].[vw_sample_inventory]
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
/****** Object:  Table [dbo].[SampleUsage]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SampleUsage](
	[usage_id] [int] IDENTITY(1,1) NOT NULL,
	[aliquot_id] [int] NOT NULL,
	[request_id] [int] NOT NULL,
	[usage_date] [date] NOT NULL,
	[quantity_used_ml] [decimal](6, 2) NOT NULL,
	[purpose] [varchar](150) NULL,
PRIMARY KEY CLUSTERED 
(
	[usage_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_aliquot_usage_summary]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_aliquot_usage_summary]
AS
SELECT a.aliquot_id,
       a.sample_id,
       d.donor_code,
       a.location_id,
       a.volume_ml AS original_volume_ml,
       ISNULL(SUM(su.quantity_used_ml),0) AS total_used_ml,
       a.status AS aliquot_status
FROM dbo.Aliquot a
JOIN dbo.Sample s ON a.sample_id = s.sample_id
JOIN dbo.Donor d ON s.donor_id = d.donor_id
LEFT JOIN dbo.SampleUsage su ON su.aliquot_id = a.aliquot_id
GROUP BY a.aliquot_id, a.sample_id, d.donor_code, a.location_id, a.volume_ml, a.status;
GO
/****** Object:  View [dbo].[vw_donors_2022]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ============================================================
-- VIEW 1
-- Donors enrolled in 2022
-- Based on Query 1
-- ============================================================

CREATE   VIEW [dbo].[vw_donors_2022]
AS
SELECT
    donor_id,
    donor_code,
    sex,
    enrollment_date
FROM dbo.Donor
WHERE YEAR(enrollment_date) = 2022;
GO
/****** Object:  View [dbo].[vw_sample_overview]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ============================================================
-- VIEW 2
-- Complete sample information
-- Donor + Sample Type + Status
-- Based on Query 2
-- ============================================================

CREATE   VIEW [dbo].[vw_sample_overview]
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
/****** Object:  Table [dbo].[StorageLocation]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StorageLocation](
	[location_id] [int] IDENTITY(1,1) NOT NULL,
	[freezer_id] [varchar](20) NOT NULL,
	[shelf] [varchar](10) NOT NULL,
	[rack] [varchar](10) NOT NULL,
	[position] [varchar](10) NOT NULL,
	[temperature_c] [decimal](5, 1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[location_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_aliquot_storage]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ============================================================
-- VIEW 3
-- Aliquot storage information
-- Sample + Donor + Type + Storage Location
-- Based on Query 3
-- ============================================================

CREATE   VIEW [dbo].[vw_aliquot_storage]
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
/****** Object:  View [dbo].[vw_samples_by_type]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ============================================================
-- VIEW 4
-- Number of samples per sample type
-- Based on Query 4
-- ============================================================

CREATE   VIEW [dbo].[vw_samples_by_type]
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
/****** Object:  Table [dbo].[Researcher]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Researcher](
	[researcher_id] [int] IDENTITY(1,1) NOT NULL,
	[full_name] [varchar](100) NOT NULL,
	[department] [varchar](100) NOT NULL,
	[email] [varchar](120) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[researcher_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TestRequest]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TestRequest](
	[request_id] [int] IDENTITY(1,1) NOT NULL,
	[sample_id] [int] NOT NULL,
	[researcher_id] [int] NOT NULL,
	[test_type] [varchar](80) NOT NULL,
	[request_date] [date] NOT NULL,
	[status] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[request_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_researcher_requests]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ============================================================
-- VIEW 5
-- Researchers with more than one test request
-- Based on Query 5
-- ============================================================

CREATE   VIEW [dbo].[vw_researcher_requests]
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
/****** Object:  View [dbo].[vw_quarantined_donors]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ============================================================
-- VIEW 6
-- Donors with quarantined samples
-- Based on Query 6
-- ============================================================

CREATE   VIEW [dbo].[vw_quarantined_donors]
AS
SELECT DISTINCT
    d.donor_id,
    d.donor_code
FROM dbo.Donor d
JOIN dbo.Sample s
    ON d.donor_id = s.donor_id
WHERE s.status = 'Quarantined';
GO
/****** Object:  View [dbo].[vw_aliquots_over_50_percent_used]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ============================================================
-- VIEW 7
-- Aliquots where more than 50% of original volume was used
-- Based on Query 7
-- ============================================================

CREATE   VIEW [dbo].[vw_aliquots_over_50_percent_used]
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
/****** Object:  View [dbo].[vw_high_average_volume_types]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ============================================================
-- VIEW 8
-- Sample types whose average volume is above
-- the overall average sample volume
-- Based on Query 8
-- ============================================================

CREATE   VIEW [dbo].[vw_high_average_volume_types]
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
/****** Object:  View [dbo].[vw_test_request_usage]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ============================================================
-- VIEW 9
-- Test requests and aliquot usage
-- Many-to-many report
-- Based on Query 9
-- ============================================================

CREATE   VIEW [dbo].[vw_test_request_usage]
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
/****** Object:  Table [dbo].[CollectionEvent]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CollectionEvent](
	[event_id] [int] IDENTITY(1,1) NOT NULL,
	[donor_id] [int] NOT NULL,
	[collected_by] [int] NOT NULL,
	[event_date] [date] NOT NULL,
	[location] [varchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[event_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ConsentForm]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConsentForm](
	[consent_id] [int] IDENTITY(1,1) NOT NULL,
	[donor_id] [int] NOT NULL,
	[consent_type] [varchar](50) NOT NULL,
	[date_signed] [date] NOT NULL,
	[expiry_date] [date] NULL,
	[status] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[consent_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Aliquot] ON 
GO
INSERT [dbo].[Aliquot] ([aliquot_id], [sample_id], [location_id], [volume_ml], [creation_date], [status]) VALUES (1, 1, 3, CAST(2.40 AS Decimal(6, 2)), CAST(N'2024-01-09' AS Date), N'Stored')
GO
INSERT [dbo].[Aliquot] ([aliquot_id], [sample_id], [location_id], [volume_ml], [creation_date], [status]) VALUES (2, 1, 1, CAST(1.80 AS Decimal(6, 2)), CAST(N'2024-01-09' AS Date), N'Stored')
GO
INSERT [dbo].[Aliquot] ([aliquot_id], [sample_id], [location_id], [volume_ml], [creation_date], [status]) VALUES (3, 2, 1, CAST(1.20 AS Decimal(6, 2)), CAST(N'2024-01-09' AS Date), N'InUse')
GO
INSERT [dbo].[Aliquot] ([aliquot_id], [sample_id], [location_id], [volume_ml], [creation_date], [status]) VALUES (4, 3, 2, CAST(1.00 AS Decimal(6, 2)), CAST(N'2024-02-15' AS Date), N'Stored')
GO
INSERT [dbo].[Aliquot] ([aliquot_id], [sample_id], [location_id], [volume_ml], [creation_date], [status]) VALUES (5, 4, 5, CAST(0.80 AS Decimal(6, 2)), CAST(N'2024-03-06' AS Date), N'Stored')
GO
INSERT [dbo].[Aliquot] ([aliquot_id], [sample_id], [location_id], [volume_ml], [creation_date], [status]) VALUES (6, 5, 4, CAST(2.20 AS Decimal(6, 2)), CAST(N'2024-04-13' AS Date), N'Depleted')
GO
INSERT [dbo].[Aliquot] ([aliquot_id], [sample_id], [location_id], [volume_ml], [creation_date], [status]) VALUES (7, 6, 3, CAST(2.40 AS Decimal(6, 2)), CAST(N'2024-02-20' AS Date), N'Stored')
GO
INSERT [dbo].[Aliquot] ([aliquot_id], [sample_id], [location_id], [volume_ml], [creation_date], [status]) VALUES (8, 7, 5, CAST(0.30 AS Decimal(6, 2)), CAST(N'2024-03-20' AS Date), N'Stored')
GO
INSERT [dbo].[Aliquot] ([aliquot_id], [sample_id], [location_id], [volume_ml], [creation_date], [status]) VALUES (9, 8, 6, CAST(3.50 AS Decimal(6, 2)), CAST(N'2024-04-25' AS Date), N'Stored')
GO
INSERT [dbo].[Aliquot] ([aliquot_id], [sample_id], [location_id], [volume_ml], [creation_date], [status]) VALUES (10, 9, 4, CAST(1.00 AS Decimal(6, 2)), CAST(N'2024-05-11' AS Date), N'Stored')
GO
SET IDENTITY_INSERT [dbo].[Aliquot] OFF
GO
SET IDENTITY_INSERT [dbo].[CollectionEvent] ON 
GO
INSERT [dbo].[CollectionEvent] ([event_id], [donor_id], [collected_by], [event_date], [location]) VALUES (1, 1, 4, CAST(N'2022-01-15' AS Date), N'Main Clinic Room A')
GO
INSERT [dbo].[CollectionEvent] ([event_id], [donor_id], [collected_by], [event_date], [location]) VALUES (2, 2, 4, CAST(N'2022-01-18' AS Date), N'Main Clinic Room B')
GO
INSERT [dbo].[CollectionEvent] ([event_id], [donor_id], [collected_by], [event_date], [location]) VALUES (3, 3, 8, CAST(N'2022-02-05' AS Date), N'Mobile Unit 1')
GO
INSERT [dbo].[CollectionEvent] ([event_id], [donor_id], [collected_by], [event_date], [location]) VALUES (4, 4, 4, CAST(N'2022-02-20' AS Date), N'Main Clinic Room A')
GO
INSERT [dbo].[CollectionEvent] ([event_id], [donor_id], [collected_by], [event_date], [location]) VALUES (5, 5, 8, CAST(N'2022-03-08' AS Date), N'Main Clinic Room C')
GO
INSERT [dbo].[CollectionEvent] ([event_id], [donor_id], [collected_by], [event_date], [location]) VALUES (6, 6, 4, CAST(N'2022-03-25' AS Date), N'Mobile Unit 2')
GO
INSERT [dbo].[CollectionEvent] ([event_id], [donor_id], [collected_by], [event_date], [location]) VALUES (7, 7, 8, CAST(N'2022-04-10' AS Date), N'Main Clinic Room B')
GO
INSERT [dbo].[CollectionEvent] ([event_id], [donor_id], [collected_by], [event_date], [location]) VALUES (8, 8, 4, CAST(N'2022-04-22' AS Date), N'Main Clinic Room A')
GO
INSERT [dbo].[CollectionEvent] ([event_id], [donor_id], [collected_by], [event_date], [location]) VALUES (9, 9, 8, CAST(N'2022-05-05' AS Date), N'Mobile Unit 1')
GO
INSERT [dbo].[CollectionEvent] ([event_id], [donor_id], [collected_by], [event_date], [location]) VALUES (10, 10, 4, CAST(N'2022-05-27' AS Date), N'Main Clinic Room C')
GO
SET IDENTITY_INSERT [dbo].[CollectionEvent] OFF
GO
SET IDENTITY_INSERT [dbo].[ConsentForm] ON 
GO
INSERT [dbo].[ConsentForm] ([consent_id], [donor_id], [consent_type], [date_signed], [expiry_date], [status]) VALUES (1, 1, N'Broad', CAST(N'2022-01-10' AS Date), CAST(N'2027-01-10' AS Date), N'Active')
GO
INSERT [dbo].[ConsentForm] ([consent_id], [donor_id], [consent_type], [date_signed], [expiry_date], [status]) VALUES (2, 2, N'Research', CAST(N'2022-01-12' AS Date), CAST(N'2027-01-12' AS Date), N'Active')
GO
INSERT [dbo].[ConsentForm] ([consent_id], [donor_id], [consent_type], [date_signed], [expiry_date], [status]) VALUES (3, 3, N'Restricted', CAST(N'2022-02-01' AS Date), NULL, N'Active')
GO
INSERT [dbo].[ConsentForm] ([consent_id], [donor_id], [consent_type], [date_signed], [expiry_date], [status]) VALUES (4, 4, N'Broad', CAST(N'2022-02-15' AS Date), CAST(N'2027-02-15' AS Date), N'Active')
GO
INSERT [dbo].[ConsentForm] ([consent_id], [donor_id], [consent_type], [date_signed], [expiry_date], [status]) VALUES (5, 5, N'Commercial', CAST(N'2022-03-03' AS Date), CAST(N'2027-03-03' AS Date), N'Active')
GO
INSERT [dbo].[ConsentForm] ([consent_id], [donor_id], [consent_type], [date_signed], [expiry_date], [status]) VALUES (6, 6, N'Research', CAST(N'2022-03-20' AS Date), CAST(N'2027-03-20' AS Date), N'Active')
GO
INSERT [dbo].[ConsentForm] ([consent_id], [donor_id], [consent_type], [date_signed], [expiry_date], [status]) VALUES (7, 7, N'Broad', CAST(N'2022-04-05' AS Date), NULL, N'Active')
GO
INSERT [dbo].[ConsentForm] ([consent_id], [donor_id], [consent_type], [date_signed], [expiry_date], [status]) VALUES (8, 8, N'Restricted', CAST(N'2022-04-18' AS Date), CAST(N'2027-04-18' AS Date), N'Active')
GO
INSERT [dbo].[ConsentForm] ([consent_id], [donor_id], [consent_type], [date_signed], [expiry_date], [status]) VALUES (9, 9, N'Research', CAST(N'2022-05-01' AS Date), CAST(N'2027-05-01' AS Date), N'Active')
GO
INSERT [dbo].[ConsentForm] ([consent_id], [donor_id], [consent_type], [date_signed], [expiry_date], [status]) VALUES (10, 10, N'Broad', CAST(N'2022-05-22' AS Date), CAST(N'2024-05-22' AS Date), N'Expired')
GO
SET IDENTITY_INSERT [dbo].[ConsentForm] OFF
GO
SET IDENTITY_INSERT [dbo].[Donor] ON 
GO
INSERT [dbo].[Donor] ([donor_id], [donor_code], [date_of_birth], [sex], [contact_email], [enrollment_date]) VALUES (1, N'DNR-0001', CAST(N'1985-02-11' AS Date), N'Female', N'd0001@example.org', CAST(N'2022-01-10' AS Date))
GO
INSERT [dbo].[Donor] ([donor_id], [donor_code], [date_of_birth], [sex], [contact_email], [enrollment_date]) VALUES (2, N'DNR-0002', CAST(N'1990-07-23' AS Date), N'Male', N'd0002@example.org', CAST(N'2022-01-12' AS Date))
GO
INSERT [dbo].[Donor] ([donor_id], [donor_code], [date_of_birth], [sex], [contact_email], [enrollment_date]) VALUES (3, N'DNR-0003', CAST(N'1978-11-02' AS Date), N'Female', N'd0003@example.org', CAST(N'2022-02-01' AS Date))
GO
INSERT [dbo].[Donor] ([donor_id], [donor_code], [date_of_birth], [sex], [contact_email], [enrollment_date]) VALUES (4, N'DNR-0004', CAST(N'1995-05-30' AS Date), N'Male', N'd0004@example.org', CAST(N'2022-02-15' AS Date))
GO
INSERT [dbo].[Donor] ([donor_id], [donor_code], [date_of_birth], [sex], [contact_email], [enrollment_date]) VALUES (5, N'DNR-0005', CAST(N'1966-09-19' AS Date), N'Other', N'd0005@example.org', CAST(N'2022-03-03' AS Date))
GO
INSERT [dbo].[Donor] ([donor_id], [donor_code], [date_of_birth], [sex], [contact_email], [enrollment_date]) VALUES (6, N'DNR-0006', CAST(N'2000-01-08' AS Date), N'Female', N'd0006@example.org', CAST(N'2022-03-20' AS Date))
GO
INSERT [dbo].[Donor] ([donor_id], [donor_code], [date_of_birth], [sex], [contact_email], [enrollment_date]) VALUES (7, N'DNR-0007', CAST(N'1972-12-25' AS Date), N'Male', N'd0007@example.org', CAST(N'2022-04-05' AS Date))
GO
INSERT [dbo].[Donor] ([donor_id], [donor_code], [date_of_birth], [sex], [contact_email], [enrollment_date]) VALUES (8, N'DNR-0008', CAST(N'1988-03-14' AS Date), N'Female', N'd0008@example.org', CAST(N'2022-04-18' AS Date))
GO
INSERT [dbo].[Donor] ([donor_id], [donor_code], [date_of_birth], [sex], [contact_email], [enrollment_date]) VALUES (9, N'DNR-0009', CAST(N'1993-06-06' AS Date), N'Male', N'd0009@example.org', CAST(N'2022-05-01' AS Date))
GO
INSERT [dbo].[Donor] ([donor_id], [donor_code], [date_of_birth], [sex], [contact_email], [enrollment_date]) VALUES (10, N'DNR-0010', CAST(N'1960-10-27' AS Date), N'Unknown', N'd0010@example.org', CAST(N'2022-05-22' AS Date))
GO
SET IDENTITY_INSERT [dbo].[Donor] OFF
GO
SET IDENTITY_INSERT [dbo].[Researcher] ON 
GO
INSERT [dbo].[Researcher] ([researcher_id], [full_name], [department], [email]) VALUES (1, N'Dr. Amina Youssef', N'Genomics', N'a.youssef@lab.org')
GO
INSERT [dbo].[Researcher] ([researcher_id], [full_name], [department], [email]) VALUES (2, N'Dr. Karim Fathy', N'Immunology', N'k.fathy@lab.org')
GO
INSERT [dbo].[Researcher] ([researcher_id], [full_name], [department], [email]) VALUES (3, N'Dr. Laila Hassan', N'Oncology', N'l.hassan@lab.org')
GO
INSERT [dbo].[Researcher] ([researcher_id], [full_name], [department], [email]) VALUES (4, N'Dr. Omar Said', N'Biobanking Core', N'o.said@lab.org')
GO
INSERT [dbo].[Researcher] ([researcher_id], [full_name], [department], [email]) VALUES (5, N'Dr. Nourhan Adel', N'Genomics', N'n.adel@lab.org')
GO
INSERT [dbo].[Researcher] ([researcher_id], [full_name], [department], [email]) VALUES (6, N'Dr. Youssef Tarek', N'Immunology', N'y.tarek@lab.org')
GO
INSERT [dbo].[Researcher] ([researcher_id], [full_name], [department], [email]) VALUES (7, N'Dr. Sara Mostafa', N'Oncology', N's.mostafa@lab.org')
GO
INSERT [dbo].[Researcher] ([researcher_id], [full_name], [department], [email]) VALUES (8, N'Dr. Hany Kamal', N'Biobanking Core', N'h.kamal@lab.org')
GO
INSERT [dbo].[Researcher] ([researcher_id], [full_name], [department], [email]) VALUES (9, N'Dr. Mona Reda', N'Genomics', N'm.reda@lab.org')
GO
INSERT [dbo].[Researcher] ([researcher_id], [full_name], [department], [email]) VALUES (10, N'Dr. Tamer Ali', N'Immunology', N't.ali@lab.org')
GO
SET IDENTITY_INSERT [dbo].[Researcher] OFF
GO
SET IDENTITY_INSERT [dbo].[Sample] ON 
GO
INSERT [dbo].[Sample] ([sample_id], [donor_id], [sample_type_id], [event_id], [collection_date], [volume_ml], [status]) VALUES (1, 1, 1, 1, CAST(N'2022-01-15' AS Date), CAST(10.00 AS Decimal(6, 2)), N'Available')
GO
INSERT [dbo].[Sample] ([sample_id], [donor_id], [sample_type_id], [event_id], [collection_date], [volume_ml], [status]) VALUES (2, 1, 2, 1, CAST(N'2022-01-08' AS Date), CAST(4.20 AS Decimal(6, 2)), N'Available')
GO
INSERT [dbo].[Sample] ([sample_id], [donor_id], [sample_type_id], [event_id], [collection_date], [volume_ml], [status]) VALUES (3, 2, 6, 2, CAST(N'2022-02-14' AS Date), CAST(3.80 AS Decimal(6, 2)), N'Quarantined')
GO
INSERT [dbo].[Sample] ([sample_id], [donor_id], [sample_type_id], [event_id], [collection_date], [volume_ml], [status]) VALUES (4, 3, 3, 3, CAST(N'2022-03-05' AS Date), CAST(2.10 AS Decimal(6, 2)), N'Available')
GO
INSERT [dbo].[Sample] ([sample_id], [donor_id], [sample_type_id], [event_id], [collection_date], [volume_ml], [status]) VALUES (5, 4, 5, 4, CAST(N'2022-04-12' AS Date), CAST(5.60 AS Decimal(6, 2)), N'Available')
GO
INSERT [dbo].[Sample] ([sample_id], [donor_id], [sample_type_id], [event_id], [collection_date], [volume_ml], [status]) VALUES (6, 2, 5, 2, CAST(N'2022-02-14' AS Date), CAST(6.00 AS Decimal(6, 2)), N'Depleted')
GO
INSERT [dbo].[Sample] ([sample_id], [donor_id], [sample_type_id], [event_id], [collection_date], [volume_ml], [status]) VALUES (7, 5, 3, 5, CAST(N'2022-03-08' AS Date), CAST(1.50 AS Decimal(6, 2)), N'Available')
GO
INSERT [dbo].[Sample] ([sample_id], [donor_id], [sample_type_id], [event_id], [collection_date], [volume_ml], [status]) VALUES (8, 6, 6, 6, CAST(N'2022-03-25' AS Date), CAST(0.50 AS Decimal(6, 2)), N'Available')
GO
INSERT [dbo].[Sample] ([sample_id], [donor_id], [sample_type_id], [event_id], [collection_date], [volume_ml], [status]) VALUES (9, 7, 1, 7, CAST(N'2022-04-10' AS Date), CAST(10.00 AS Decimal(6, 2)), N'Available')
GO
INSERT [dbo].[Sample] ([sample_id], [donor_id], [sample_type_id], [event_id], [collection_date], [volume_ml], [status]) VALUES (10, 8, 1, 8, CAST(N'2022-04-22' AS Date), CAST(20.00 AS Decimal(6, 2)), N'Available')
GO
SET IDENTITY_INSERT [dbo].[Sample] OFF
GO
SET IDENTITY_INSERT [dbo].[SampleType] ON 
GO
INSERT [dbo].[SampleType] ([sample_type_id], [type_name], [storage_requirements]) VALUES (1, N'Whole Blood', N'-80C freezer')
GO
INSERT [dbo].[SampleType] ([sample_type_id], [type_name], [storage_requirements]) VALUES (2, N'Plasma', N'-80C freezer')
GO
INSERT [dbo].[SampleType] ([sample_type_id], [type_name], [storage_requirements]) VALUES (3, N'Saliva', N'-20C freezer')
GO
INSERT [dbo].[SampleType] ([sample_type_id], [type_name], [storage_requirements]) VALUES (4, N'Tissue Biopsy', N'Liquid nitrogen (-196C)')
GO
INSERT [dbo].[SampleType] ([sample_type_id], [type_name], [storage_requirements]) VALUES (5, N'DNA Extract', N'-20C freezer')
GO
INSERT [dbo].[SampleType] ([sample_type_id], [type_name], [storage_requirements]) VALUES (6, N'Urine', N'-20C freezer')
GO
SET IDENTITY_INSERT [dbo].[SampleType] OFF
GO
SET IDENTITY_INSERT [dbo].[SampleUsage] ON 
GO
INSERT [dbo].[SampleUsage] ([usage_id], [aliquot_id], [request_id], [usage_date], [quantity_used_ml], [purpose]) VALUES (1, 2, 2, CAST(N'2024-02-03' AS Date), CAST(0.40 AS Decimal(6, 2)), N'Biomarker screening')
GO
INSERT [dbo].[SampleUsage] ([usage_id], [aliquot_id], [request_id], [usage_date], [quantity_used_ml], [purpose]) VALUES (2, 3, 3, CAST(N'2024-03-20' AS Date), CAST(0.30 AS Decimal(6, 2)), N'Proteome profiling')
GO
INSERT [dbo].[SampleUsage] ([usage_id], [aliquot_id], [request_id], [usage_date], [quantity_used_ml], [purpose]) VALUES (3, 4, 1, CAST(N'2024-01-25' AS Date), CAST(0.25 AS Decimal(6, 2)), N'Initial quality check')
GO
INSERT [dbo].[SampleUsage] ([usage_id], [aliquot_id], [request_id], [usage_date], [quantity_used_ml], [purpose]) VALUES (4, 1, 1, CAST(N'2024-02-02' AS Date), CAST(2.00 AS Decimal(6, 2)), N'WGS library prep')
GO
INSERT [dbo].[SampleUsage] ([usage_id], [aliquot_id], [request_id], [usage_date], [quantity_used_ml], [purpose]) VALUES (5, 5, 4, CAST(N'2024-03-02' AS Date), CAST(2.00 AS Decimal(6, 2)), N'WGS library prep')
GO
INSERT [dbo].[SampleUsage] ([usage_id], [aliquot_id], [request_id], [usage_date], [quantity_used_ml], [purpose]) VALUES (6, 6, 5, CAST(N'2024-03-16' AS Date), CAST(1.00 AS Decimal(6, 2)), N'Histology slide prep')
GO
INSERT [dbo].[SampleUsage] ([usage_id], [aliquot_id], [request_id], [usage_date], [quantity_used_ml], [purpose]) VALUES (7, 7, 6, CAST(N'2024-04-02' AS Date), CAST(0.30 AS Decimal(6, 2)), N'PCR run 1')
GO
INSERT [dbo].[SampleUsage] ([usage_id], [aliquot_id], [request_id], [usage_date], [quantity_used_ml], [purpose]) VALUES (8, 8, 7, CAST(N'2024-04-16' AS Date), CAST(3.00 AS Decimal(6, 2)), N'RNA extraction')
GO
INSERT [dbo].[SampleUsage] ([usage_id], [aliquot_id], [request_id], [usage_date], [quantity_used_ml], [purpose]) VALUES (9, 9, 8, CAST(N'2024-05-02' AS Date), CAST(5.00 AS Decimal(6, 2)), N'Tumor marker ELISA')
GO
INSERT [dbo].[SampleUsage] ([usage_id], [aliquot_id], [request_id], [usage_date], [quantity_used_ml], [purpose]) VALUES (10, 10, 9, CAST(N'2024-05-11' AS Date), CAST(1.00 AS Decimal(6, 2)), N'Cytokine ELISA replicate')
GO
SET IDENTITY_INSERT [dbo].[SampleUsage] OFF
GO
SET IDENTITY_INSERT [dbo].[StorageLocation] ON 
GO
INSERT [dbo].[StorageLocation] ([location_id], [freezer_id], [shelf], [rack], [position], [temperature_c]) VALUES (1, N'FRZ-1', N'S1', N'R1', N'P1', CAST(-80.0 AS Decimal(5, 1)))
GO
INSERT [dbo].[StorageLocation] ([location_id], [freezer_id], [shelf], [rack], [position], [temperature_c]) VALUES (2, N'FRZ-1', N'S1', N'R1', N'P2', CAST(-80.0 AS Decimal(5, 1)))
GO
INSERT [dbo].[StorageLocation] ([location_id], [freezer_id], [shelf], [rack], [position], [temperature_c]) VALUES (3, N'FRZ-1', N'S1', N'R2', N'P1', CAST(-80.0 AS Decimal(5, 1)))
GO
INSERT [dbo].[StorageLocation] ([location_id], [freezer_id], [shelf], [rack], [position], [temperature_c]) VALUES (4, N'FRZ-2', N'S1', N'R1', N'P1', CAST(-20.0 AS Decimal(5, 1)))
GO
INSERT [dbo].[StorageLocation] ([location_id], [freezer_id], [shelf], [rack], [position], [temperature_c]) VALUES (5, N'FRZ-2', N'S1', N'R1', N'P2', CAST(-20.0 AS Decimal(5, 1)))
GO
INSERT [dbo].[StorageLocation] ([location_id], [freezer_id], [shelf], [rack], [position], [temperature_c]) VALUES (6, N'FRZ-3', N'S1', N'R1', N'P1', CAST(-196.0 AS Decimal(5, 1)))
GO
INSERT [dbo].[StorageLocation] ([location_id], [freezer_id], [shelf], [rack], [position], [temperature_c]) VALUES (7, N'FRZ-1', N'S2', N'R1', N'P1', CAST(-80.0 AS Decimal(5, 1)))
GO
INSERT [dbo].[StorageLocation] ([location_id], [freezer_id], [shelf], [rack], [position], [temperature_c]) VALUES (8, N'FRZ-2', N'S2', N'R1', N'P1', CAST(-20.0 AS Decimal(5, 1)))
GO
INSERT [dbo].[StorageLocation] ([location_id], [freezer_id], [shelf], [rack], [position], [temperature_c]) VALUES (9, N'FRZ-1', N'S2', N'R2', N'P1', CAST(-80.0 AS Decimal(5, 1)))
GO
INSERT [dbo].[StorageLocation] ([location_id], [freezer_id], [shelf], [rack], [position], [temperature_c]) VALUES (10, N'FRZ-2', N'S2', N'R2', N'P1', CAST(-20.0 AS Decimal(5, 1)))
GO
SET IDENTITY_INSERT [dbo].[StorageLocation] OFF
GO
SET IDENTITY_INSERT [dbo].[TestRequest] ON 
GO
INSERT [dbo].[TestRequest] ([request_id], [sample_id], [researcher_id], [test_type], [request_date], [status]) VALUES (1, 1, 1, N'Genomic Sequencing', CAST(N'2024-01-20' AS Date), N'Pending')
GO
INSERT [dbo].[TestRequest] ([request_id], [sample_id], [researcher_id], [test_type], [request_date], [status]) VALUES (2, 2, 2, N'Biomarker Assay', CAST(N'2024-02-01' AS Date), N'Approved')
GO
INSERT [dbo].[TestRequest] ([request_id], [sample_id], [researcher_id], [test_type], [request_date], [status]) VALUES (3, 3, 3, N'Proteomics Panel', CAST(N'2024-03-12' AS Date), N'Completed')
GO
INSERT [dbo].[TestRequest] ([request_id], [sample_id], [researcher_id], [test_type], [request_date], [status]) VALUES (4, 5, 1, N'QC Validation', CAST(N'2024-04-15' AS Date), N'Pending')
GO
INSERT [dbo].[TestRequest] ([request_id], [sample_id], [researcher_id], [test_type], [request_date], [status]) VALUES (5, 4, 2, N'Histopathology', CAST(N'2024-03-15' AS Date), N'Approved')
GO
INSERT [dbo].[TestRequest] ([request_id], [sample_id], [researcher_id], [test_type], [request_date], [status]) VALUES (6, 6, 5, N'PCR Genotyping', CAST(N'2024-04-01' AS Date), N'Completed')
GO
INSERT [dbo].[TestRequest] ([request_id], [sample_id], [researcher_id], [test_type], [request_date], [status]) VALUES (7, 7, 1, N'RNA Sequencing', CAST(N'2024-04-15' AS Date), N'Pending')
GO
INSERT [dbo].[TestRequest] ([request_id], [sample_id], [researcher_id], [test_type], [request_date], [status]) VALUES (8, 8, 7, N'Tumor Marker Panel', CAST(N'2024-05-01' AS Date), N'Approved')
GO
INSERT [dbo].[TestRequest] ([request_id], [sample_id], [researcher_id], [test_type], [request_date], [status]) VALUES (9, 9, 2, N'Cytokine Panel', CAST(N'2024-05-10' AS Date), N'Completed')
GO
INSERT [dbo].[TestRequest] ([request_id], [sample_id], [researcher_id], [test_type], [request_date], [status]) VALUES (10, 10, 5, N'WGS', CAST(N'2024-06-01' AS Date), N'Pending')
GO
SET IDENTITY_INSERT [dbo].[TestRequest] OFF
GO
/****** Object:  Index [idx_aliquot_sample]    Script Date: 8/15/2026 7:08:00 PM ******/
CREATE NONCLUSTERED INDEX [idx_aliquot_sample] ON [dbo].[Aliquot]
(
	[sample_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Donor__F3CEC8CD02AC3F0B]    Script Date: 8/15/2026 7:08:00 PM ******/
ALTER TABLE [dbo].[Donor] ADD UNIQUE NONCLUSTERED 
(
	[donor_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Research__AB6E61648DFE0925]    Script Date: 8/15/2026 7:08:00 PM ******/
ALTER TABLE [dbo].[Researcher] ADD UNIQUE NONCLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_sample_donor]    Script Date: 8/15/2026 7:08:00 PM ******/
CREATE NONCLUSTERED INDEX [idx_sample_donor] ON [dbo].[Sample]
(
	[donor_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__SampleTy__543C4FD96DD0625C]    Script Date: 8/15/2026 7:08:00 PM ******/
ALTER TABLE [dbo].[SampleType] ADD UNIQUE NONCLUSTERED 
(
	[type_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ_Usage]    Script Date: 8/15/2026 7:08:00 PM ******/
ALTER TABLE [dbo].[SampleUsage] ADD  CONSTRAINT [UQ_Usage] UNIQUE NONCLUSTERED 
(
	[aliquot_id] ASC,
	[request_id] ASC,
	[usage_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_usage_aliquot]    Script Date: 8/15/2026 7:08:00 PM ******/
CREATE NONCLUSTERED INDEX [idx_usage_aliquot] ON [dbo].[SampleUsage]
(
	[aliquot_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_usage_request]    Script Date: 8/15/2026 7:08:00 PM ******/
CREATE NONCLUSTERED INDEX [idx_usage_request] ON [dbo].[SampleUsage]
(
	[request_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ_StorageLocation]    Script Date: 8/15/2026 7:08:00 PM ******/
ALTER TABLE [dbo].[StorageLocation] ADD  CONSTRAINT [UQ_StorageLocation] UNIQUE NONCLUSTERED 
(
	[freezer_id] ASC,
	[shelf] ASC,
	[rack] ASC,
	[position] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [idx_testrequest_sample]    Script Date: 8/15/2026 7:08:00 PM ******/
CREATE NONCLUSTERED INDEX [idx_testrequest_sample] ON [dbo].[TestRequest]
(
	[sample_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Aliquot] ADD  DEFAULT ('Stored') FOR [status]
GO
ALTER TABLE [dbo].[ConsentForm] ADD  DEFAULT ('Active') FOR [status]
GO
ALTER TABLE [dbo].[Donor] ADD  DEFAULT (CONVERT([date],getdate())) FOR [enrollment_date]
GO
ALTER TABLE [dbo].[Sample] ADD  DEFAULT ('Available') FOR [status]
GO
ALTER TABLE [dbo].[TestRequest] ADD  DEFAULT ('Pending') FOR [status]
GO
ALTER TABLE [dbo].[Aliquot]  WITH CHECK ADD  CONSTRAINT [FK_Aliquot_Sample] FOREIGN KEY([sample_id])
REFERENCES [dbo].[Sample] ([sample_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Aliquot] CHECK CONSTRAINT [FK_Aliquot_Sample]
GO
ALTER TABLE [dbo].[Aliquot]  WITH CHECK ADD  CONSTRAINT [FK_Aliquot_Storage] FOREIGN KEY([location_id])
REFERENCES [dbo].[StorageLocation] ([location_id])
GO
ALTER TABLE [dbo].[Aliquot] CHECK CONSTRAINT [FK_Aliquot_Storage]
GO
ALTER TABLE [dbo].[CollectionEvent]  WITH CHECK ADD  CONSTRAINT [FK_Event_Donor] FOREIGN KEY([donor_id])
REFERENCES [dbo].[Donor] ([donor_id])
GO
ALTER TABLE [dbo].[CollectionEvent] CHECK CONSTRAINT [FK_Event_Donor]
GO
ALTER TABLE [dbo].[CollectionEvent]  WITH CHECK ADD  CONSTRAINT [FK_Event_Researcher] FOREIGN KEY([collected_by])
REFERENCES [dbo].[Researcher] ([researcher_id])
GO
ALTER TABLE [dbo].[CollectionEvent] CHECK CONSTRAINT [FK_Event_Researcher]
GO
ALTER TABLE [dbo].[ConsentForm]  WITH CHECK ADD  CONSTRAINT [FK_Consent_Donor] FOREIGN KEY([donor_id])
REFERENCES [dbo].[Donor] ([donor_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ConsentForm] CHECK CONSTRAINT [FK_Consent_Donor]
GO
ALTER TABLE [dbo].[Sample]  WITH CHECK ADD  CONSTRAINT [FK_Sample_Donor] FOREIGN KEY([donor_id])
REFERENCES [dbo].[Donor] ([donor_id])
GO
ALTER TABLE [dbo].[Sample] CHECK CONSTRAINT [FK_Sample_Donor]
GO
ALTER TABLE [dbo].[Sample]  WITH CHECK ADD  CONSTRAINT [FK_Sample_Event] FOREIGN KEY([event_id])
REFERENCES [dbo].[CollectionEvent] ([event_id])
GO
ALTER TABLE [dbo].[Sample] CHECK CONSTRAINT [FK_Sample_Event]
GO
ALTER TABLE [dbo].[Sample]  WITH CHECK ADD  CONSTRAINT [FK_Sample_SampleType] FOREIGN KEY([sample_type_id])
REFERENCES [dbo].[SampleType] ([sample_type_id])
GO
ALTER TABLE [dbo].[Sample] CHECK CONSTRAINT [FK_Sample_SampleType]
GO
ALTER TABLE [dbo].[SampleUsage]  WITH CHECK ADD  CONSTRAINT [FK_Usage_Aliquot] FOREIGN KEY([aliquot_id])
REFERENCES [dbo].[Aliquot] ([aliquot_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SampleUsage] CHECK CONSTRAINT [FK_Usage_Aliquot]
GO
ALTER TABLE [dbo].[SampleUsage]  WITH CHECK ADD  CONSTRAINT [FK_Usage_Request] FOREIGN KEY([request_id])
REFERENCES [dbo].[TestRequest] ([request_id])
GO
ALTER TABLE [dbo].[SampleUsage] CHECK CONSTRAINT [FK_Usage_Request]
GO
ALTER TABLE [dbo].[TestRequest]  WITH CHECK ADD  CONSTRAINT [FK_Request_Researcher] FOREIGN KEY([researcher_id])
REFERENCES [dbo].[Researcher] ([researcher_id])
GO
ALTER TABLE [dbo].[TestRequest] CHECK CONSTRAINT [FK_Request_Researcher]
GO
ALTER TABLE [dbo].[TestRequest]  WITH CHECK ADD  CONSTRAINT [FK_Request_Sample] FOREIGN KEY([sample_id])
REFERENCES [dbo].[Sample] ([sample_id])
GO
ALTER TABLE [dbo].[TestRequest] CHECK CONSTRAINT [FK_Request_Sample]
GO
ALTER TABLE [dbo].[Aliquot]  WITH CHECK ADD CHECK  (([status]='Discarded' OR [status]='Depleted' OR [status]='InUse' OR [status]='Stored'))
GO
ALTER TABLE [dbo].[Aliquot]  WITH CHECK ADD CHECK  (([volume_ml]>(0)))
GO
ALTER TABLE [dbo].[ConsentForm]  WITH CHECK ADD  CONSTRAINT [chk_consent_dates_sqlserver] CHECK  (([expiry_date] IS NULL OR [expiry_date]>[date_signed]))
GO
ALTER TABLE [dbo].[ConsentForm] CHECK CONSTRAINT [chk_consent_dates_sqlserver]
GO
ALTER TABLE [dbo].[ConsentForm]  WITH CHECK ADD CHECK  (([consent_type]='Restricted' OR [consent_type]='Broad' OR [consent_type]='Commercial' OR [consent_type]='Research'))
GO
ALTER TABLE [dbo].[ConsentForm]  WITH CHECK ADD CHECK  (([status]='Expired' OR [status]='Withdrawn' OR [status]='Active'))
GO
ALTER TABLE [dbo].[Donor]  WITH CHECK ADD CHECK  (([sex]='Unknown' OR [sex]='Other' OR [sex]='Female' OR [sex]='Male'))
GO
ALTER TABLE [dbo].[Sample]  WITH CHECK ADD CHECK  (([status]='Disposed' OR [status]='Quarantined' OR [status]='Depleted' OR [status]='Available'))
GO
ALTER TABLE [dbo].[Sample]  WITH CHECK ADD CHECK  (([volume_ml]>(0)))
GO
ALTER TABLE [dbo].[SampleUsage]  WITH CHECK ADD CHECK  (([quantity_used_ml]>(0)))
GO
ALTER TABLE [dbo].[TestRequest]  WITH CHECK ADD CHECK  (([status]='Rejected' OR [status]='Completed' OR [status]='Approved' OR [status]='Pending'))
GO
/****** Object:  StoredProcedure [dbo].[sp_record_sample_usage]    Script Date: 8/15/2026 7:08:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Stored procedure: record usage and return remaining volume
CREATE PROCEDURE [dbo].[sp_record_sample_usage]
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
ALTER DATABASE [biobank] SET  READ_WRITE 
GO
