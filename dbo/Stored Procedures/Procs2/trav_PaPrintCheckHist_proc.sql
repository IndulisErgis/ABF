
CREATE PROCEDURE dbo.trav_PaPrintCheckHist_proc
@PostRun pPostRun, 
@CheckId int, 
@PrintingCheck bit, 
@EmployeeId pEmpID, 
@CheckDate datetime

AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @YearBegin nvarchar(4), @YearBeginDate datetime

	SELECT @YearBegin = CAST(DATEPART(YY, @CheckDate) AS nvarchar)
	SELECT @YearBeginDate = @YearBegin + '0101'

	CREATE TABLE #Empty
	(
		CheckId int NULL
	)

	CREATE TABLE #Checks
	(
		PostRun pPostRun, 
		CheckId int, 
		DepartmentId pDeptID, 
		EmployeeId pEmpID, 
		SocialSecurityNo nvarchar(255), 
		VoucherNumber nvarchar(50), 
		CheckNumber pCheckNum, 
		CheckDate datetime, 
		NetPay pDecimal, 
		GrossPay pDecimal
	)
	
	CREATE TABLE #DirectDeposit
	(
		CheckId int, 
		CurrentAmount pDecimal, 
		CurrentAmountYTD pDecimal
	)
	
	CREATE TABLE #Earnings
	(
		CheckId int, 
		EarningCode pCode, 
		[Description] nvarchar(40), 
		HoursWorked pDecimal, 
		HoursWorkedYTD pDecimal, 
		CurrentAmount pDecimal, 
		CurrentAmountYTD pDecimal
	)
	
	CREATE TABLE #Deductions
	(
		CheckId int, 
		DeductionCode pCode, 
		[Description] nvarchar(30), 
		CurrentAmount pDecimal, 
		CurrentAmountYTD pDecimal
	)

	CREATE TABLE #Withholdings
	(
		CheckId int, 
		TaxAuthorityType tinyint, 
		[State] nvarchar(2), 
		[Local] nvarchar(2), 
		WithholdingCode nvarchar(3), 
		[Description] nvarchar(30), 
		CurrentAmount pDecimal, 
		CurrentAmountYTD pDecimal
	)

	INSERT INTO #Checks (PostRun, CheckId, DepartmentId, EmployeeId, SocialSecurityNo
		, VoucherNumber, CheckNumber, CheckDate, NetPay, GrossPay) 
	SELECT PostRun, Id AS CheckId, DepartmentId, EmployeeId, SocialSecurityNo, VoucherNumber, CheckNumber
		, CheckDate, NetPay, GrossPay 
	FROM dbo.tblPaCheckHist 
	WHERE Voided = 0 AND EmployeeId = @EmployeeId AND CheckDate BETWEEN @YearBeginDate AND @CheckDate

	INSERT INTO #DirectDeposit (CheckId, CurrentAmount, CurrentAmountYTD) 
	SELECT @CheckId AS CheckId
		, ISNULL(SUM(CASE WHEN d.PostRun = @PostRun AND d.CheckId = @CheckId THEN d.CurrentAmount 
			ELSE 0 END), 0) AS CurrentAmount
		, ISNULL(SUM(d.CurrentAmount), 0) AS CurrentAmountYTD 
	FROM dbo.tblPaCheckHistDistribution d 
		INNER JOIN #Checks c ON d.PostRun = c.PostRun AND d.CheckId = c.CheckId

	INSERT INTO #Earnings (CheckId, EarningCode, [Description]
		, HoursWorked, HoursWorkedYTD, CurrentAmount, CurrentAmountYTD) 
	SELECT @CheckId, e.EarningCode, earn.[Description]
		, CASE WHEN e.PostRun = @PostRun AND e.CheckId = @CheckId THEN e.HoursWorked ELSE 0 END AS HoursWorked
		, e.HoursWorked AS HoursWorkedYTD
		, CASE WHEN e.PostRun = @PostRun AND e.CheckId = @CheckId THEN e.EarningsAmount ELSE 0 END AS CurrentAmount
		, e.EarningsAmount AS CurrentAmountYTD 
	FROM dbo.tblPaCheckHistEarn e 
		INNER JOIN #Checks c ON e.PostRun = c.PostRun AND e.CheckId = c.CheckId 
		LEFT JOIN dbo.tblPaEarnCode earn ON e.EarningCode = earn.Id

	INSERT INTO #Deductions (CheckId, DeductionCode, [Description], CurrentAmount, CurrentAmountYTD) 
	SELECT @CheckId, d.DeductionCode, ded.[Description]
		, CASE WHEN d.PostRun = @PostRun AND d.CheckId = @CheckId THEN d.Amount ELSE 0 END AS CurrentAmount
		, d.Amount AS CurrentAmountYTD 
	FROM dbo.tblPaCheckHistDeduct d 
		INNER JOIN #Checks c ON d.PostRun = c.PostRun AND d.CheckId = c.CheckId 
		LEFT JOIN dbo.tblPaDeductCode ded ON d.DeductionCode = ded.DeductionCode

	INSERT INTO #Withholdings(CheckId, TaxAuthorityType, [State], [Local]
		, WithholdingCode, [Description], CurrentAmount, CurrentAmountYTD) 
	SELECT @CheckId, TaxAuthorityType, [State], [Local], w.WithholdingCode, w.[Description]
		, CASE WHEN w.PostRun = @PostRun AND w.CheckId = @CheckId THEN w.WithholdingAmount 
			ELSE 0 END AS CurrentAmount
		, w.WithholdingAmount AS CurrentAmountYTD 
	FROM dbo.tblPaCheckHistWithhold w 
		INNER JOIN #Checks c ON w.PostRun = c.PostRun AND w.CheckId = c.CheckId

	--Table - Check Detail
	SELECT c.CheckId, c.EmployeeId AS GroupLevel0, c.DepartmentId, c.EmployeeId
		, COALESCE(e.LastName, '') + ', ' + COALESCE(e.FirstName, '') + ' ' + COALESCE(e.MiddleInit, '') AS EmployeeName
		, e.FirstName + CASE WHEN e.MiddleInit IS NULL THEN '' ELSE ' ' + e.MiddleInit END + ' ' + e.LastName AS FML
		, c.SocialSecurityNo, CASE @PrintingCheck WHEN 0 THEN c.VoucherNumber ELSE c.CheckNumber END AS CheckNumber
		, c.CheckDate, e.AddressLine1, e.AddressLine2, e.ResidentCity, e.ResidentState, e.ZipCode
		, e.CountryCode, NULL AS PeriodBegin, c.NetPay
		, ISNULL(c.NetPay, 0) - ISNULL(dist.CurrentAmount, 0) AS NetCheckAmount
		, ISNULL(dist.CurrentAmount, 0) AS DirectDepositAmount
		, 0.00 AS HourlyRate, c.GrossPay
		, ISNULL(ded.CurrentAmount, 0) + ISNULL(wh.CurrentAmount, 0) AS CurrentDeductions
		, earn.CurrentAmountYTD AS YTDEarnings
		, ISNULL(ded.CurrentAmountYTD, 0) + ISNULL(wh.CurrentAmountYTD, 0) AS YTDDeductions
		, checks.YTDNetPay AS YTDNetPay 
	FROM #Checks c 
		LEFT JOIN dbo.tblSmEmployee e ON c.EmployeeId = e.EmployeeId 
		LEFT JOIN #DirectDeposit dist ON dist.CheckId = c.CheckId
		LEFT JOIN (SELECT @CheckId AS CheckId, SUM(NetPay) AS YTDNetPay FROM #Checks) checks ON checks.CheckId = c.CheckId 
		LEFT JOIN (SELECT @CheckId AS CheckId, SUM(CurrentAmount) AS CurrentAmount, SUM(CurrentAmountYTD) AS CurrentAmountYTD FROM #Earnings) earn ON checks.CheckId = c.CheckId 
		LEFT JOIN (SELECT @CheckId AS CheckId, SUM(CurrentAmount) AS CurrentAmount, SUM(CurrentAmountYTD) AS CurrentAmountYTD FROM #Deductions) ded ON checks.CheckId = c.CheckId 
		LEFT JOIN (SELECT @CheckId AS CheckId, SUM(CurrentAmount) AS CurrentAmount, SUM(CurrentAmountYTD) AS CurrentAmountYTD FROM #Withholdings) wh ON checks.CheckId = c.CheckId 
	WHERE c.PostRun = @PostRun AND c.CheckId = @CheckId

	--Table1 - Direct Deposit Distributions
	SELECT NULL AS CheckId, NULL AS DistributionId, NULL AS AccountType, NULL AS AccountNumber, NULL AS CurrentAmount 
	FROM #Empty

	--Table2 - Earnings
	SELECT CheckId, [Description], SUM(HoursWorked) AS HoursWorked
		, SUM(CurrentAmount) AS CurrentAmount, SUM(CurrentAmountYTD) AS YTDAmount 
	FROM #Earnings 
	GROUP BY CheckId, EarningCode, [Description] 
	HAVING SUM(CurrentAmountYTD) <> 0

	--Table3 - Leave
	SELECT NULL AS CheckId, NULL AS [Description], NULL AS HoursRemaining 
	FROM #Empty

	--Table4 - Deductions
	SELECT CheckId, [Description], SUM(CurrentAmount) AS CurrentAmount, SUM(CurrentAmountYTD) AS YTDAmount 
	FROM #Deductions 
	GROUP BY CheckId, DeductionCode, [Description] 
	HAVING SUM(CurrentAmount) <> 0
	UNION
	SELECT CheckId, [Description], SUM(CurrentAmount) AS CurrentAmount, SUM(CurrentAmountYTD) AS YTDAmount 
	FROM #Withholdings 
	GROUP BY CheckId, TaxAuthorityType, [State], [Local], WithholdingCode, [Description] 
	HAVING SUM(CurrentAmountYTD) <> 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaPrintCheckHist_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaPrintCheckHist_proc';

