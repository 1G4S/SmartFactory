SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Igor>
-- Create date: <Create Date, 31.12.2025>
-- Description:	<Description, Telemetry data quality firewall>
-- =============================================

CREATE OR ALTER PROCEDURE LoadTelemetry
	@MachineID INT,
	@DateKey INT,
	@Timestamp DATETIME2,
	@Temperature FLOAT,
	@VibrationLevel FLOAT,
	@RPM FLOAT,
	@PowerUsage FLOAT
AS
BEGIN
-- Wylacza komunikaty wysylane do uzytkownika
	SET NOCOUNT ON;
	DECLARE @ErrorMessage VARCHAR(255);
	DECLARE @RawData VARCHAR(MAX);

	SET @RawData = CONCAT(
		'MachineID: ', @MachineID, '|',
		'DateKey: ', @DateKey, '|',
		'Timestamp: ', @Timestamp, '|',
		'Temp: ', @Temperature, '|',
		'Vib: ', @VibrationLevel, '|',
		'RPM: ', @RPM, '|',
		'Pwr: ', @PowerUsage
	);

	-- Sprawdzenie czy parametry maja poprawne wartosci
	IF (@Temperature < -20.0 OR @Temperature > 150.0)
		OR (@VibrationLevel < 0.0 OR @VibrationLevel > 50.0)
		OR (@RPM < 0.0 OR @RPM > 10000.0)
		OR (@PowerUsage < 0.0 OR @PowerUsage > 100.0)
	BEGIN
		-- Deklaracja wiadomosci do loga
		SET @ErrorMessage = 'Some value is out of range!'

		-- Proba przechwycenia wyjatku jesli podczas insertu pojdzie cos nie tak
		BEGIN TRY
			INSERT INTO ErrorLog (
				ProcedureName, 
				ErrorMessage, 
				RawData
			)
			VALUES(
				'usp_LoadTelemetry',
				@ErrorMessage,
				@RawData
			)
			RETURN;
		END TRY
	
		-- Przechwytujemy wyjatek jesli do niego doszlo i dodajemy informacje o bledach ktore wystapily
		BEGIN CATCH

			--Ladujemy do tabeli ErrorLog info o bledzie
			INSERT INTO ErrorLog (
				ProcedureName, 
				ErrorMessage, 
				RawData
			)
			VALUES(
				ERROR_PROCEDURE(),
				ERROR_MESSAGE(),
				@RawData
			);
			THROW;
		END CATCH
	END

	-- Dodajemy dane do tabeli faktów - fct_Telemetry
	BEGIN TRY
		INSERT INTO fct_Telemetry (
			MachineID,
			DateKey,
			Timestamp,
			Temperature,
			VibrationLevel,
			RPM,
			PowerUsage
		)
		VALUES (
			@MachineID,
			@DateKey,
			@Timestamp,
			@Temperature,
			@VibrationLevel,
			@RPM,
			@PowerUsage
		);

	END TRY
			
	BEGIN CATCH
		INSERT INTO ErrorLog (
			ProcedureName,
			ErrorMessage,
			RawData
		)
		VALUES (
			ERROR_PROCEDURE(),
			ERROR_MESSAGE(),
			@RawData
		);

		THROW;
	END CATCH
END;