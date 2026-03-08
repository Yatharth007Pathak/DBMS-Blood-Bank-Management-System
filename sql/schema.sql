DROP TABLE IF EXISTS requests;
DROP TABLE IF EXISTS blood_donations;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS donors;
DROP TABLE IF EXISTS admin;

CREATE DATABASE IF NOT EXISTS blood_bank;
USE blood_bank;

CREATE TABLE donors (
  donor_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  gender ENUM('M','F','O') DEFAULT 'O',
  age INT CHECK (age BETWEEN 18 AND 65),
  blood_group VARCHAR(5) NOT NULL,
  phone VARCHAR(10) UNIQUE,
  email VARCHAR(100) UNIQUE,
  city VARCHAR(100),
  last_donation DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_blood_group ON donors (blood_group);

CREATE TABLE inventory (
  unit_id INT AUTO_INCREMENT PRIMARY KEY,
  blood_group VARCHAR(5) NOT NULL,
  donor_id INT,
  quantity_ml INT DEFAULT 450 CHECK (quantity_ml > 0),
  blood_component ENUM('Whole Blood','Plasma','Platelets','RBC') DEFAULT 'Whole Blood',
  donation_date DATE DEFAULT (CURRENT_DATE),
  expiry_date DATE GENERATED ALWAYS AS (DATE_ADD(donation_date, INTERVAL 42 DAY)) STORED,
  storage_location VARCHAR(100) DEFAULT 'Refrigerator-1',
  storage_temperature DECIMAL(4,1) DEFAULT 4.0, 
  status ENUM('AVAILABLE','USED','EXPIRED') DEFAULT 'AVAILABLE',
  remarks VARCHAR(255) DEFAULT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (donor_id) REFERENCES donors(donor_id)
    ON UPDATE CASCADE ON DELETE SET NULL
);

-- Index for searching by blood group
CREATE INDEX idx_inventory_bg ON inventory(blood_group);

-- Requests Table (Hospital/Patient Requests)
CREATE TABLE requests (
  request_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_name VARCHAR(100) NOT NULL,
  hospital VARCHAR(150),
  blood_group VARCHAR(5) NOT NULL,
  units_requested INT CHECK (units_requested > 0),
  request_reason VARCHAR(255),
  status ENUM('PENDING','FULFILLED','REJECTED') DEFAULT 'PENDING',
  requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fulfilled_at DATETIME NULL,

  CONSTRAINT fk_req_bg FOREIGN KEY (blood_group) REFERENCES inventory(blood_group)
    ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Blood Donations Table
CREATE TABLE blood_donations (
  donation_id INT AUTO_INCREMENT PRIMARY KEY,
  donor_id INT NOT NULL,
  blood_group VARCHAR(5) NOT NULL,
  units_donated INT DEFAULT 1 CHECK (units_donated > 0),
  donation_date DATE DEFAULT (CURRENT_DATE),
  hemoglobin_level DECIMAL(4,1) DEFAULT 13.5,
  remarks VARCHAR(255),

  FOREIGN KEY (donor_id) REFERENCES donors(donor_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

-- Admin Table
CREATE TABLE admin (
  admin_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('ADMIN','STAFF') DEFAULT 'ADMIN',
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample Data
INSERT INTO donors (name, gender, age, blood_group, phone, email, city, last_donation) 
VALUES
('Rohan Singh','M',26,'A+','9876543210','rohan@example.com','Kanpur','2025-06-10'),
('Priya Sharma','F',30,'O+','9123456780','priya@example.com','Lucknow','2025-04-05'),
('Aman Dubey','M',22,'B+','9812345678','aman.d@example.com','Kanpur','2025-05-01'),
('Yatharth Pathak','M',21,'A+','9998765432','yatharth.p@example.com','Kanpur','2025-05-18'),
('Neha Verma','F',25,'AB+','9876501234','neha.v@example.com','Lucknow','2025-03-15'),
('Sanjay Yadav','M',28,'O-','9800123456','sanjay.y@example.com','Varanasi','2025-04-22'),
('Ritika Singh','F',24,'B+','9911223344','ritika.s@example.com','Kanpur','2025-05-09'),
('Arjun Gupta','M',29,'A-','9876001111','arjun.g@example.com','Agra','2025-06-02'),
('Simran Kaur','F',27,'AB-','9798787878','simran.k@example.com','Delhi','2025-01-20'),
('Rajesh Mishra','M',31,'O+','9822456789','rajesh.m@example.com','Lucknow','2025-03-25'),
('Nisha Tiwari','F',22,'B-','9811998822','nisha.t@example.com','Kanpur','2025-04-18'),
('Ankit Sharma','M',24,'O+','9776655443','ankit.s@example.com','Noida','2025-05-12'),
('Pooja Patel','F',26,'A+','9100112233','pooja.p@example.com','Kanpur','2025-02-10'),
('Ravi Kumar','M',27,'B+','9815544332','ravi.k@example.com','Lucknow','2025-06-01'),
('Kiran Devi','F',29,'O+','9711223344','kiran.d@example.com','Varanasi','2025-04-17'),
('Shubham Saini','M',23,'A+','9600998877','shubham.s@example.com','Delhi','2025-05-11'),
('Divya Singh','F',25,'O-','9588123456','divya.s@example.com','Kanpur','2025-03-10'),
('Vikas Chaurasia','M',32,'B-','9833123456','vikas.c@example.com','Lucknow','2025-02-18'),
('Swati Gupta','F',28,'AB+','9822345678','swati.g@example.com','Agra','2025-06-05'),
('Amit Patel','M',26,'O+','9810002222','amit.p@example.com','Kanpur','2025-05-08'),
('Nidhi Yadav','F',24,'A+','9788776655','nidhi.y@example.com','Varanasi','2025-04-02'),
('Deepak Verma','M',33,'B+','9777788889','deepak.v@example.com','Lucknow','2025-05-14'),
('Manisha Rai','F',27,'O-','9721122334','manisha.r@example.com','Delhi','2025-03-19'),
('Vivek Tripathi','M',25,'A-','9833445566','vivek.t@example.com','Kanpur','2025-05-06'),
('Isha Pandey','F',22,'B+','9911002233','isha.p@example.com','Noida','2025-04-12'),
('Mohit Sharma','M',29,'AB+','9844455566','mohit.s@example.com','Lucknow','2025-02-08'),
('Poonam Mishra','F',30,'O+','9900776655','poonam.m@example.com','Kanpur','2025-06-03'),
('Arnav Singh','M',23,'A+','9711445566','arnav.s@example.com','Varanasi','2025-04-09'),
('Rekha Chauhan','F',26,'B+','9822556677','rekha.c@example.com','Agra','2025-03-14'),
('Kartik Jain','M',28,'AB-','9812334455','kartik.j@example.com','Lucknow','2025-05-22');

-- Sample Inventory 
INSERT INTO inventory (blood_group, donor_id, quantity_ml, donation_date, storage_location, status)
VALUES
('A+', 1, 450, '2025-10-05', 'Refrigerator-1', 'AVAILABLE'),
('O+', 2, 450, '2025-10-20', 'Refrigerator-2', 'AVAILABLE'),
('B+', 3, 450, '2025-09-15', 'Refrigerator-3', 'USED'),
('A+', 4, 450, '2025-08-28', 'Refrigerator-1', 'EXPIRED'),
('AB-', 5, 450, '2025-10-11', 'Refrigerator-1', 'AVAILABLE'),
('O-', 6, 450, '2025-10-22', 'Refrigerator-2', 'AVAILABLE'),
('B+', 7, 450, '2025-09-15', 'Refrigerator-3', 'USED'),
('A-', 8, 450, '2025-08-09', 'Refrigerator-1', 'EXPIRED'),
('AB-', 9, 450, '2025-10-13', 'Refrigerator-1', 'AVAILABLE'),
('O+', 10, 450, '2025-10-27', 'Refrigerator-2', 'AVAILABLE'),
('AB+', 11, 450, '2025-09-30', 'Refrigerator-3', 'USED'),
('B-', 12, 450, '2025-08-04', 'Refrigerator-2', 'EXPIRED'),
('B-', 13, 450, '2025-10-18', 'Refrigerator-1', 'AVAILABLE'),
('A-', 14, 450, '2025-10-26', 'Refrigerator-2', 'AVAILABLE'),
('A-', 15, 450, '2025-10-16', 'Refrigerator-3', 'AVAILABLE');

-- Sample Requests
INSERT INTO requests (patient_name, hospital, blood_group, units_requested, status, request_reason)
VALUES
('Ananya Tiwari','Apollo Hospital','A+',2,'PENDING','Surgery'),
('Raghav Sharma','SGPGI','O+',3,'FULFILLED','Accident'),
('Preeti Yadav','Lala Lajpat Rai Hospital','B+',1,'PENDING','Delivery'),
('Kunal Singh','AIIMS Delhi','O-',2,'REJECTED','Unavailability'),
('Shalini Gupta','Regency Hospital','AB+',1,'FULFILLED','Anemia treatment');

-- Sample Blood Donations
INSERT INTO blood_donations (donor_id, blood_group, units_donated, donation_date, hemoglobin_level, remarks)
VALUES
(1,'A+',1,'2025-06-10','Whole Blood',14.5,'Regular Donor'),
(2,'O+',1,'2025-04-05','Whole Blood',15.2,'Healthy'),
(5,'AB+',2,'2025-03-15','Platelets',16.7,'High hemoglobin'),
(7,'B+',1,'2025-05-09','Plasma',14.1,'Regular Donor'),
(10,'O+',2,'2025-03-25','Platelets',14.8,'First-time donor'),
(13,'A+',1,'2025-02-10','Whole Blood',14.7,'Repeat donor'),
(18,'B-',1,'2025-02-18','Whole Blood',15.0,'Donated after 6 months'),
(25,'A-',1,'2025-05-06','Plasma',15.2,'Eligible donor'),
(30,'AB-',1,'2025-05-22','Whole Blood',15.2,'Rare blood type');
