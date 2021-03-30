 CREATE Procedure dbo.Alp_qryArAlpSiteRecBillServProcessed  
@RecBillId int  
AS  
SET NOCOUNT ON  
  
-- blm 9/22/03 EFI # 1168 - Check if the Recur Bill group has any services that have been processed  
  
SELECT *  
FROM  tblArAlpSiteRecBillServ   
WHERE tblArAlpSiteRecBillServ.RecBillId = @RecBillID AND Processed = 1