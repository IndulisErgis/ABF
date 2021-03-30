
CREATE PROCEDURE dbo.trav_PaVoidCheck_BuildGlLog_proc
AS
--PET:http://webfront:801/view.php?id=227706

BEGIN TRY

	DECLARE @PostRun pPostRun
	DECLARE @CurrBase pCurrency
	DECLARE @CompId sysname
	DECLARE @AdvPmtAcct pGlAcct
	DECLARE @FiscalYear smallint
	DECLARE @FiscalPeriod smallint
	DECLARE @VoidDate datetime
       
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @CompId = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @AdvPmtAcct = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'AdvPmtAcct'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'
	SELECT @VoidDate = Cast([Value] AS DateTime) FROM #GlobalValues WHERE [Key] = 'VoidDate'
       
	IF @PostRun IS NULL OR @CurrBase IS NULL OR @CompId IS NULL
		OR @AdvPmtAcct IS NULL OR @VoidDate IS NULL
		OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END

	--use a temp table to accumulate the log values	
	CREATE TABLE #GLDetail (
		[GlAccount] [pGlAcct], 
		[Reference] [nvarchar](15), 
		[Description] [nvarchar](30),
		[Amount] [pDecimal],
		[Grouping] [smallint],
		[GroupId1] [nvarchar](10),
		[GroupId2] [nvarchar](10)
	)

	--reverse the earnings
	INSERT #GLDetail([GlAccount], [Reference], [Description], [Amount], [Grouping], [GroupId1])
	SELECT d.[GLAcct], h.[DepartmentId], SUBSTRING(d.[Description], 1, 30)
		, -h.[EarningsAmount], 10, h.[EarningCode]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistEarn h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaDeptDtl d ON h.[DepartmentId] = d.[DepartmentId] AND h.[EarningCode] = d.[Code]
	INNER JOIN dbo.tblPaEarnCode e ON h.[EarningCode] = e.[Id]
	WHERE d.[Type] = 3 AND d.[TaxAuthorityId] IS NULL AND e.[IncludeInNet] <> 0
		AND l.[Status] = 0 


	--Deductions Debit to liability
	INSERT #GLDetail([GlAccount], [Reference], [Description], [Amount], [Grouping], [GroupId1])
	SELECT c.[GLLiabilityAccount], 'PA', SUBSTRING(c.[Description], 1, 30)
		, h.[Amount], 20, h.[DeductionCode]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistDeduct h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaDeductCode c ON h.[DeductionCode] = c.[DeductionCode]
	WHERE c.[EmployerPaid] = 0
		AND l.[Status] = 0 


	--Withholdings Debit to liability
	--Federal (non-EIC)
	INSERT #GLDetail([GlAccount], [Reference], [Description], [Amount], [Grouping], [GroupId1], [GroupId2])
	SELECT td.[GlLiabilityAccount], 'PA', SUBSTRING(td.[Description], 1, 30)
		, h.[WithholdingAmount], 30, th.[TaxAuthority], td.[Code]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHist c ON l.[PostRun] = c.[PostRun] AND l.[Id] = c.[Id]
	INNER JOIN dbo.tblPaCheckHistWithhold h ON c.[PostRun] = h.[PostRun] AND c.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaTaxAuthorityHeader th ON h.[TaxAuthorityType] = th.[Type]
	INNER JOIN dbo.tblPaTaxAuthorityDetail td ON th.[Id] = td.[TaxAuthorityId] AND c.[PaYear] = td.[PaYear] AND h.[WithholdingCode] = td.[Code]
	WHERE h.[TaxAuthorityType] = 0 --Federal
		AND td.[EmployerPaid] = 0 AND td.[Code] <> 'EIC'
		AND l.[Status] = 0 

	--Federal (EIC)
	INSERT #GLDetail([GlAccount], [Reference], [Description], [Amount], [Grouping], [GroupId1], [GroupId2])
	SELECT @AdvPmtAcct, 'PA', SUBSTRING(td.[Description], 1, 30)
		, h.[WithholdingAmount], 30, th.[TaxAuthority], td.[Code]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHist c ON l.[PostRun] = c.[PostRun] AND l.[Id] = c.[Id]
	INNER JOIN dbo.tblPaCheckHistWithhold h ON c.[PostRun] = h.[PostRun] AND c.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaTaxAuthorityHeader th ON h.[TaxAuthorityType] = th.[Type]
	INNER JOIN dbo.tblPaTaxAuthorityDetail td ON th.[Id] = td.[TaxAuthorityId] AND c.[PaYear] = td.[PaYear] AND h.[WithholdingCode] = td.[Code]
	WHERE h.[TaxAuthorityType] = 0 --Federal
		AND td.[EmployerPaid] = 0 AND td.[Code] = 'EIC'
		AND l.[Status] = 0 

	--State
	INSERT #GLDetail([GlAccount], [Reference], [Description], [Amount], [Grouping], [GroupId1], [GroupId2])
	SELECT td.[GlLiabilityAccount], 'PA', SUBSTRING(td.[Description], 1, 30)
		, h.[WithholdingAmount], 33, th.[TaxAuthority], td.[Code]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHist c ON l.[PostRun] = c.[PostRun] AND l.[Id] = c.[Id]
	INNER JOIN dbo.tblPaCheckHistWithhold h ON c.[PostRun] = h.[PostRun] AND c.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaTaxAuthorityHeader th ON h.[TaxAuthorityType] = th.[Type] AND h.[State] = th.[State]
	INNER JOIN dbo.tblPaTaxAuthorityDetail td ON th.[Id] = td.[TaxAuthorityId] AND c.[PaYear] = td.[PaYear] AND h.[WithholdingCode] = td.[Code]
	WHERE h.[TaxAuthorityType] = 1 --State
		AND td.[EmployerPaid] = 0
		AND l.[Status] = 0 

	--Local
	INSERT #GLDetail([GlAccount], [Reference], [Description], [Amount], [Grouping], [GroupId1], [GroupId2])
	SELECT td.[GlLiabilityAccount], 'PA', SUBSTRING(td.[Description], 1, 30)
		, h.[WithholdingAmount], 36, th.[TaxAuthority], td.[Code]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHist c ON l.[PostRun] = c.[PostRun] AND l.[Id] = c.[Id]
	INNER JOIN dbo.tblPaCheckHistWithhold h ON c.[PostRun] = h.[PostRun] AND c.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaTaxAuthorityHeader th ON h.[TaxAuthorityType] = th.[Type] AND h.[State] = th.[State] AND h.[Local] = th.[Local]
	INNER JOIN dbo.tblPaTaxAuthorityDetail td ON th.[Id] = td.[TaxAuthorityId] AND c.[PaYear] = td.[PaYear] AND h.[WithholdingCode] = td.[Code]
	WHERE h.[TaxAuthorityType] = 2 --Local
		AND td.[EmployerPaid] = 0
		AND l.[Status] = 0 


	--Employer Cost debit to liability
	INSERT #GLDetail([GlAccount], [Reference], [Description], [Amount], [Grouping], [GroupId1])
	SELECT d.[GlLiabilityAccount], 'PA', SUBSTRING(d.[Description], 1, 30)
		, h.[Amount], 40, d.[DeductionCode]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistEmplrCost h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaDeductCode d ON h.[DeductionCode] = d.[DeductionCode]
	WHERE d.[EmployerPaid] = 1
		AND l.[Status] = 0 


	--Employer Cost credit to department
	INSERT #GLDetail([GlAccount], [Reference], [Description], [Amount], [Grouping], [GroupId1])
	SELECT d.[GLAcct], d.[DepartmentId], SUBSTRING(d.[Description], 1, 30)
		, -h.[Amount], 50, d.[DepartmentId]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistEmplrCost h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaDeptDtl d ON h.[DepartmentId] = d.[DepartmentId] AND h.[DeductionCode] = d.[Code]
	WHERE d.[Type] = 4 AND d.TaxAuthorityId IS NULL --deductions
		AND l.[Status] = 0 


	--Employer Taxes debit liability
	--Federal
	INSERT #GLDetail([GlAccount], [Reference], [Description], [Amount], [Grouping], [GroupId1], [GroupId2])
	SELECT td.[GlLiabilityAccount], 'PA', SUBSTRING(td.[Description], 1, 30)
		, h.[WithholdingAmount], 60, th.[TaxAuthority], td.[Code]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHist c ON l.[PostRun] = c.[PostRun] AND l.[Id] = c.[Id]
	INNER JOIN dbo.tblPaCheckHistEmplrTax h ON c.[PostRun] = h.[PostRun] AND c.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaTaxAuthorityHeader th ON h.[TaxAuthorityType] = th.[Type]
	INNER JOIN dbo.tblPaTaxAuthorityDetail td ON th.[Id] = td.[TaxAuthorityId] AND c.[PaYear] = td.[PaYear] AND h.[WithholdingCode] = td.[Code]
	WHERE h.[TaxAuthorityType] = 0 --Federal
		AND td.[EmployerPaid] = 1
		AND l.[Status] = 0 
		
	--State
	INSERT #GLDetail([GlAccount], [Reference], [Description], [Amount], [Grouping], [GroupId1], [GroupId2])
	SELECT td.[GlLiabilityAccount], 'PA', SUBSTRING(td.[Description], 1, 30)
		, h.[WithholdingAmount], 63, th.[TaxAuthority], td.[Code]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHist c ON l.[PostRun] = c.[PostRun] AND l.[Id] = c.[Id]
	INNER JOIN dbo.tblPaCheckHistEmplrTax h ON c.[PostRun] = h.[PostRun] AND c.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaTaxAuthorityHeader th ON h.[TaxAuthorityType] = th.[Type] AND h.[State] = th.[State]
	INNER JOIN dbo.tblPaTaxAuthorityDetail td ON th.[Id] = td.[TaxAuthorityId] AND c.[PaYear] = td.[PaYear] AND h.[WithholdingCode] = td.[Code]
	WHERE h.[TaxAuthorityType] = 1 --State
		AND td.[EmployerPaid] = 1
		AND l.[Status] = 0 

	--Local
	INSERT #GLDetail([GlAccount], [Reference], [Description], [Amount], [Grouping], [GroupId1], [GroupId2])
	SELECT td.[GlLiabilityAccount], 'PA', SUBSTRING(td.[Description], 1, 30)
		, h.[WithholdingAmount], 66, th.[TaxAuthority], td.[Code]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHist c ON l.[PostRun] = c.[PostRun] AND l.[Id] = c.[Id]
	INNER JOIN dbo.tblPaCheckHistEmplrTax h ON c.[PostRun] = h.[PostRun] AND c.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaTaxAuthorityHeader th ON h.[TaxAuthorityType] = th.[Type] AND h.[State] = th.[State] AND h.[Local] = th.[Local]
	INNER JOIN dbo.tblPaTaxAuthorityDetail td ON th.[Id] = td.[TaxAuthorityId] AND c.[PaYear] = td.[PaYear] AND h.[WithholdingCode] = td.[Code]
	WHERE h.[TaxAuthorityType] = 2 --Local
		AND td.[EmployerPaid] = 1
		AND l.[Status] = 0 


	--Employer Taxes credit department
	INSERT #GLDetail([GlAccount], [Reference], [Description], [Amount], [Grouping], [GroupId1])
	SELECT d.[GLAcct], d.[DepartmentId], SUBSTRING(d.[Description], 1, 30)
		, -h.[WithholdingAmount], 70, d.[DepartmentId]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHistEmplrTax h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[CheckId]
	INNER JOIN dbo.tblPaDeptDtl d ON h.[DepartmentId] = d.[DepartmentId] AND h.[TaxAuthorityType] = d.[Type] AND h.[WithholdingCode] = d.[Code]
	INNER JOIN dbo.tblPaTaxAuthorityHeader th ON d.[TaxAuthorityId] = th.[Id] 
		AND h.[TaxAuthorityType] = th.[Type] AND ISNULL(h.[State], '') = ISNULL(th.[State], '') AND ISNULL(h.[Local], '') = ISNULL(th.[Local], '')
	WHERE d.[Type] IN (0, 1, 2) 
		AND l.[Status] = 0 


	--NetPay Debit (Cash GL Account comes from the BankID)
	INSERT #GLDetail([GlAccount], [Reference], [Description], [Amount], [Grouping], [GroupId1])
	SELECT i.[BankGlAcct], 'PA', 'Net Cash Entry'
		, SUM(l.[NetPay]), 80, i.[BankId]
	FROM #VoidCheckList i
	INNER JOIN #VoidCheckLog l ON i.[PostRun] = l.[PostRun] AND i.[Id] = l.[Id]
	WHERE l.[Status] = 0 
	GROUP BY i.[BankId], i.[BankGlAcct]
	


	--populate the GL log table
	INSERT #GlPostLogs (PostRun, FiscalYear, FiscalPeriod, [Grouping]
		, GlAccount, Reference, [Description], SourceCode
		, PostDate, TransDate, CurrencyId, ExchRate, CompId
		, AmountFgn, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn)
	SELECT @PostRun, @FiscalYear, @FiscalPeriod, [Grouping]
		, l.[GlAccount], l.[Reference], l.[Description], 'PA'
		, @VoidDate, @VoidDate, @CurrBase, 1, @CompId
		, SUM(l.[Amount])
		, CASE WHEN SUM(l.[Amount]) > 0 THEN SUM(l.[Amount]) ELSE 0 END
		, CASE WHEN SUM(l.[Amount]) < 0 then -SUM(l.[Amount]) ELSE 0 END
		, CASE WHEN SUM(l.[Amount]) > 0 THEN SUM(l.[Amount]) ELSE 0 END
		, CASE WHEN SUM(l.[Amount]) < 0 then -SUM(l.[Amount]) ELSE 0 END
	FROM #GLDetail l
	GROUP BY l.[GLAccount], l.[Reference], l.[Description], l.[Grouping], l.[GroupId1], l.[GroupId2]
	HAVING SUM(l.[Amount]) <> 0


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_BuildGlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_BuildGlLog_proc';

