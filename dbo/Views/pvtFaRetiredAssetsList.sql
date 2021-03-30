
CREATE VIEW dbo.pvtFaRetiredAssetsList
AS

SELECT RetirementID AS 'Retirement ID', AssetId AS 'Asset ID', SerialNo AS 'Serial No', TagNo AS 'Tag No'
	, RetireCredits, RetireExpense, RetireProceeds, RetireAcqCosts, RetireQty
	, RetireDate AS 'Retire Date', RetireAmt, BonusDeprPct AS 'Special Allowance Percent' 
FROM dbo.tblFaRetire
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtFaRetiredAssetsList';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtFaRetiredAssetsList';

