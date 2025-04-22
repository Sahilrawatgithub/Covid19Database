
CREATE DATABASE CovidDatabase;
USE CovidDatabase;
GO

CREATE TABLE Tb_Regions (
    RegionID INT IDENTITY(1,1) PRIMARY KEY,
    RegionName NVARCHAR(100) NOT NULL,
    Population INT,
    TotalCases INT DEFAULT 0,
    TotalDeaths INT DEFAULT 0,
    TotalVaccinated INT DEFAULT 0
);


CREATE TABLE Tb_Patients (
    PatientID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Gender NVARCHAR(10),
    Phone NVARCHAR(15),
    Email NVARCHAR(100),
    RegionID INT NOT NULL FOREIGN KEY REFERENCES Tb_Regions(RegionID)
);

CREATE TABLE Tb_TestCenters (
    CenterID INT IDENTITY(1,1) PRIMARY KEY,
    CenterName NVARCHAR(100) NOT NULL,
    Address NVARCHAR(255),
    RegionID INT NOT NULL FOREIGN KEY REFERENCES Tb_Regions(RegionID)
);


CREATE TABLE Tb_CovidTests (
    TestID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL FOREIGN KEY REFERENCES Tb_Patients(PatientID),
    CenterID INT NOT NULL FOREIGN KEY REFERENCES Tb_TestCenters(CenterID),
    TestDate DATETIME DEFAULT GETDATE(),
    TestType NVARCHAR(50) NOT NULL,
    Result NVARCHAR(50) NOT NULL CHECK (Result IN ('Positive', 'Negative', 'Inconclusive'))
);


CREATE TABLE Tb_Vaccinations (
    VaccinationID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL FOREIGN KEY REFERENCES Tb_Patients(PatientID),
    VaccineName NVARCHAR(100) NOT NULL,
    DoseNumber INT CHECK (DoseNumber IN (1, 2, 3, 4)),
    VaccinationDate DATETIME DEFAULT GETDATE(),
    CenterID INT NOT NULL FOREIGN KEY REFERENCES Tb_TestCenters(CenterID)
);


CREATE TABLE Tb_HealthWorkers (
    WorkerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Role NVARCHAR(50),
    AssignedCenterID INT NOT NULL FOREIGN KEY REFERENCES Tb_TestCenters(CenterID)
);

-- Insert values into tables
INSERT INTO Tb_Regions (RegionName, Population) VALUES
('Region A', 1000000),
('Region B', 500000);


INSERT INTO Tb_Patients (FullName, DOB, Gender, Phone, Email, RegionID) VALUES
('John Doe', '1990-01-01', 'Male', '1234567890', 'john.doe@example.com', 1),
('Jane Smith', '1985-05-15', 'Female', '0987654321', 'jane.smith@example.com', 2);

INSERT INTO Tb_Patients (FullName, DOB, Gender, Phone, Email, RegionID) VALUES
('sahil not', '1990-01-01', 'Male', '1234567890', 'john.doe@example.com', 1),
('abhishek not', '1985-05-15', 'Female', '0987654321', 'jane.smith@example.com', 2);



INSERT INTO Tb_TestCenters (CenterName, Address, RegionID) VALUES
('Center 1', '123 Main Street', 1),
('Center 2', '456 Elm Street', 2);


INSERT INTO Tb_CovidTests (PatientID, CenterID, TestType, Result) VALUES
(1, 1, 'PCR', 'Positive'),
(2, 2, 'Antigen', 'Negative');

INSERT INTO Tb_CovidTests (PatientID, CenterID, TestType, Result) VALUES
(3, 1, 'PCR', 'Positive'),
(4, 2, 'Antigen', 'Positive');


INSERT INTO Tb_Vaccinations (PatientID, VaccineName, DoseNumber, CenterID) VALUES
(1, 'Pfizer', 1, 1),
(2, 'Moderna', 1, 2);

INSERT INTO Tb_Vaccinations (PatientID, VaccineName, DoseNumber, CenterID) VALUES
(3, 'Pfizer', 1, 2)




INSERT INTO Tb_HealthWorkers (FullName, Role, AssignedCenterID) VALUES
('Dr. Alice', 'Doctor', 1),
('Nurse Bob', 'Nurse', 2);


--Query to get the total number of COVID-19 cases in each region

select
    R.RegionName,
    (
        select count(P.PatientID)
        from Tb_Patients P
        left join Tb_CovidTests CT on P.PatientID = CT.PatientId
        where P.RegionID = R.RegionID and CT.Result = 'positive'
    ) as totalPatients
from Tb_Regions R;


--Query to get the number of vaccinated patients per region.

select R.RegionName,Count(V.VaccinationId) AS TotalVaccinated
from Tb_Regions R
left join Tb_Patients P 
on P.RegionID=R.RegionId
left join Tb_Vaccinations V
on V.PatientID=P.PatientID
group by R.RegionName


--List patients with positive test results.

select P.FullName,P.Phone,P.DOB,CT.TestType,CT.Result
from Tb_Patients P
left join Tb_CovidTests CT on
CT.PatientID=P.PatientID


--Get vaccination details of a specific patient.

select P.FullName,V.VaccinationID,V.DoseNumber,V.VaccineName
from Tb_Patients P
left join Tb_Vaccinations V on
V.PatientID=P.PatientID
WHERE P.FullName='sahil not'


--Find test centers that have conducted more than a specified number of tests.

select 
    TC.CenterName,
    COUNT(CT.TestID) as TotalTests
from 
    Tb_TestCenters TC
left join 
    Tb_CovidTests CT on TC.CenterID = CT.CenterID
group by
    TC.CenterName
having
    COUNT(CT.TestID) > 1;


--List health workers assigned to each test center.

select
    TC.CenterName,
    HW.FullName,
    HW.Role
from
    Tb_TestCenters TC
left join
    Tb_HealthWorkers HW on TC.CenterID = HW.AssignedCenterID;