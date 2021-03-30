
CREATE VIEW dbo.pvtFaAssetsList
AS

SELECT AssetId AS 'Asset ID', AssetDescr AS 'Description', SerialNo AS 'Serial No', TagNo AS 'Tag No'
	, AcquisitionCost, AcquisitionDate AS 'Acquisition Date', RetirementDate AS 'Retirement Date'
	, Qty, InsuredValue, InsuredValueDate AS 'Insured Effective Date'
	, AssessedValue, AssessedValueDate AS 'Assessment Date'
	, ReplaceCost, PlacedInServDate AS 'Date Placed In Service', AdjustedCost
	, AccumNonDeprcCost, TotalCredits, BonusDeprPct AS 'Special Allowance Percent' 
FROM dbo.tblFaAsset
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtFaAssetsList';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtFaAssetsList';

