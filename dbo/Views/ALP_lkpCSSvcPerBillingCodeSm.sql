CREATE VIEW dbo.ALP_lkpCSSvcPerBillingCodeSm
-- MAH 05/21/11 - modified view to also include billed services that do not have associated central station services
AS
--SELECT     TOP 100 PERCENT dbo.tblCSsvcperbillingCode.ItemId, dbo.tblCSServices.SvcCode, dbo.tblCSServices.Descr, 
--                      dbo.tblSmItem.ItemCode + '-' + dbo.tblSmItem.[Desc] AS ItemDesc
--FROM         dbo.tblCSsvcperbillingCode INNER JOIN
--                      dbo.tblCSServices ON dbo.tblCSsvcperbillingCode.CSSvcID = dbo.tblCSServices.CSSvcID INNER JOIN
--                      dbo.tblSmItem ON dbo.tblCSsvcperbillingCode.ItemId = dbo.tblSmItem.ItemCode
--ORDER BY dbo.tblCSsvcperbillingCode.ItemId, dbo.tblCSsvcperbillingCode.CSSvcID

SELECT  BS.ItemCode as ItemId, BS.[Desc] as BillingDescr, CS.SvcCode, CS.Descr,
  dbo.tblSmItem.ItemCode + '-' + dbo.tblSmItem.[Desc] AS ItemDesc -- added by NSK on 18 Jul 2014
FROM (dbo.ALP_tblCSsvcperbillingCode CSpBS
	INNER JOIN dbo.ALP_tblCSServices CS
	ON CSpBS.CSSvcID = CS.CSSvcID )
INNER JOIN  -- added by NSK on 18 Jul 2014
                      dbo.tblSmItem ON CSpBS.ItemId = dbo.tblSmItem.ItemCode  -- added by NSK on 18 Jul 2014
RIGHT OUTER JOIN dbo.ALP_lkpSmAlpItem_MonitoredSvc  BS
ON BS.ItemCode = CSpBS.ItemID