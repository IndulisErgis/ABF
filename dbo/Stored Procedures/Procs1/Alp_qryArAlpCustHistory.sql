CREATE PROCEDURE dbo.Alp_qryArAlpCustHistory @Cust varchar(10)  
As  
SET NOCOUNT ON  
SELECT  AlpSiteID,  InvcNum, Min(TransDate) AS FirstOfTransDate,   
Amount = Sum(CASE   
 WHEN RecType > 0  THEN Amt  
 ELSE 0  
END),   
Pay = Sum(CASE   
 WHEN RecType < 0  THEN Amt  
 ELSE 0  
END),   
Balance = Sum(CASE  
 WHEN RecType > 0 THEN Amt  
 ELSE Amt * -1  
END),  
 Status  
FROM ALP_tblArOpenInvoice_view    
WHERE (((CustId)=@Cust))  
GROUP BY AlpSiteID,  InvcNum,  Status  
HAVING ((( Status)<>4))  
ORDER BY  InvcNum, Min( TransDate);