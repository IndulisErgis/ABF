CREATE Procedure dbo.Alp_qryArAlpUpdateCancelledActivePrice  
@ID bigint, @Price pdec  
AS  
SET NOCOUNT ON  
UPDATE Alp_tblArAlpSiteRecBill   
SET Alp_tblArAlpSiteRecBill.ActivePrice = [ActivePrice] - @Price, 
Alp_tblArAlpSiteRecBill.ActiveRMR = [ActivePrice] - @Price  
WHERE Alp_tblArAlpSiteRecBill.RecBillId = @ID