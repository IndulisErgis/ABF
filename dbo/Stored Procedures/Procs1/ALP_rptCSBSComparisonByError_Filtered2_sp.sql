

CREATE PROCEDURE [dbo].[ALP_rptCSBSComparisonByError_Filtered2_sp]   
/* Created: MAH 07/29/04 for EFI# 1454  
   Modified:  
*/  
(  
 @strSQLWhere varchar(1000)  
)  
AS  
set nocount on  
declare @strSQLBase varchar(1000)  
declare @strSQLEnd varchar(100)  
set @strSQLBase = 'SELECT E.ErrorCode, E.Transmitter, E.BSCustId, E.BSSiteID, '  
 + 'SiteName = CASE WHEN dbo.ALP_tblArAlpSite.AlpFirstName IS NULL THEN dbo.ALP_tblArAlpSite.SiteName '  
 + ' ELSE  dbo.ALP_tblArAlpSite.AlpFirstName + '' '' + dbo.ALP_tblArAlpSite.SiteName END ,'  
 + ' dbo.ALP_tblArAlpSite.Addr1 '
 + ' FROM dbo.ALP_tblCSBSComparisonResultsErrors E INNER JOIN dbo.ALP_tblArAlpSite'  
 + ' ON E.BSSiteID = dbo.ALP_tblArAlpSite.SiteID  '  
set @strSQLEnd = ' ORDER BY E.ErrorCode, E.Transmitter  '  
execute (@strSQLBase + @strSQLWhere + @strSQLEnd)