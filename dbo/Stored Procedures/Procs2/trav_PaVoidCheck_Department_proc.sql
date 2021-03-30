
CREATE PROCEDURE dbo.trav_PaVoidCheck_Department_proc
AS
--PET:http://webfront:801/view.php?id=227706

BEGIN TRY
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


	CREATE TABLE #DeptHistEarn
	(
		[PostRun] [pPostRun] NOT NULL,
		[Id] [int] NOT NULL,
		[CheckId] [int],
		[VoidMonth] [smallint],
		PRIMARY KEY CLUSTERED ([PostRun], [Id])
	)


	--===========================
	--Employer Tax
	--===========================
	INSERT INTO dbo.tblPaDeptDtlAmount ([DeptDtlId], [EntryDate], [PaYear], [PaMonth], [Amount])
	SELECT d.[Id], @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, SUM(-h.[WithholdingAmount])
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistEmplrTax h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaTaxAuthorityHeader tah ON h.[TaxAuthorityType] = tah.[Type] 
		AND ISNULL(h.[State], '') = ISNULL(tah.[State], '') AND ISNULL(h.[Local], '') = ISNULL(tah.[Local], '')
	INNER JOIN dbo.tblPaDeptDtl d ON h.[DepartmentId] = d.[DepartmentId] AND h.[WithholdingCode] = d.[Code] AND tah.[Id] = d.[TaxAuthorityId]
	WHERE d.[Type] in (0, 1, 2) --0=Federal/1=State/2=Local
		AND l.[Status] = 0 
	GROUP BY d.[Id]
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
	

	--===========================
	--Deductions
	--===========================
	INSERT INTO dbo.tblPaDeptDtlAmount ([DeptDtlId], [EntryDate], [PaYear], [PaMonth], [Amount])
	SELECT d.[Id], @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, SUM(-h.[Amount])
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistEmplrCost h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaDeptDtl d ON h.[DepartmentId] = d.[DepartmentId] AND h.[DeductionCode] = d.[Code] 
	WHERE d.[Type] = 4 --Deductions
		AND l.[Status] = 0 
	GROUP BY d.[Id]
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END


	--===========================
	--Earnings
	--===========================
	INSERT INTO dbo.tblPaDeptDtlAmount ([DeptDtlId], [EntryDate], [PaYear], [PaMonth], [Amount])
	SELECT d.[Id], @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, SUM(-h.[EarningsAmount])
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistEarn h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaDeptDtl d ON h.[DepartmentId] = d.[DepartmentId] AND h.[EarningCode] = d.[Code] 
	WHERE d.[Type] = 3 --Earnings
		AND l.[Status] = 0 
	GROUP BY d.[Id]
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END


	--===========================
	--identify the earning history applied to the department detail
	--	(used to update earnings, hours worked and pieces)
	--===========================
	INSERT INTO #DeptHistEarn ([PostRun], [Id], [CheckId], [VoidMonth])
	SELECT h.[PostRun], h.[Id], h.[CheckId]
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistEarn h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaDeptDtl d ON h.[DepartmentId] = d.[DepartmentId] AND h.[EarningCode] = d.[Code] 
	WHERE d.[Type] = 3 --Earnings
		AND l.[Status] = 0 


	--===========================
	--Hours
	--===========================
	INSERT INTO dbo.tblPaDeptDtlAmount ([DeptDtlId], [EntryDate], [PaYear], [PaMonth], [Amount])
	SELECT d.[Id], @VoidDate, @PayrollYear, he.[VoidMonth]
		, SUM(-h.[HoursWorked])
	FROM #DeptHistEarn he
	INNER JOIN dbo.tblPaCheckHistEarn h ON he.[PostRun] = h.[PostRun] AND he.[Id] = h.[Id]
	INNER JOIN dbo.tblPaDeptDtl d ON h.[DepartmentId] = d.[DepartmentId] 
	WHERE d.[Type] = 5 --Hours
	GROUP BY d.[Id], he.[VoidMonth]
	

	--===========================
	--Pieces
	--===========================
	INSERT INTO dbo.tblPaDeptDtlAmount ([DeptDtlId], [EntryDate], [PaYear], [PaMonth], [Amount])
	SELECT d.[Id], @VoidDate, @PayrollYear, he.[VoidMonth]
		, SUM(-h.[Pieces])
	FROM #DeptHistEarn he
	INNER JOIN dbo.tblPaCheckHistEarn h ON he.[PostRun] = h.[PostRun] AND he.[Id] = h.[Id]
	INNER JOIN #VoidCheckLog l ON h.[PostRun] = l.[PostRun] AND h.[CheckId] = l.[Id]
	INNER JOIN dbo.tblPaDeptDtl d ON h.[DepartmentId] = d.[DepartmentId] 
	WHERE d.[Type] = 6 --Pieces
		AND l.[Type] = 1 --Manual Checks
		AND l.[Status] = 0 
	GROUP BY d.[Id], he.[VoidMonth]


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_Department_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_Department_proc';

