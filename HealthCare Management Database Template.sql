/*******************************************************************************
MIT License

Copyright (c) 2026 Surendra Reddy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--------------------------------------------------------------------------------
Project: Healthcare Management Database Template
Version: 1.0
Target Engine: SQL Server (T-SQL)
*******************************************************************************/

-- 1. DATABASE & SCHEMA SETUP
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'HealthcareDatabase')
BEGIN
    CREATE DATABASE HealthcareDatabase;
END
GO

USE HealthcareDatabase;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Healthcare')
BEGIN
    EXEC('CREATE SCHEMA Healthcare');
END
GO

-- 2. CORE TABLES
-- Patients
CREATE TABLE Healthcare.Patients (
    PatientID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Gender NVARCHAR(20),
    Phone NVARCHAR(20),
    Email NVARCHAR(150),
    Address NVARCHAR(500),
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CreatedBy NVARCHAR(50) NOT NULL DEFAULT 'Admin',
    DateCreated DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedBy NVARCHAR(50) NULL,
    DateUpdated DATETIME NULL
);

-- Providers
CREATE TABLE Healthcare.Providers (
    ProviderID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Specialty NVARCHAR(100),
    Phone NVARCHAR(20),
    Email NVARCHAR(150),
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CreatedBy NVARCHAR(50) NOT NULL DEFAULT 'Admin',
    DateCreated DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedBy NVARCHAR(50) NULL,
    DateUpdated DATETIME NULL
);

-- Insurance Payers
CREATE TABLE Healthcare.Payers (
    PayerID INT IDENTITY(1,1) PRIMARY KEY,
    PayerName NVARCHAR(200) NOT NULL,
    PolicyType NVARCHAR(50), -- Private, Government, Self-Pay
    ContactPhone NVARCHAR(20),
    IsActive BIT NOT NULL DEFAULT 1,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CreatedBy NVARCHAR(50) NOT NULL DEFAULT 'Admin',
    DateCreated DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedBy NVARCHAR(50) NULL,
    DateUpdated DATETIME NULL
);

-- Patient Insurance (Junction)
CREATE TABLE Healthcare.PatientInsurance (
    PatientInsuranceID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL,
    PayerID INT NOT NULL,
    PolicyNumber NVARCHAR(50),
    GroupNumber NVARCHAR(50),
    IsPrimary BIT NOT NULL DEFAULT 1,
    CreatedBy NVARCHAR(50) NOT NULL DEFAULT 'Admin',
    DateCreated DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedBy NVARCHAR(50) NULL,
    DateUpdated DATETIME NULL
    CONSTRAINT FK_Insurance_Patient FOREIGN KEY (PatientID) REFERENCES Healthcare.Patients(PatientID),
    CONSTRAINT FK_Insurance_Payer FOREIGN KEY (PayerID) REFERENCES Healthcare.Payers(PayerID)
);

-- Appointments
CREATE TABLE Healthcare.Appointments (
    AppointmentID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL,
    ProviderID INT NOT NULL,
    AppointmentDate DATETIME2 NOT NULL,
    Status NVARCHAR(50) NOT NULL, -- Scheduled, Completed, Cancelled
    Reason NVARCHAR(MAX),
    CreatedBy NVARCHAR(50) NOT NULL DEFAULT 'Admin',
    DateCreated DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedBy NVARCHAR(50) NULL,
    DateUpdated DATETIME NULL,
    CONSTRAINT FK_Appointments_Patient FOREIGN KEY (PatientID) REFERENCES Healthcare.Patients(PatientID),
    CONSTRAINT FK_Appointments_Provider FOREIGN KEY (ProviderID) REFERENCES Healthcare.Providers(ProviderID)
);

-- Billing
CREATE TABLE Healthcare.Billing (
    BillingID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL,
    AppointmentID INT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(50) NOT NULL, -- Pending, Paid, Denied
    PaymentMethod NVARCHAR(50),
    CreatedBy NVARCHAR(50) NOT NULL DEFAULT 'Admin',
    DateCreated DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedBy NVARCHAR(50) NULL,
    DateUpdated DATETIME NULL,
    CONSTRAINT FK_Billing_Patient FOREIGN KEY (PatientID) REFERENCES Healthcare.Patients(PatientID),
    CONSTRAINT FK_Billing_Appointment FOREIGN KEY (AppointmentID) REFERENCES Healthcare.Appointments(AppointmentID)
);

-- Medical Records
CREATE TABLE Healthcare.MedicalRecords (
    RecordID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL,
    ProviderID INT NOT NULL,
    Diagnosis NVARCHAR(MAX),
    Treatment NVARCHAR(MAX),
    Notes NVARCHAR(MAX),
    CreatedBy NVARCHAR(50) NOT NULL DEFAULT 'Admin',
    DateCreated DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedBy NVARCHAR(50) NULL,
    DateUpdated DATETIME NULL,
    CONSTRAINT FK_MedicalRecords_Patient FOREIGN KEY (PatientID) REFERENCES Healthcare.Patients(PatientID),
    CONSTRAINT FK_MedicalRecords_Provider FOREIGN KEY (ProviderID) REFERENCES Healthcare.Providers(ProviderID)
);

-- Prescriptions
CREATE TABLE Healthcare.Prescriptions (
    PrescriptionID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL,
    ProviderID INT NOT NULL,
    MedicationName NVARCHAR(200) NOT NULL,
    Dosage NVARCHAR(100),
    Frequency NVARCHAR(100),
    StartDate DATE,
    EndDate DATE,
    CreatedBy NVARCHAR(50) NOT NULL DEFAULT 'Admin',
    DateCreated DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedBy NVARCHAR(50) NULL,
    DateUpdated DATETIME NULL,
    CONSTRAINT FK_Prescription_Patient FOREIGN KEY (PatientID) REFERENCES Healthcare.Patients(PatientID),
    CONSTRAINT FK_Prescription_Provider FOREIGN KEY (ProviderID) REFERENCES Healthcare.Providers(ProviderID)
);

-- Audit Logs
CREATE TABLE Healthcare.AuditLogs (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(100) NOT NULL,
    RecordID INT NOT NULL,
    Action NVARCHAR(50) NOT NULL, -- INSERT, UPDATE, DELETE
    OldValue NVARCHAR(MAX),
    NewValue NVARCHAR(MAX),
    CreatedBy NVARCHAR(50) NOT NULL DEFAULT 'System',
    DateCreated DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- 3. INDEXES
CREATE INDEX IX_Patients_LastName ON Healthcare.Patients(LastName);
CREATE INDEX IX_Appointments_Date ON Healthcare.Appointments(AppointmentDate);
CREATE INDEX IX_Billing_Status ON Healthcare.Billing(Status);
GO

-- 4. VIEWS (Reporting)
-- Patient Appointment Summary
CREATE OR ALTER VIEW Healthcare.vw_PatientAppointments AS
SELECT 
    p.PatientID,
    p.FirstName,
    p.LastName,
    COUNT(a.AppointmentID) AS TotalAppointments
FROM Healthcare.Patients p
LEFT JOIN Healthcare.Appointments a ON p.PatientID = a.PatientID
WHERE p.IsDeleted = 0
GROUP BY p.PatientID, p.FirstName, p.LastName;
GO

-- Revenue Report
CREATE OR ALTER VIEW Healthcare.vw_RevenueReport AS
SELECT 
    FORMAT(DateCreated, 'yyyy-MM') AS Month,
    SUM(Amount) AS TotalRevenue
FROM Healthcare.Billing
WHERE Status = 'Paid'
GROUP BY FORMAT(DateCreated, 'yyyy-MM');
GO

-- Provider Workload
CREATE OR ALTER VIEW Healthcare.vw_ProviderWorkload AS
SELECT 
    pr.ProviderID,
    pr.FirstName,
    pr.LastName,
    COUNT(a.AppointmentID) AS TotalAppointments
FROM Healthcare.Providers pr
LEFT JOIN Healthcare.Appointments a ON pr.ProviderID = a.ProviderID
WHERE pr.IsActive = 1
GROUP BY pr.ProviderID, pr.FirstName, pr.LastName;
GO

-- 5. STORED PROCEDURES
-- Create Appointment
CREATE OR ALTER PROCEDURE Healthcare.sp_CreateAppointment
    @PatientID INT,
    @ProviderID INT,
    @AppointmentDate DATETIME2,
    @Reason NVARCHAR(MAX),
    @CreatedBy NVARCHAR(50) = 'Admin'
AS
BEGIN
    INSERT INTO Healthcare.Appointments (PatientID, ProviderID, AppointmentDate, Status, Reason, CreatedBy)
    VALUES (@PatientID, @ProviderID, @AppointmentDate, 'Scheduled', @Reason, @CreatedBy);
END;
GO

-- Record Payment
CREATE OR ALTER PROCEDURE Healthcare.sp_RecordPayment
    @BillingID INT,
    @PaymentMethod NVARCHAR(50),
    @UpdatedBy NVARCHAR(50)
AS
BEGIN
    UPDATE Healthcare.Billing
    SET Status = 'Paid',
        PaymentMethod = @PaymentMethod,
        UpdatedBy = @UpdatedBy,
        DateUpdated = GETDATE()
    WHERE BillingID = @BillingID;
END;
GO

-- Add Medical Record
CREATE OR ALTER PROCEDURE Healthcare.sp_AddMedicalRecord
    @PatientID INT,
    @ProviderID INT,
    @Diagnosis NVARCHAR(MAX),
    @Treatment NVARCHAR(MAX),
    @Notes NVARCHAR(MAX),
    @CreatedBy NVARCHAR(50)
AS
BEGIN
    INSERT INTO Healthcare.MedicalRecords (PatientID, ProviderID, Diagnosis, Treatment, Notes, CreatedBy)
    VALUES (@PatientID, @ProviderID, @Diagnosis, @Treatment, @Notes, @CreatedBy);
END;
GO

-- 6. AUDIT TRIGGER (T-SQL)
CREATE OR ALTER TRIGGER Healthcare.trg_Patients_Audit
ON Healthcare.Patients
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Handle INSERT
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO Healthcare.AuditLogs (TableName, RecordID, Action, OldValue, NewValue, CreatedBy)
        SELECT 'Patients', i.PatientID, 'INSERT', NULL, (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER), 'System'
        FROM inserted i;
    END

    -- Handle UPDATE
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO Healthcare.AuditLogs (TableName, RecordID, Action, OldValue, NewValue, CreatedBy)
        SELECT 'Patients', i.PatientID, 'UPDATE', 
               (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER), 
               (SELECT i.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER), 
               ISNULL(i.UpdatedBy, 'System')
        FROM inserted i
        JOIN deleted d ON i.PatientID = d.PatientID;
    END

    -- Handle DELETE
    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO Healthcare.AuditLogs (TableName, RecordID, Action, OldValue, NewValue, CreatedBy)
        SELECT 'Patients', d.PatientID, 'DELETE', (SELECT d.* FOR JSON PATH, WITHOUT_ARRAY_WRAPPER), NULL, 'System'
        FROM deleted d;
    END
END;
GO