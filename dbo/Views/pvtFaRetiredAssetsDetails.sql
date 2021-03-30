
CREATE  VIEW dbo.pvtFaRetiredAssetsDetails
AS

SELECT r.RetirementID AS 'Retirement ID', r.AssetID AS 'Asset ID', r.SerialNo AS 'Serial No'
	, r.TagNo AS 'Tag No', d.DeprcType AS 'Depreciation Type', d.Method
	, d.BeginYr AS 'Begin Year', d.BeginPd AS 'Begin Period', d.EndYr AS 'End Year', d.EndPd AS 'End Period'
	, d.BaseCost, d.AnnualDepr, d.TotDeprTaken, d.YTDDepr, r.BonusDeprPct AS 'Special Allowance Percent' 
FROM dbo.tblFaRetire r INNER JOIN dbo.tblFaretireDepr d ON r.RetirementID = d.RetirementID
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtFaRetiredAssetsDetails';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtFaRetiredAssetsDetails';

