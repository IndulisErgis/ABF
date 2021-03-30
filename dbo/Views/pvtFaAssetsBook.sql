
CREATE  VIEW dbo.pvtFaAssetsBook
AS

SELECT a.AssetId AS 'Asset ID', a.SerialNo AS 'Serial No', a.TagNo AS 'Tag No'
	, d.DeprcType AS 'Depreciation Type', d.Method, d.BeginYr AS 'Begin Year', d.BeginPd AS 'Begin Period'
	, d.EndYr AS 'End Year', d.EndPd AS 'End Period', d.BaseCost, d.CurrDepr, d.AnnualDepr
	, act.TotDeprTaken, act.YTDDepr, a.BonusDeprPct AS 'Special Allowance Percent' 
FROM dbo.tblFaAsset a 
	INNER JOIN dbo.tblFaAssetDepr d ON a.AssetId = d.AssetID 
	LEFT JOIN 
		(
			SELECT act.DeprID
			, SUM(act.Amount) AS TotDeprTaken
			, SUM(CASE WHEN act.FiscalYear = o.FiscalYear THEN act.Amount ELSE 0 END) AS YTDDepr 
			FROM dbo.tblFaAssetDepr d 
				INNER JOIN dbo.tblFaOptionDepr o ON d.DeprcType = o.DeprType 
				INNER JOIN dbo.tblFaAssetDeprActivity act on d.ID = act.DeprID 
			GROUP BY DeprID
		) act ON d.ID = act.DeprID 
WHERE a.AssetStatus <> 2
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtFaAssetsBook';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtFaAssetsBook';

