


CREATE Procedure [dbo].[ALP_R_JM_R150SR-SummarybyMarketCode]
	(
	@Branch VARCHAR(255)='<ALL>',
	@Department VARCHAR(255)='<ALL>',
	@Division VARCHAR(255)='<ALL>',
	@Startdate Datetime ,
	@Enddate Datetime = null
	)

 AS  
 Begin
--converted from access qryJm-SR150-QR150 - 4/7/2015 - ER	
SELECT 
qry150.MarketCode, 
Sum(qry150.RMR) AS RMRAdded, 
Sum(qry150.TotalPrice) AS JobPrice, 
Sum(qry150.Connects) AS Connections, 
Sum(qry150.BasePrice) AS Base, 
Sum(Case when qry150.BasePrice=0 then 0 else qry150.TotalPrice - qry150.BasePrice end) AS AddPrice

FROM  
ufxALP_R_Jm_R150_Q004_Q005(@Branch,@Department,@Division,@Startdate,@Enddate) AS qry150

GROUP BY 
qry150.MarketCode

End