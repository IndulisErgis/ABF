
CREATE PROCEDURE dbo.trav_PaWithholdings_proc
@PayrollYear int, 
@SortBy tinyint, -- 0 = Withholding Code, 1 = GL Account
@IncludeExclusions bit

AS
BEGIN TRY
	SET NOCOUNT ON

	-- main report results
	SELECT CASE @SortBy WHEN 0 THEN CAST(h.[Type] as nvarchar) ELSE d.GlLiabilityAccount END AS GrpId1
		, CASE @SortBy 
			WHEN 0 THEN 
				CASE h.[Type] WHEN 0 THEN h.TaxAuthority WHEN 1 THEN h.[State] ELSE h.[Local] END 
			ELSE CAST(h.[Type] AS nvarchar) 
			END AS GrpId2
		, CASE @SortBy 
			WHEN 0 THEN d.Code 
			ELSE CASE h.[Type] WHEN 0 THEN h.TaxAuthority WHEN 1 THEN h.[State] ELSE h.[Local] END 
			END AS GrpId3
		, CASE @SortBy WHEN 0 THEN '' ELSE d.Code END AS GrpId4
		, h.[Type], h.TaxAuthority, d.Code, h.[State], h.[Local], d.[Description]
		, d.GlLiabilityAccount, d.EmplrExpenseAcct, d.FixedPercent, d.TaxId
		, d.EmployerPaid, d.WeeksWorkedLimit, d.Id AS TaxAuthDtlId 
	FROM #AuthorityList a 
		INNER JOIN dbo.tblPaTaxAuthorityDetail d ON a.Id = d.TaxAuthorityId 
		INNER JOIN dbo.tblPaTaxAuthorityHeader h ON h.Id = d.TaxAuthorityId 
	WHERE h.[Type] IN (0, 1, 2) AND d.PaYear = @PayrollYear

	-- exclusions subreport results
	SELECT d.Id AS TaxAuthDtlId, 0 AS ExclusionType, ec.Id AS CodeDescr, ec.[Description] 
	FROM dbo.tblPaTaxAuthorityExclusionEarning ee 
		INNER JOIN dbo.tblPaTaxAuthorityDetail d ON ee.TaxAuthorityDtlId = d.Id 
		INNER JOIN dbo.tblPaTaxAuthorityHeader h ON h.Id = d.TaxAuthorityId 
		INNER JOIN #AuthorityList a ON d.TaxAuthorityId = a.Id 
		INNER JOIN dbo.tblPaEarnCode ec ON ee.EarningCodeId = ec.Id 
	UNION ALL
	SELECT d.Id AS TaxAuthDtlId, 1 AS ExclusionType, dc.DeductionCode AS CodeDescr, dc.[Description] 
	FROM dbo.tblPaTaxAuthorityExclusionDeduction ed 
		INNER JOIN dbo.tblPaTaxAuthorityDetail d ON ed.TaxAuthorityDtlId = d.Id 
		INNER JOIN dbo.tblPaTaxAuthorityHeader h ON h.Id = d.TaxAuthorityId 
		INNER JOIN #AuthorityList a ON d.TaxAuthorityId = a.Id 
		INNER JOIN dbo.tblPaDeductCode dc ON ed.DeductionCodeId = dc.Id

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaWithholdings_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaWithholdings_proc';

