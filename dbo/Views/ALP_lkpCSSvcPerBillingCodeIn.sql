


CREATE VIEW [dbo].[ALP_lkpCSSvcPerBillingCodeIn]
-- MAH 05/21/11 - modified view to also include billed services that do not have associated central station services
AS
/*SELECT     TOP 100 PERCENT dbo.ALP_tblCSsvcperbillingCode.ItemId, dbo.ALP_tblCSServices.SvcCode, dbo.ALP_tblCSServices.Descr, 
                      dbo.tblInItem.ItemId + '-' + dbo.tblInItem.Descr AS ItemDesc
FROM         dbo.ALP_tblCSsvcperbillingCode INNER JOIN
                   dbo.ALP_tblCSServices ON dbo.ALP_tblCSsvcperbillingCode.CSSvcID = dbo.ALP_tblCSServices.CSSvcID INNER JOIN
                     dbo.tblInItem ON dbo.ALP_tblCSsvcperbillingCode.ItemId = dbo.tblInItem.ItemId
ORDER BY dbo.ALP_tblCSsvcperbillingCode.ItemId, dbo.ALP_tblCSsvcperbillingCode.CSSvcID */

SELECT  TOP 100 PERCENT  BS.ItemId, BS.Descr as BillingDescr, CS.SvcCode, CS.Descr,
              dbo.tblInItem.ItemId + '-' + dbo.tblInItem.Descr AS ItemDesc  -- added by NSK on 18 Jul 2014
FROM (dbo.ALP_tblCSsvcperbillingCode CSpBS
	INNER JOIN dbo.ALP_tblCSServices CS
	ON CSpBS.CSSvcID = CS.CSSvcID ) 
INNER JOIN    						           -- added by NSK on 18 Jul 2014
                dbo.tblInItem ON CSpBS.ItemId = dbo.tblInItem.ItemId   -- added by NSK on 18 Jul 2014
RIGHT OUTER JOIN dbo.ALP_lkpInAlpItem_MonitoredSvc  BS
ON BS.ItemID = CSpBS.ItemID
ORDER BY CSpBS.ItemId, CSpBS.CSSvcID