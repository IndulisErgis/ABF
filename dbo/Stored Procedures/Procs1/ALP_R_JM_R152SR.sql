
  
 
CREATE PROCEDURE [dbo].[ALP_R_JM_R152SR]  
 @StartDate dateTime,  
 @EndDate dateTime,
 @Market VARCHAR(255)
   
AS  
BEGIN  
SET NOCOUNT ON;  
--Converted from Access qryJM-SR152-QR152 8/14/18 - ER  
SELECT   
qry152.SysType, 
Sum(qry152.RMR) AS RMRAdded, 
Sum(qry152.TotalPrice) AS JobPrice, 
Sum(qry152.BasePrice) AS Base, 
Sum(qry152.Connects) AS Connections, 
Sum(Case when qry152.BasePrice=0 then 0 else qry152.TotalPrice - qry152.BasePrice end) AS AddPrice
   
FROM 
ufxALP_R_Jm_R152_Q004_Q005_Q013(@StartDate,@EndDate,@Market) AS qry152
  
GROUP BY    
qry152.SysType;
  
END