
CREATE PROCEDURE dbo.trav_PaVoidCheck_EmployeeHistory_proc
AS

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


	--===========================
	--Earnings
	--===========================
	INSERT INTO dbo.tblPaEmpHistEarn ([EntryDate], [PaYear], [PaMonth]
		, [EmployeeId], [EarningCode], [Hours], [Amount])
	SELECT @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, l.[EmployeeId], h.[EarningCode], -h.[HoursWorked], -h.[EarningsAmount]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistEarn h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	WHERE l.[Status] = 0 

	--===========================
	--Deductions
	--===========================
	--Deduction history
	INSERT INTO dbo.tblPaEmpHistDeduct ([EntryDate], [PaYear], [PaMonth]
		, [EmployeeId], [DeductionCode], [EmployerPaid], [Amount])
	SELECT @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, l.[EmployeeId], h.[DeductionCode], 0, -h.[Amount]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistDeduct h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	WHERE l.[Status] = 0 


	--Deduction Balance (Employee Paid)
	--	(only update for period codes that are setup for deductions)
	--  PeriodCode Enums: 2;DecliningBalance;6;DecliningBalanceByPercent;7;DecliningBalanceByFormula
	UPDATE dbo.tblPaEmpDeduct SET dbo.tblPaEmpDeduct.[Balance] = dbo.tblPaEmpDeduct.[Balance] + s.[TotalAmount]
	FROM (
		SELECT ed.[Id]
			, SUM(
				CASE WHEN (h.[PeriodRunCode] = 1 AND ed.[PeriodCode1] IN (2, 6, 7))
					OR (h.[PeriodRunCode] = 2 AND ed.[PeriodCode2] IN (2, 6, 7))
					OR (h.[PeriodRunCode] = 3 AND ed.[PeriodCode3] IN (2, 6, 7))
					OR (h.[PeriodRunCode] = 4 AND ed.[PeriodCode4] IN (2, 6, 7))
					OR (h.[PeriodRunCode] = 5 AND ed.[PeriodCode5] IN (2, 6, 7))
				THEN hd.[Amount]
				ELSE 0
				END
			) AS [TotalAmount]
		FROM #VoidCheckLog l
		INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[Id]
		INNER JOIN dbo.tblPaCheckHistDeduct hd ON h.[PostRun] = hd.[PostRun] AND h.[Id] = hd.[CheckId]
		INNER JOIN dbo.tblPaDeductCode d ON hd.[DeductionCode] = d.[DeductionCode]
		INNER JOIN dbo.tblPaEmpDeduct ed ON h.[PaYear] = ed.[PaYear] AND h.[EmployeeId] = ed.[EmployeeId] AND d.[Id] = ed.[DeductionCodeId]
		WHERE d.[EmployerPaid] = 0
			AND l.[Status] = 0 
		GROUP BY ed.[Id]
	) s
	WHERE dbo.tblPaEmpDeduct.[Id] = s.[Id]


	--Employer cost history
	INSERT INTO dbo.tblPaEmpHistDeduct ([EntryDate], [PaYear], [PaMonth]
		, [EmployeeId], [DeductionCode], [EmployerPaid], [Amount])
	SELECT @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, l.[EmployeeId], h.[DeductionCode], 1, -h.[Amount]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistEmplrCost h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	WHERE l.[Status] = 0 


	--Employer cost Balance (Employer Paid)
	--	(only update for period codes that are setup for deductions)
	--  PeriodCode Enums: 2;DecliningBalance;6;DecliningBalanceByPercent;7;DecliningBalanceByFormula
	UPDATE dbo.tblPaEmpDeduct SET dbo.tblPaEmpDeduct.[Balance] = dbo.tblPaEmpDeduct.[Balance] + s.[TotalAmount]
	FROM (
		SELECT ed.[Id]
			, SUM(
				CASE WHEN (h.[PeriodRunCode] = 1 AND ed.[PeriodCode1] IN (2, 6, 7))
					OR (h.[PeriodRunCode] = 2 AND ed.[PeriodCode2] IN (2, 6, 7))
					OR (h.[PeriodRunCode] = 3 AND ed.[PeriodCode3] IN (2, 6, 7))
					OR (h.[PeriodRunCode] = 4 AND ed.[PeriodCode4] IN (2, 6, 7))
					OR (h.[PeriodRunCode] = 5 AND ed.[PeriodCode5] IN (2, 6, 7))
				THEN hd.[Amount]
				ELSE 0
				END
			) AS [TotalAmount]
		FROM #VoidCheckLog l
		INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[Id]
		INNER JOIN dbo.tblPaCheckHistEmplrCost hd ON h.[PostRun] = hd.[PostRun] AND h.[Id] = hd.[CheckId]
		INNER JOIN dbo.tblPaDeductCode d ON hd.[DeductionCode] = d.[DeductionCode]
		INNER JOIN dbo.tblPaEmpDeduct ed ON h.[PaYear] = ed.[PaYear] AND h.[EmployeeId] = ed.[EmployeeId] AND d.[Id] = ed.[DeductionCodeId]
		WHERE d.[EmployerPaid] = 1
			AND l.[Status] = 0 
		GROUP BY ed.[Id]
	) s
	WHERE dbo.tblPaEmpDeduct.[Id] = s.[Id]


	--===========================
	--Withholdings
	--===========================
	--Withholding
	INSERT INTO dbo.tblPaEmpHistWithhold ([EntryDate], [PaYear], [PaMonth]
		, [EmployeeId], [TaxAuthorityType], [State], [Local]
		, [WithholdingCode], [EmployerPaid], [EarningAmount], [TaxableAmount], [WithholdAmount])
	SELECT @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, l.[EmployeeId], h.[TaxAuthorityType], h.[State], h.[Local]
		, h.[WithholdingCode], 0, -h.[GrossEarnings], -h.[WithholdingEarnings], -h.[WithholdingAmount]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistWithhold h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	WHERE l.[Status] = 0 


	--Employer Tax
	INSERT INTO dbo.tblPaEmpHistWithhold ([EntryDate], [PaYear], [PaMonth]
		, [EmployeeId], [TaxAuthorityType], [State], [Local]
		, [WithholdingCode], [EmployerPaid], [EarningAmount], [TaxableAmount], [WithholdAmount])
	SELECT @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, l.[EmployeeId], h.[TaxAuthorityType], h.[State], h.[Local]
		, h.[WithholdingCode], 1, -h.[GrossEarnings], -h.[WithholdingEarnings], -h.[WithholdingAmount]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistEmplrTax h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	WHERE l.[Status] = 0 


	--===========================
	--Gross/Net
	--===========================
	INSERT INTO dbo.tblPaEmpHistGrossNet ([EntryDate], [PaYear], [PaMonth]
		, [EmployeeId], [GrossPayAmount], [NetPayAmount])
	SELECT @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, l.[EmployeeId], -l.[GrossPay], -l.[NetPay]
	FROM #VoidCheckLog l
	WHERE l.[GrossPay] <> 0 OR l.[NetPay] <> 0
		AND l.[Status] = 0 

	
	--===========================
	--Leave
	--===========================
	--add any leave taken
	INSERT INTO dbo.tblPaEmpHistLeave ([EntryDate], [PaYear], [PaMonth]
		, [EmployeeId], [LeaveCodeId], [PrintedFlag], [From], [EarningCode]
		, [Description], [CheckNumber], [AdjustmentDate], [AdjustmentAmount])
	SELECT @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, l.[EmployeeId], h.[LeaveCodeId], 0, 'VC', h.[EarningCode]
		, 'Void Checks', l.[CheckNumber], l.[CheckDate], h.[HoursWorked]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistEarn h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	WHERE NULLIF(h.[LeaveCodeId], '') IS NOT NULL AND h.[HoursWorked] <> 0
		AND l.[Status] = 0 

	--remove any leave accrued
	INSERT INTO dbo.tblPaEmpHistLeave ([EntryDate], [PaYear], [PaMonth]
		, [EmployeeId], [LeaveCodeId], [PrintedFlag], [From]
		, [Description], [CheckNumber], [AdjustmentDate], [AdjustmentAmount])
	SELECT @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, l.[EmployeeId], h.[LeaveCodeId], 0, 'VC'
		, 'Void Checks', l.[CheckNumber], l.[CheckDate], -h.[HoursAccrued]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistLeave h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	WHERE NULLIF(h.[LeaveCodeId], '') IS NOT NULL AND h.[HoursAccrued] <> 0
		AND l.[Status] = 0 
	

	--===========================
	--Misc
	--===========================
	--Hours Worked
	INSERT INTO dbo.tblPaEmpHistMisc ([EntryDate], [PaYear], [PaMonth], [EmployeeId], [Amount], [MiscCodeId])
	SELECT @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, l.[EmployeeId], -SUM(h.[HoursWorked]), 1 --Hours Worked
	FROM #VoidCheckLog l 
	INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun]  = h.[PostRun] AND l.[Id] = h.[Id]
	WHERE l.[Status] = 0 
	GROUP BY l.[EmployeeId]
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
	HAVING SUM(h.[HoursWorked]) <> 0

	--Weeks Worked
	INSERT INTO dbo.tblPaEmpHistMisc ([EntryDate], [PaYear], [PaMonth], [EmployeeId], [Amount], [MiscCodeId])
	SELECT @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, l.[EmployeeId], -SUM(h.[WeeksWorked]), 2 --Weeks Worked
	FROM #VoidCheckLog l 
	INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun]  = h.[PostRun] AND l.[Id] = h.[Id]
	WHERE l.[Status] = 0 
	GROUP BY l.[EmployeeId]
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
	HAVING SUM(h.[WeeksWorked]) <> 0

	--Weeks Under Limit
	INSERT INTO dbo.tblPaEmpHistMisc ([EntryDate], [PaYear], [PaMonth], [EmployeeId], [Amount], [MiscCodeId])
	SELECT @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, l.[EmployeeId], -SUM(h.[WeeksUnderLimit]), 3 --Weeks Under Limit
	FROM #VoidCheckLog l 
	INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun]  = h.[PostRun] AND l.[Id] = h.[Id]
	WHERE l.[Status] = 0 
	GROUP BY l.[EmployeeId]
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
	HAVING SUM(h.[WeeksUnderLimit]) <> 0

	----Allocated Tips modified to TipsDeemedWages
	
	INSERT INTO dbo.tblPaEmpHistMisc ([EntryDate], [PaYear], [PaMonth], [EmployeeId], [Amount], [MiscCodeId])
	SELECT @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, l.[EmployeeId], -SUM(h.[TipsDeemedWages] ), 15  --TipsDeemedWages
		
	FROM #VoidCheckLog l 
	INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun]  = h.[PostRun] AND l.[Id] = h.[Id]
	WHERE l.[Status] = 0 
	GROUP BY l.[EmployeeId]
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
	HAVING SUM(h.[TipsDeemedWages]) <> 0

	--Fica Tips
	INSERT INTO dbo.tblPaEmpHistMisc ([EntryDate], [PaYear], [PaMonth], [EmployeeId], [Amount], [MiscCodeId])
	SELECT @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, l.[EmployeeId], -SUM(h.[FicaTips]), 11 --Fica Tips
	FROM #VoidCheckLog l 
	INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun]  = h.[PostRun] AND l.[Id] = h.[Id]
	WHERE l.[Status] = 0 
	GROUP BY l.[EmployeeId]
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
	HAVING SUM(h.[FicaTips]) <> 0

	--Adv EIC Payment
	INSERT INTO dbo.tblPaEmpHistMisc ([EntryDate], [PaYear], [PaMonth], [EmployeeId], [Amount], [MiscCodeId])
	SELECT @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, l.[EmployeeId], -SUM(h.[WithholdingAmount]), 12 --Adv EIC Payment
	FROM #VoidCheckLog l 
	INNER JOIN dbo.tblPaCheckHistWithhold h ON l.[PostRun]  = h.[PostRun] AND l.[Id] = h.[CheckId]
	WHERE h.[TaxAuthorityType] = 0 AND h.[WithholdingCode] = 'EIC'
		AND l.[Status] = 0 
	GROUP BY l.[EmployeeId]
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
	HAVING SUM(h.[WithholdingAmount]) <> 0

	--Uncollected OASDI
	INSERT INTO dbo.tblPaEmpHistMisc ([EntryDate], [PaYear], [PaMonth], [EmployeeId], [Amount], [MiscCodeId])
	SELECT @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, l.[EmployeeId], -SUM(h.[UncollectedOasdi]), 13 --Uncollected OASDI
	FROM #VoidCheckLog l 
	INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun]  = h.[PostRun] AND l.[Id] = h.[Id]
	WHERE l.[Status] = 0 
	GROUP BY l.[EmployeeId]
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
	HAVING SUM(h.[UncollectedOasdi]) <> 0

	--Uncollected Medicare
	INSERT INTO dbo.tblPaEmpHistMisc ([EntryDate], [PaYear], [PaMonth], [EmployeeId], [Amount], [MiscCodeId])
	SELECT @VoidDate, @PayrollYear
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
		, l.[EmployeeId], -SUM(h.[UncollectedMedicare]), 14 --Uncollected Medicare
	FROM #VoidCheckLog l 
	INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun]  = h.[PostRun] AND l.[Id] = h.[Id]
	WHERE l.[Status] = 0 
	GROUP BY l.[EmployeeId]
		, CASE WHEN @VoidToPayrollMonth = 1 THEN @PayrollMonth ELSE l.[PaMonth] END
	HAVING SUM(h.[UncollectedMedicare]) <> 0


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_EmployeeHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_EmployeeHistory_proc';

