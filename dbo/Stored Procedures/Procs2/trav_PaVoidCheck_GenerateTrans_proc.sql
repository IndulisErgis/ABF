
CREATE PROCEDURE dbo.trav_PaVoidCheck_GenerateTrans_proc
AS
--PET:http://webfront:801/view.php?id=227706
--PET:http://webfront:801/view.php?id=251453

BEGIN TRY
	DECLARE @PaYear smallint
       
	SELECT @PaYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PayrollYear'
       
	IF @PaYear IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	
	--Deductions
	INSERT INTO dbo.tblPaTransDeduct ([PaYear], [EmployeeId], [DeductCode]
		, [LaborClass], [Hours], [Amount], [TransDate], [SeqNo], [Note], [CF])
	SELECT @PaYear, h.[EmployeeId], h.[DeductCode]
		, h.[LaborClass], h.[Hours], h.[Amount], h.[TransDate], h.[SeqNo], h.[Note], h.[CF]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaTransDeductHist h ON l.[EmployeeId] = h.[EmployeeId] AND l.[Id] = h.[CheckId]
	WHERE l.[Type] = 0 --calculated check
		AND l.[Status] = 0 


	--Earnings
	INSERT INTO dbo.tblPaTransEarn ([PaYear], [EmployeeId], [EarningCode], [LeaveCodeId]
		, [DepartmentId], [StateTaxAuthorityId], [LocalTaxAuthorityId], [LaborClass]
		, [Rate], [Pieces], [Hours], [Amount], [TransDate], [SUIState], [SeqNo]
		, [DeptAllocId], [ProjectDetailId], [CustId], [ProjId], [PhaseId], [TaskId], [CF],TaxGroupId)
	SELECT @PaYear, h.[EmployeeId], h.[EarningCode], h.[LeaveCodeId]
		, h.[DepartmentId], sta.[Id], lta.[Id], h.[LaborClass]
		, h.[Rate], h.[Pieces], h.[Hours], h.[Amount], h.[TransDate], h.[SUIState], h.[SeqNo]
		, h.[DeptAllocId], NULL, h.[CustId], h.[ProjId], h.[PhaseId], h.[TaskId], h.[CF],gh.ID
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaTransEarnHist h ON h.[CheckId] = l.[Id]
	LEFT JOIN dbo.tblPaTaxAuthorityHeader sta ON h.[StateCode] = sta.[TaxAuthority] AND sta.[Type] = 1 --state
	LEFT JOIN dbo.tblPaTaxAuthorityHeader lta ON h.[LocalCode] = lta.[TaxAuthority] AND lta.[Type] = 2 --local
	LEFT JOIN dbo.tblPaTaxGroupHeader gh ON h.TaxGroup = gh.TaxGroup
	WHERE l.[Type] = 0 --calculated check
		AND l.[Status] = 0 


	--Employer Costs
	INSERT INTO dbo.tblPaTransEmplrCost ([PaYear], [EmployeeId], [DeductCode], [DepartmentId]
		, [LaborClass], [Hours], [Amount], [TransDate], [SeqNo], [Note], [CF])
	SELECT @PaYear, h.[EmployeeId], h.[DeductCode], h.[DepartmentId]
		, h.[LaborClass], h.[Hours], h.[Amount], h.[TransDate], h.[SeqNo], h.[Note], h.[CF]
	FROM #VoidCheckLog l
	INNER JOIN dbo.tblPaTransEmplrCostHist h ON l.[EmployeeId] = h.[EmployeeId] AND l.[Id] = h.[CheckId]
	WHERE l.[Type] = 0 --calculated check
		AND l.[Status] = 0


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_GenerateTrans_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaVoidCheck_GenerateTrans_proc';

