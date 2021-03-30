
CREATE VIEW [dbo].[ALP_lkpArAlpSiteContact] AS 
SELECT *,
--Contact added by NSK on 29 Feb 2016
--start
[ALP_tblArAlpSiteContact].FirstName + ' ' +   [ALP_tblArAlpSiteContact].[Name] +  
-- Case added to check null title values  
CASE WHEN Title is NULL THEN '' ELSE ' (' +  [ALP_tblArAlpSiteContact].Title  + ')' END as Contact 
--end
 FROM dbo.ALP_tblArAlpSiteContact