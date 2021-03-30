
CREATE  VIEW dbo.pvtArMethodPmt
AS
SELECT dbo.tblArPmtMethod.PmtMethodID, dbo.tblArPmtMethod.[Desc]
	, case dbo.tblArPmtMethod.PmtType
		when 1 then 'Cash'
		when 2 then 'Check'
		when 3 then 'Credit'
		when 4 then 'Write-off'
		when 5 then 'Other'
		when 7 then 'Credit'
	end as [pmttype$]
	, dbo.tblArPmtMethod.GLAcctDebit, dbo.tblArPmtMethodDetail.FiscalYear
	, dbo.tblArPmtMethodDetail.GLPeriod, dbo.tblArPmtMethodDetail.Pmt
FROM dbo.tblArPmtMethod 
INNER JOIN dbo.tblArPmtMethodDetail ON dbo.tblArPmtMethod.PmtMethodID = dbo.tblArPmtMethodDetail.PmtMethodID
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArMethodPmt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArMethodPmt';

