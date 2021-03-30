
 CREATE Procedure [dbo].[Alp_comArAlpDeleteFuturePrices]  
@ID int, @sDate datetime, @lUnits int  
AS  
SET NOCOUNT ON  
  
UPDATE Alp_tblArAlpSiteRecBillServ   
SET Alp_tblArAlpSiteRecBillServ.ActiveCycleId = @lUnits--, tblArAlpSiteRecBillServ.FinalBillDate = @sDate  
WHERE (((Alp_tblArAlpSiteRecBillServ.RecBillId)=@ID))