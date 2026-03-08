# DBMS-Blood-Bank-Management-System

A database-driven Blood Bank Management System developed as a DBMS mini-project.  
It helps blood banks efficiently manage donors, blood inventory, requests, patients, and basic operations.

<img width="1919" height="1017" alt="Screenshot 2026-03-07 211304" src="https://github.com/user-attachments/assets/d09aabcb-ba35-455a-b93b-1e6934c9a589" />

<img width="1919" height="1008" alt="Screenshot 2026-03-07 211253" src="https://github.com/user-attachments/assets/4ef8f616-d814-4990-913a-25a6d2daae49" />

<img width="1919" height="1012" alt="Screenshot 2026-03-07 211230" src="https://github.com/user-attachments/assets/c5d228bf-c6ab-4b95-a2fd-4d22350b28c0" />


## ✨ Features

- **Donor Management**
  - Register new donors with personal & medical details
  - View/search donor history
  - Track last donation date & eligibility

- **Blood Inventory Management**
  - Add blood units after donation
  - Track blood stock by group (A+, A-, B+, B-, etc.)
  - Automatic expiry date calculation
  - Low stock alerts

- **Blood Request & Issue System**
  - Patients/hospitals can request specific blood groups
  - Admin approves/rejects requests
  - Issue blood with recipient details

- **User Roles**
  - Admin: full access (manage everything)
  - Staff/Receptionist: limited access

- **Reports**
  - Blood stock summary
  - Donation history report
  - Donor list by blood group / city
  - Monthly / yearly statistics

- **Search & Filters**
  - Quick search donors by blood group, city, name, etc.
  - Filter blood stock
 
## 🛠️ Tech Stack

| Layer       | Technology                  | Notes                              |
|-------------|-----------------------------|------------------------------------|
| Frontend    | HTML, CSS, JavaScript       | ~54% HTML, ~22% JS, ~1% CSS       |
| Backend     | Python                      | ~22% of repo, see `requirements.txt` |
| Database    | MySQL / MariaDB (assumed)   | SQL scripts in `sql/` folder       |
| Dependencies| Listed in `requirements.txt`| Python packages                    |


