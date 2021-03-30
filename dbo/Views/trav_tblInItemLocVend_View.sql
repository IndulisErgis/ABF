CREATE VIEW [dbo].[trav_tblInItemLocVend_View]
AS
SELECT t.[BrkId]
, t.[CurrencyID]
, t.[ExchRate]
, t.[ItemId]
, t.[LandedCostID]
, t.[LastPOConvFactor]
, t.[LastPODate]
, t.[LastPOOrderNum]
, t.[LastPOQty]
, t.[LastPOUnitCost]
, t.[LastPOUom]
, t.[LeadTime]
, t.[LocId]
, t.[VendId]
, t.[VendItemId]
, t.[VendName]
, e.[cf_VendorPartNo]
 FROM dbo.[tblInItemLocVend] t
 LEFT JOIN
 ( SELECT pvt.[ItemId]
	, pvt.[LocId]
	, pvt.[VendId]
	, Cast(pvt.[VendorPartNo] As nvarchar(100)) AS [cf_VendorPartNo]
	 FROM
		 ( SELECT t.[ItemId], t.[LocId], t.[VendId], [Name], [Value]
		 FROM
			 ( SELECT t.[ItemId], t.[LocId], t.[VendId]
			 , e.props.value('./Name[1]', 'NVARCHAR(max)') as [Name]
			 , e.props.value('./Value[1]', 'NVARCHAR(max)') as [Value]
			 FROM dbo.[tblInItemLocVend] t
			 CROSS APPLY t.CF.nodes('/ArrayOfEntityPropertyOfString/EntityPropertyOfString') as e(props)
			 WHERE (e.props.exist('Name') = 1) AND (e.props.exist('Value') = 1)
		 ) t
	 ) tmp
	 PIVOT (Max([Value]) FOR [Name] IN ([VendorPartNo])) AS pvt
) e on  t.[ItemId] = e.[ItemId] AND t.[LocId] = e.[LocId] AND t.[VendId] = e.[VendId]