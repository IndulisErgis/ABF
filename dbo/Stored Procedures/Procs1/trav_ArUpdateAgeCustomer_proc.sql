CREATE procedure [dbo].[trav_ArUpdateAgeCustomer_proc]  
 @CustId pCustID
AS  
SET NOCOUNT ON    
BEGIN TRY    
  --create the list of customers to age    
  CREATE TABLE #CustomerList (CustId pCustId, UNIQUE CLUSTERED (CustId))    
      
  --set the list of customers to process with the    
  INSERT INTO #CustomerList (CustId)    
  SELECT CustId FROM dbo.tblArCust where CustId=@CustId    
    
  --execute the aging    
  EXEC dbo.trav_ArAgeCustomer_proc    
 END TRY    
BEGIN CATCH    
 EXEC dbo.trav_RaiseError_proc    
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArUpdateAgeCustomer_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArUpdateAgeCustomer_proc';

