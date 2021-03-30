
CREATE VIEW dbo.pvtApPaymentHist
AS

SELECT VendorID, InvoiceNum, PmtType, CheckDate, CheckNum, DiscTaken, GrossAmtDue, InvoiceDate, case when dbo.tblApCheckHist.PmtType = 0 then 'Check' when dbo.tblApCheckHist.PmtType = 3 then 'Prepaid' else 'Void' end as [CheckType$]
FROM dbo.tblApCheckHist
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApPaymentHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApPaymentHist';

