DROP TABLE IF EXISTS fct_Telemetry;
DROP TABLE IF EXISTS fct_ProductionOutput;
DROP TABLE IF EXISTS fct_MachineEvents;
DROP TABLE IF EXISTS fct_ProductionPlan;
DROP TABLE IF EXISTS dim_Shifts;
DROP TABLE IF EXISTS dim_FailureCodes;
DROP TABLE IF EXISTS dim_Products;
DROP TABLE IF EXISTS dim_Machines;
DROP TABLE IF EXISTS dim_Lines;

CREATE TABLE dim_Lines(
	LineID INT IDENTITY(1,1) PRIMARY KEY,
	LineName VARCHAR(255)
)

CREATE TABLE dim_Machines(
	MachineID INT IDENTITY(1,1) PRIMARY KEY,
	LineID INT FOREIGN KEY REFERENCES dim_Lines(LineID),
	MachineName VARCHAR(255)
)

CREATE TABLE dim_Products(
	ProductID INT IDENTITY(1,1) PRIMARY KEY,
	ProductName VARCHAR(255),
	IdealCycleTime_sec DECIMAL(10,2),
	ValidFrom DATETIME2,
	ValidTo DATETIME2,
	IsCurrent BIT
)

CREATE TABLE dim_FailureCodes(
	FailureID INT IDENTITY(1,1) PRIMARY KEY,
	Code VARCHAR(255),
	Description VARCHAR(255),
	Category VARCHAR(255)
)

CREATE TABLE dim_Shifts(
	ShiftID INT IDENTITY(1,1) PRIMARY KEY,
	StartShiftDate DATETIME2,
	EndShiftDate DATETIME2,
	DayStartShiftDate DATETIME2,
	Week INT,
	DayNumber INT,
	DayName VARCHAR(255),
	ShiftType CHAR(1),
	ShiftName VARCHAR(255)
)

CREATE TABLE fct_ProductionPlan(
	PlanID INT IDENTITY(1,1) PRIMARY KEY,
	StartShiftDate DATETIME2,
	ShiftID INT FOREIGN KEY REFERENCES dim_Shifts(ShiftID),
	LineID INT FOREIGN KEY REFERENCES dim_Lines(LineID),
	ProductID INT FOREIGN KEY REFERENCES dim_Products(ProductID),
	TargetQuantity INT
)

CREATE TABLE fct_MachineEvents(
	EventID INT IDENTITY(1,1) PRIMARY KEY,
	MachineID INT FOREIGN KEY REFERENCES dim_Machines(MachineID),
	FailureID INT FOREIGN KEY REFERENCES dim_FailureCodes(FailureID),
	StartTime DATETIME2,
	EndTime DATETIME2,
	StateCode VARCHAR(255)
)

CREATE TABLE fct_ProductionOutput(
	ProductionOutputID INT IDENTITY(1,1) PRIMARY KEY,
	MachineID INT FOREIGN KEY REFERENCES dim_Machines(MachineID),
	ProductID INT FOREIGN KEY REFERENCES dim_Products(ProductID),
	IsGood BIT,
	IsScrap BIT
)

CREATE TABLE fct_Telemetry(
	ReadingID BIGINT IDENTITY(1,1) PRIMARY KEY,
	MachineID INT FOREIGN KEY REFERENCES dim_Machines(MachineID),
	DateKey BIGINT,
	TimeStamp DATETIME2,
	Temperature DECIMAL(5,2),
	VibrationLevel DECIMAL(10,2),
	RPM DECIMAL(10,2),
	PowerUsage DECIMAL(10,2)
)