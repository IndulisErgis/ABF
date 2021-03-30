CREATE PROCEDURE [dbo].[ALP_stpSISiteDelete]  
-- Below coded adde by ravi on 03.11.2015, Reason:- To Delete the Sites children date before delete the Site data
-- Updated for TRAV11 by Josh Gillespie on 04/26/2013  
 @SiteId int  
AS  
BEGIN  
--Below coded adde by ravi on 03.11.2015
DELETE FROM ALP_tblArAlpSiteContact  WHERE SiteId =@SiteId

DELETE FROM ALP_tblArAlpSiteSysItem    WHERE SysId IN (SELECT  SysId  from ALP_tblArAlpSiteSys  WHERE SiteId =@SiteId)
DELETE FROM ALP_tblArAlpSiteSys   WHERE SiteId =@SiteId

DELETE FROM ALP_tblArAlpSiteRecBillServPrice  WHERE RecBillServId  
		IN(SELECT  RecBillServId    from ALP_tblArAlpSiteRecBillServ
			 WHERE RecBillId IN(SELECT  RecBillId   from ALP_tblArAlpSiteRecBill  WHERE SiteId =@SiteId))
DELETE FROM ALP_tblArAlpSiteRecBillServ WHERE RecBillId IN(SELECT  RecBillId   from ALP_tblArAlpSiteRecBill  WHERE SiteId =@SiteId)
DELETE FROM ALP_tblArAlpSiteRecBill    WHERE SiteId =@SiteId

DELETE FROM ALP_tblArAlpSiteRecJobUdf WHERE RecJobEntryId IN (SELECT RecJobEntryId  from ALP_tblArAlpSiteRecJob WHERE SiteId =@SiteId)
DELETE FROM ALP_tblArAlpSiteRecJob WHERE SiteId =@SiteId
--End
 DELETE FROM [dbo].[ALP_tblArAlpSite]  
 WHERE [SiteId] = @SiteId  
 RETURN 0  
END