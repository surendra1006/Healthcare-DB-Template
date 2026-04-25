
# Healthcare Management Database Template 🏥

A professional, reusable T-SQL database schema for healthcare providers. This template includes patient management, appointment scheduling, billing, insurance integration, and a full automated audit logging system.

## 🌟 Features
- **Comprehensive Schema:** Tables for Patients, Providers, Appointments, Billing, Payers (Insurance), and Prescriptions.
- **Automated Audit Logs:** Uses T-SQL triggers and JSON serialization to track every change in the Patients table.
- **Reporting Views:** Built-in views for Revenue tracking, Provider workload, and Patient history.
- **Stored Procedures:** Streamlined workflows for creating appointments and recording payments.
- **Scalable Design:** Uses `DATETIME2` for precision and `NVARCHAR(MAX)` for clinical notes.

## 🛠️ Technical Stack
- **Engine:** SQL Server (T-SQL)
- **Features Used:** Triggers, JSON PATH, Views, Stored Procedures, Foreign Key Constraints.

## 🚀 Getting Started

1. Open **SQL Server Management Studio (SSMS)** or **Azure Data Studio**.
2. Copy the contents of `/SQL/setup_database.sql`.
3. Execute the script to create the `HealthcareDatabase` and the `Healthcare` schema.

## 📊 Database Diagram Summary
- **Core:** `Patients`, `Providers`
- **Clinical:** `MedicalRecords`, `Prescriptions`
- **Operations:** `Appointments`, `AuditLogs`
- **Financial:** `Billing`, `Payers`, `PatientInsurance`

## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing
Contributions are welcome! Feel free to open an issue or submit a pull request.
