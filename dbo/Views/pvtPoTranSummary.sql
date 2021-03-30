
CREATE VIEW dbo.pvtPoTranSummary
AS

SELECT TransId, CASE TransType WHEN 1 THEN 'Goods Received' WHEN -1 THEN 'New Return'
	WHEN 2 THEN 'Invoice Received' WHEN -2 THEN 'Debit Memo' WHEN 9 THEN 'New Order' END AS TransType,
	TransDate, MemoNonTaxable, MemoTaxable, MemoSalesTax, MemoFreight, MemoMisc, MemoDisc, MemoPrepaid
FROM dbo.tblPoTransHeader 
WHERE TransType <> 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPoTranSummary';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtPoTranSummary';

