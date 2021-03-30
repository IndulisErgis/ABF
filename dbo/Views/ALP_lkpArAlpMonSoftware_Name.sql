 CREATE VIEW dbo.ALP_lkpArAlpMonSoftware_Name  
AS  
SELECT     TOP 100 PERCENT MonSoftwareId, Name  
FROM         dbo.ALP_tblArAlpMonSoftware  
ORDER BY Name