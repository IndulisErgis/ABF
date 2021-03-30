CREATE FUNCTION [dbo].[ufxALP_R_AR_R510c_OpenInvBal]  
(   
 @CustID varchar(10)  
)  
RETURNS TABLE   
AS  
RETURN   
(  
SELECT   
 OI.CustId,   
 --Sum(CASE RecType WHEN 1 THEN Amt ELSE (Amt *-1) END) AS Balance  
 Sum(CASE WHEN RecType >= 1 THEN Amt ELSE (Amt *-1) END) AS Balance 
  
FROM ALP_tblArOpenInvoice_view AS OI  
  
WHERE   
(  
 (CustID=@CustID OR @CustID='<ALL>')  
 AND   
 OI.Status<>4        
)  
GROUP BY OI.CustId  
  
--HAVING Sum(CASE RecType WHEN 1 THEN Amt ELSE [Amt]*-1 END)<>0  
HAVING Sum(CASE WHEN RecType >= 1 THEN Amt ELSE (Amt *-1) END)<>0  
)