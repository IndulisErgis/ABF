
CREATE PROCEDURE dbo.trav_PaVoidCheck_GenerateCheck_proc
AS
--PET:http://webfront:801/view.php?id=227706
--PET:http://webfront:801/view.php?id=244561
--PET:http://webfront:801/view.php?id=251650

BEGIN TRY
	DECLARE @PaYear smallint
	DECLARE @DDYn bit
	DECLARE @FiscalYear smallint
	DECLARE @FiscalPeriod smallint
	DECLARE @VoidDate datetime
	DECLARE @MaxId int
       
	SELECT @PaYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PayrollYear'
	SELECT @DDYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'DDYn'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'
	SELECT @VoidDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'VoidDate'
       
	IF @PaYear IS NULL OR @DDYn IS NULL
		OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL
		OR @VoidDate IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--conditionally create default check group information
	--	when it doesn't exist and there is a manual check to recreate
	DECLARE @InfoId int
	SELECT @InfoId = [Id] FROM dbo.tblPaCheckInfo WHERE [PaYear] = @PaYear
	IF @InfoId IS NULL AND EXISTS (SELECT 1 FROM #VoidCheckLog l WHERE l.[Type] = 1 AND l.[Status] = 0 )
	BEGIN
		DECLARE @BankId pBankId
		SELECT @BankId = MIN([VoidBankId]) FROM #VoidCheckLog l WHERE l.[Status] = 0 
		
		INSERT INTO dbo.tblPaCheckInfo ([PaYear], [GlPeriod], [GlYear], [PeriodEndDate], [DateOnCheck], [PrintedYn], [BankId])
		VALUES (@PaYear, @FiscalPeriod, @FiscalYear, @VoidDate, @VoidDate, 0, @BankId)

		SET @InfoId = @@IDENTITY
		
		INSERT INTO dbo.tblPaCheckInfoGroup ([InfoId], [Id], [Selected], [PeriodStartDate], [PdCode])
		SELECT @InfoId, 0, 0, NULL, 1
		UNION ALL
		SELECT @InfoId, 1, 0, NULL, 1
		UNION ALL
		SELECT @InfoId, 2, 0, NULL, 1
		UNION ALL
		SELECT @InfoId, 3, 0, NULL, 1
		UNION ALL
		SELECT @InfoId, 4, 0, NULL, 1
		UNION ALL
		SELECT @InfoId, 5, 0, NULL, 1
		UNION ALL
		SELECT @InfoId, 6, 0, NULL, 1
		UNION ALL
		SELECT @InfoId, 7, 0, NULL, 1
		UNION ALL
		SELECT @InfoId, 8, 0, NULL, 1
		UNION ALL
		SELECT @InfoId, 9, 0, NULL, 1
	END

   --Get max id from tblPaCheck
	SELECT @MaxId = MAX(Id) FROM dbo.tblPaCheckHist

	--Check entry
	INSERT INTO dbo.tblPaCheck ([Id],[PaYear], [EmployeeId], [CheckNumber], [VoucherNumber], [CheckDate]
		, [GrossPay], [NetPay], [WeeksWorked], [TotalHoursWorked], [WeeksUnderLimit]
		, [Type], [FicaTips], [TipsDeemedWages], [UncollectedOasdi], [UncollectedMedicare]
		, [CollOnUncolOasdi], [CollOnUncolMed], [VoidHistCheckId], [CF])
	SELECT ROW_NUMBER() OVER (ORDER BY h.[Id]) + @MaxId,  @PaYear, h.[EmployeeId], NULL, NULL, @VoidDate
		, h.[GrossPay], h.[NetPay], h.[WeeksWorked], h.[HoursWorked], h.[WeeksUnderLimit]
		, h.[Type], h.[FicaTips], h.[TipsDeemedWages], h.[UncollectedOasdi], h.[UncollectedMedicare]
		, h.[CollOnUncollOasdi], h.[CollOnUncollMed], h.[Id], h.[CF]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[Id]
	WHERE l.[Type] = 1 --Manual check
		AND l.[Status] = 0 
	
	
	--Check Leave
	INSERT INTO dbo.tblPaCheckLeave ([CheckId], [LeaveCodeId], [HoursAccrued])	
	SELECT c.[Id], hl.[LeaveCodeId], hl.[HoursAccrued]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[Id]
	INNER JOIN dbo.tblPaCheckHistLeave hl ON h.[PostRun] = hl.[PostRun] AND h.[Id] = hl.[CheckId]
	INNER JOIN dbo.tblPaCheck c ON h.[Id] = c.[VoidHistCheckId]
	WHERE l.[Type] = 1 --Manual check
		AND l.[Status] = 0 
	

	--Check Earn
	INSERT INTO dbo.tblPaCheckEarn ([CheckId], [EarningCode], [LeaveCodeId]
		, [StateTaxAuthorityId], [SUIState], [LocalTaxAuthorityId], [DepartmentId], [LaborClass]
		, [HoursWorked], [Pieces], [EarningCodeRate], [EarningAmount], [DeptAllocId]
		, [CustId], [ProjId], [PhaseId], [TaskId], [CF],TaxGroupId)
	SELECT c.[Id], he.[EarningCode], he.[LeaveCodeId]
		, sta.[Id], he.[SUIState], lta.[Id], he.[DepartmentId], he.[LaborClass]
		, he.[HoursWorked], he.[Pieces], he.[HourlyRate], he.[EarningsAmount], he.[DeptAllocId]
		, he.[CustId], he.[ProjId], he.[PhaseId], he.[TaskId], he.[CF],gh.ID
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[Id]
	INNER JOIN dbo.tblPaCheckHistEarn he ON h.[PostRun] = he.[PostRun] AND h.[Id] = he.[CheckId]
	INNER JOIN dbo.tblPaCheck c ON h.[Id] = c.[VoidHistCheckId]
	LEFT JOIN dbo.tblPaTaxAuthorityHeader sta ON he.[StateCode] = sta.[TaxAuthority] AND sta.[Type] = 1 --state
	LEFT JOIN dbo.tblPaTaxAuthorityHeader lta ON he.[LocalCode] = lta.[TaxAuthority] AND lta.[Type] = 2 --local
	LEFT JOIN dbo.tblPaTaxGroupHeader gh ON he.TaxGroup = gh.TaxGroup
	WHERE l.[Type] = 1 --Manual check
		AND l.[Status] = 0 

	--Check Deduct
	INSERT INTO dbo.tblPaCheckDeduct ([CheckId], [DeductionCode]
		, [DeductionHours], [DeductionAmount], [CF])
	SELECT c.[Id], hd.[DeductionCode]
		, hd.[Hours], hd.[Amount], hd.[CF]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[Id]
	INNER JOIN dbo.tblPaCheckHistDeduct hd ON h.[PostRun] = hd.[PostRun] AND h.[Id] = hd.[CheckId]
	INNER JOIN dbo.tblPaCheck c ON h.[Id] = c.[VoidHistCheckId]
	WHERE l.[Type] = 1 --Manual check
		AND l.[Status] = 0 
		
	
	--Check Withholdings
	INSERT INTO dbo.tblPaCheckWithhold ([CheckId], [TaxAuthorityId], [TaxAuthorityDtlId], [WithholdingCode]
		, [Description], [WithholdingPayments], [WithholdingEarnings], [GrossEarnings], [CF])
	SELECT c.[Id], tah.[Id], tad.[Id], hw.[WithholdingCode]
		, hw.[Description], hw.[WithholdingAmount], hw.[WithholdingEarnings], hw.[GrossEarnings], hw.[CF]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[Id]
	INNER JOIN dbo.tblPaCheckHistWithhold hw ON h.[PostRun] = hw.[PostRun] AND h.[Id] = hw.[CheckId]
	INNER JOIN dbo.tblPaCheck c ON h.[Id] = c.[VoidHistCheckId]
	INNER JOIN dbo.tblPaTaxAuthorityHeader tah ON hw.[TaxAuthorityType] = tah.[Type] 
		AND ISNULL(hw.[State], '') = ISNULL(tah.[State], '') AND ISNULL(hw.[Local], '') = ISNULL(tah.[Local], '')
	INNER JOIN dbo.tblPaTaxAuthorityDetail tad ON tah.[Id] = tad.[TaxAuthorityId] AND hw.[WithholdingCode] = tad.[Code]
	WHERE l.[Type] = 1 --Manual check
		AND l.[Status] = 0 
		AND tad.[PaYear] = @PaYear


	--Check Employer Cost
	INSERT INTO dbo.tblPaCheckEmplrCost ([CheckId], [DeductionCode], [DepartmentId]
		, [DeductionHours], [DeductionAmount], [CF])
	SELECT c.[Id], hd.[DeductionCode], hd.[DepartmentId]
		, hd.[Hours], hd.[Amount], hd.[CF]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[Id]
	INNER JOIN dbo.tblPaCheckHistEmplrCost hd ON h.[PostRun] = hd.[PostRun] AND h.[Id] = hd.[CheckId]
	INNER JOIN dbo.tblPaCheck c ON h.[Id] = c.[VoidHistCheckId]
	WHERE l.[Type] = 1 --Manual check
		AND l.[Status] = 0 


	--Check Employer Tax
	INSERT INTO dbo.tblPaCheckEmplrTax ([CheckId], [DepartmentId], [TaxAuthorityId], [TaxAuthorityDtlId], [WithholdingCode]
		, [Description], [WithholdingPayments], [WithholdingEarnings], [GrossEarnings], [CF])
	SELECT c.[Id], ht.[DepartmentId], tah.[Id], tad.[Id], ht.[WithholdingCode]
		, ht.[Description], ht.[WithholdingAmount], ht.[WithholdingEarnings], ht.[GrossEarnings], ht.[CF]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[Id]
	INNER JOIN dbo.tblPaCheckHistEmplrTax ht ON h.[PostRun] = ht.[PostRun] AND h.[Id] = ht.[CheckId]
	INNER JOIN dbo.tblPaCheck c ON h.[Id] = c.[VoidHistCheckId]
	INNER JOIN dbo.tblPaTaxAuthorityHeader tah ON ht.[TaxAuthorityType] = tah.[Type] 
		AND ISNULL(ht.[State], '') = ISNULL(tah.[State], '') AND ISNULL(ht.[Local], '') = ISNULL(tah.[Local], '')
	INNER JOIN dbo.tblPaTaxAuthorityDetail tad ON tah.[Id] = tad.[TaxAuthorityId] AND ht.[WithholdingCode] = tad.[Code]
	WHERE l.[Type] = 1 --Manual check
		AND l.[Status] = 0 
		AND tad.[PaYear] = @PaYear


	--Payment distribution
	IF @DDYn = 1
	BEGIN
		INSERT INTO dbo.tblPaCheckDistribution ([CheckId], [DistributionId]
			, [CurrentAmount], [DirectDepositYN], [TraceNumber], [CF])
		SELECT c.[Id], hd.[DistributionId]
			, hd.[CurrentAmount], hd.[DirectDepositYN], hd.[TraceNumber], hd.[CF]
		FROM #VoidCheckLog l
		INNER JOIN dbo.tblPaCheckHist h ON l.[PostRun] = h.[PostRun] AND l.[Id] = h.[Id]
		INNER JOIN dbo.tblPaCheckHistDistribution hd ON h.[PostRun] = hd.[PostRun] AND h.[Id] = hd.[CheckId]
		INNER JOIN dbo.tblPaCheck c ON h.[Id] = c.[VoidHistCheckId]
		WHERE l.[Type] = 1 --Manual check
			AND l.[Status] = 0 
	END


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_GenerateCheck_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_GenerateCheck_proc';

