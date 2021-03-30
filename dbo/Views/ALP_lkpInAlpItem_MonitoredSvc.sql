CREATE VIEW dbo.ALP_lkpInAlpItem_MonitoredSvc  
AS  
SELECT     TOP 100 PERCENT ItemId, Descr  
FROM         dbo.ALP_tblInItem_view  
WHERE     (AlpServiceType = 4)  
ORDER BY ItemId