 CREATE VIEW dbo.ALP_lkpSmAlpItem_MonitoredSvc  
AS  
SELECT     TOP 100 PERCENT ItemCode, [Desc]  
FROM         dbo.ALP_tblSmItem_view  
WHERE     (AlpServiceType = 4)  
ORDER BY ItemCode