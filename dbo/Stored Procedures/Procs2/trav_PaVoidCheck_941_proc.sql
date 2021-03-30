
CREATE PROCEDURE dbo.trav_PaVoidCheck_941_proc
AS
BEGIN TRY

--PET:http://webfront:801/view.php?id=227570
--PET:http://webfront:801/view.php?id=227706
--PET:http://problemtrackingsystem.osas.com/view.php?id=263987

	DECLARE @PayrollYear smallint
	DECLARE @PayrollMonth smallint
	DECLARE @VoidToPayrollMonth smallint
    DECLARE @VoidDate datetime
	   
	SELECT @PayrollYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PayrollYear'
	SELECT @PayrollMonth = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PayrollMonth'
	SELECT @VoidToPayrollMonth = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'VoidToPayrollMonth'
    SELECT @VoidDate = Cast([Value] AS DateTime) FROM #GlobalValues WHERE [Key] = 'VoidDate'
	   
	IF @PayrollYear IS NULL OR @PayrollMonth IS NULL
		OR @VoidToPayrollMonth IS NULL OR @VoidDate IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END


	--===========================
	--Employer tax
	--===========================
	INSERT INTO dbo.tblPa941ScheduleB ([PaYear], [PaMonth], [PaDay], [Amount])
	SELECT @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, DAY(@VoidDate), SUM(-h.[WithholdingAmount])
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistEmplrTax h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaTaxAuthorityHeader tah ON h.[TaxAuthorityType] = tah.[Type]
	INNER JOIN dbo.tblPaTaxAuthorityDetail tad ON tah.[Id] = tad.[TaxAuthorityId] AND h.[WithholdingCode] = tad.[Code]
	WHERE h.[TaxAuthorityType] = 0 --Federal
		AND tad.[PaYear] = @PayrollYear AND tad.EmployerPaid = 1 AND tad.CodeType <> 2 --2=Unemployment Tax
		AND l.[Status] = 0 
	GROUP BY DAY(l.[CheckDate])
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		
		
	--===========================
	--Withholding
	--===========================
	INSERT INTO dbo.tblPa941ScheduleB ([PaYear], [PaMonth], [PaDay], [Amount])
	SELECT @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, DAY(@VoidDate), SUM(-h.[WithholdingAmount])
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistWithhold h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	WHERE h.[TaxAuthorityType] = 0 --Federal
		AND l.[Status] = 0 
	GROUP BY DAY(l.[CheckDate])
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_941_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_941_proc';

