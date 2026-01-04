DELETE FROM fct_Telemetry;
DELETE FROM fct_ProductionOutput;
DELETE FROM fct_MachineEvents;
DELETE FROM fct_ProductionPlan;
DELETE FROM dim_Machines;
DELETE FROM dim_Lines;
DELETE FROM dim_Products;
DELETE FROM dim_FailureCodes;
DELETE FROM dim_Shifts;

DBCC CHECKIDENT ('dim_Lines', RESEED, 1);
DBCC CHECKIDENT ('dim_Machines', RESEED, 1);
DBCC CHECKIDENT ('dim_Products', RESEED, 1);
DBCC CHECKIDENT ('dim_FailureCodes', RESEED,1);
DBCC CHECKIDENT ('dim_Shifts', RESEED, 1);

SET NOCOUNT ON;

INSERT INTO dim_Lines (LineName)
VALUES 
('Linia Monta¿u Silników'),
('Linia Spawalnicza A'),
('Linia Lakiernicza');

INSERT INTO dim_Machines (LineID, MachineName)
VALUES 
(1, 'Robot Monta¿owy ABB 01'),
(1, 'Robot Monta¿owy ABB 02'),
(2, 'Spawarka Laserowa KUKA 01'),
(2, 'Spawarka Punktowa 02'),
(3, 'Kabina Lakiernicza Auto');

INSERT INTO dim_Products (ProductName, IdealCycleTime_sec, ValidFrom, ValidTo, IsCurrent)
VALUES 
('Silnik V6 Diesel', 120.00, '2020-01-01', NULL, 1),
('Skrzynia Biegów Auto', 300.00, '2020-01-01', NULL, 1),
('Drzwi Prawy Przód', 45.50, '2023-01-01', NULL, 1);

INSERT INTO dim_FailureCodes (Code, Description, Category)
VALUES 
('E001', 'Zatrzymanie awaryjne (E-STOP)', 'Safety'),
('M023', 'Przeci¹¿enie silnika serwo', 'Mechanical'),
('T005', 'Przekroczenie temp. g³owicy', 'Temperature'),
('S001', 'Brak materia³u na wejœciu', 'Logistic'),
('Q002', 'B³¹d wizyjny kamery', 'Quality');

DECLARE @StartDate DATE = '2026-01-01';
DECLARE @EndDate DATE = '2026-12-31';  
DECLARE @LoopDate DATE = @StartDate;

WHILE @LoopDate <= @EndDate
BEGIN
    DECLARE @DayBase DATETIME2 = CAST(@LoopDate AS DATETIME2);
    DECLARE @WeekNum INT = DATEPART(ISO_WEEK, @LoopDate);
    DECLARE @DayNum INT = DATEPART(WEEKDAY, @LoopDate);
    DECLARE @DayName VARCHAR(50) = DATENAME(WEEKDAY, @LoopDate);

    INSERT INTO dim_Shifts (
        StartShiftDate, 
        EndShiftDate, 
        DayStartShiftDate, 
        Week, 
        DayNumber, 
        DayName, 
        ShiftType, 
        ShiftName,
        KeyDate
        )
    VALUES (
        DATEADD(HOUR, 6, @DayBase), 
        DATEADD(HOUR, 14, @DayBase), 
        @DayBase, 
        @WeekNum, 
        @DayNum, 
        @DayName, 
        '1', 
        'Zmiana Poranna',
        CONVERT(INT, FORMAT(CAST(@DayBase AS Date), 'yyyMMdd'))
        );
    
    INSERT INTO dim_Shifts (
        StartShiftDate, 
        EndShiftDate, 
        DayStartShiftDate, 
        Week, 
        DayNumber, 
        DayName, 
        ShiftType, 
        ShiftName,
        KeyDate
        )
    VALUES (
        DATEADD(HOUR, 14, @DayBase), 
        DATEADD(HOUR, 22, @DayBase), 
        @DayBase, 
        @WeekNum, 
        @DayNum, 
        @DayName, 
        '2', 
        'Zmiana Popo³udniowa',
        CONVERT(INT, FORMAT(CAST(@DayBase AS Date), 'yyyMMdd'))
        );

    INSERT INTO dim_Shifts (
        StartShiftDate, 
        EndShiftDate, 
        DayStartShiftDate, 
        Week, 
        DayNumber, 
        DayName, 
        ShiftType, 
        ShiftName,
        KeyDate
        )
    VALUES (
        DATEADD(HOUR, 22, @DayBase), 
        DATEADD(HOUR, 30, @DayBase), 
        @DayBase, 
        @WeekNum, 
        @DayNum, 
        @DayName, 
        '3', 
        'Zmiana Nocna',
        CONVERT(INT, FORMAT(CAST(@DayBase AS Date), 'yyyMMdd'))
    );

    SET @LoopDate = DATEADD(DAY, 1, @LoopDate);
END