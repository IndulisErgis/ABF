CREATE Procedure dbo.Alp_qryArAlpUpdateCustStatus      
 @ID pcustid, @bStatus bit      
AS      
SET NOCOUNT ON      
UPDATE Alp_tblArCust       
SET Alp_tblArCust.AlpInactive = case  when   @bStatus =0 then 'false' else 'true' end  
WHERE Alp_tblArCust.AlpCustId  = @ID  
  
UPDATE dbo.tblArCust       
SET dbo.tblArCust.[Status]  = case  when   @bStatus =0 then  0 else 1 end          
WHERE  dbo.tblArCust.CustId   = @ID