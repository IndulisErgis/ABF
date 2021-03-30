
CREATE PROCEDURE dbo.ALP_qryJmCustBySysId 
@ID int
As
SET NOCOUNT ON
SELECT ALP_tblArAlpSiteSys.SysId, ALP_tblArAlpSiteSys.SiteId, ALP_tblArAlpSiteSys.CustId, ALP_tblArCust_view.AlpInactive
FROM ALP_tblArCust_view INNER JOIN ALP_tblArAlpSiteSys ON ALP_tblArCust_view.CustId = ALP_tblArAlpSiteSys.CustId
WHERE ALP_tblArAlpSiteSys.SysId = @ID