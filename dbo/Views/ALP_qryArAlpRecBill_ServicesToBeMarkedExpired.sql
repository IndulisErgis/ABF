CREATE VIEW [dbo].[ALP_qryArAlpRecBill_ServicesToBeMarkedExpired]  
--mah 1/7/16: created view.  
AS  

 WITH [LastPrice] AS   
 (  
  SELECT  
   MAX([p].[RecBillServPriceId]) AS [RecBillServPriceId]  
  FROM [dbo].[ALP_tblArAlpSiteRecBillServPrice] AS [p]  
  GROUP BY [p].[RecBillServId]  
 )  
 SELECT  
  [srb].[custId],
  [srb].[SiteId], 
  [srbs].[RecBillServId], 
  [srbs].[ServiceID],  
  [srbs].[Desc],  
  [srbs].[ServiceStartDate],  
  [srbsp].[EndBillDate],
  [srbs].[BilledThruDate],
  [srbs].[FinalBillDate],
  [srbs].[status]
 FROM 
 [dbo].[ALP_tblArAlpSiteRecBill_view] AS [srb]  
	 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ_view] AS [srbs]  
		ON [srbs].[RecBillId] = [srb].[RecBillId]  
	 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice_view] AS [srbsp]  
		ON [srbsp].[RecBillServId] = [srbs].[RecBillServId]  
	 INNER JOIN [LastPrice] AS [l]  
		ON [l].[RecBillServPriceId] = [srbsp].[RecBillServPriceId]  
 WHERE [srbs].[status] = 'active'
	AND([srbsp].[EndBillDate] IS NOT NULL AND [srbsp].[EndBillDate] <= GetDate())
	AND([srbs].[BilledThruDate] IS NOT NULL AND [srbs].[BilledThruDate] <= GetDate())