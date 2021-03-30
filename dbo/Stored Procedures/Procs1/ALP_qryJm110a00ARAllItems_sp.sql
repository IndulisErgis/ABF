
CREATE PROCEDURE [dbo].[ALP_qryJm110a00ARAllItems_sp]  
/* RecordSource for Invoices (All)  subform of Control Center */  
(  
 @CCcustID pcustID = null  
)  
AS  
--mah 12/30/15 - added SiteID to payments, where available
DECLARE @Finch varchar(15)
SET @Finch = (SELECT TOP 1 ConfigValue FROM dbo.tblSmConfigValue V INNER JOIN SYS.dbo.tblSmConfig C ON V.ConfigRef = C.ConfigRef
				WHERE  C.AppId = 'AR' AND C.ConfigID = 'InvcFinch')
SELECT   
 tblArHistHeader.CustId,    
 SiteId = ALP_tblArHistHeader.AlpSiteID,   
 [Date] = tblArHistHeader.InvcDate,   
 InvcNum = tblArHistHeader.InvcNum,   
 Type = (CASE WHEN (TransType=1) THEN 'Invc' ELSE 'Cred' END),   
 Amount=[TransType]*([TaxSubtotal]+[NonTaxSubtotal]+[SalesTax]+[Freight]+[Misc]),  
 CheckNum = ' ',  
 Method = ' ',
 --Below columns added on 06 May 2015
 PostRun,TransId,BatchId   
FROM tblArHistHeader   
LEFT OUTER JOIN  
                      ALP_tblArHistHeader ON tblArHistHeader.PostRun = ALP_tblArHistHeader.AlpPostRun and   
                      tblArHistHeader.TransId = ALP_tblArHistHeader.AlpTransId  
WHERE  tblArHistHeader.CustId=@CCcustID  
--05/01/15 MAH - corrected this - removed Group By 
--GROUP BY   
-- tblArHistHeader.CustId,   
-- tblArHistHeader.InvcDate,   
-- tblArHistHeader.InvcNum,  
-- TransType* (TaxSubtotal+NonTaxSubtotal+SalesTax+Freight+Misc),  
-- ALP_tblArHistHeader.AlpSiteID,   
-- (CASE WHEN TransType=1 THEN 'Invc' ELSE 'Cred' END)  
UNION ALL 
--mah 12/30/15- added SiteID info, if available
SELECT   
 tblArHistPmt.CustId, 
 SiteId = CASE WHEN AP.AlpSiteID IS NULL THEN 0 ELSE AP.AlpSiteId END ,    
 --SiteId = '0',   
 [Date] = tblArHistPmt.PmtDate,   
 InvcNum = tblArHistPmt.InvcNum,   
 Type = 'Pmt',  
 Amount = tblArHistPmt.PmtAmt* -1,  
 CheckNum , 
 ----05/01/15 MAH - inserted DepositID, when CHeckNum is empty
  --CheckNum = CASE WHEN CheckNum is null THEN 'n/a ' + tblArHistPmt.DepNum
--	ELSE CheckNum
--	END, 
 Method = tblArHistPmt.PmtMethodID, 
 --Below columns added on 06 May 2015
 PostRun,TransId,DepNum as BatchId     
FROM tblArHistPmt  LEFT OUTER JOIN ALP_tblArHistPmt AP ON tblArHistPmt.Counter = AP.AlpCounter  
--SELECT   
-- tblArHistPmt.CustId,    
-- SiteId = '0',   
-- [Date] = tblArHistPmt.PmtDate,   
-- InvcNum = tblArHistPmt.InvcNum,   
-- Type = 'Pmt',  
-- Amount = tblArHistPmt.PmtAmt* -1,  
-- CheckNum , 
-- ----05/01/15 MAH - inserted DepositID, when CHeckNum is empty
--  --CheckNum = CASE WHEN CheckNum is null THEN 'n/a ' + tblArHistPmt.DepNum
----	ELSE CheckNum
----	END, 
-- Method = tblArHistPmt.PmtMethodID, 
-- --Below columns added on 06 May 2015
-- PostRun,TransId,DepNum as BatchId     
--FROM tblArHistPmt  
WHERE  tblArHistPmt.CustId=@CCcustID  
UNION ALL  
SELECT   
 tblArHistFinch.CustID,   
 SiteId = '0',   
 [Date] = tblArHistFinch.FinchDate,  
 --InvcNum ='LATE CHRG', 
 InvcNum = @Finch ,
 --convert(varchar (10),  tblArHistFinch.FinchDate,101),  
 Type = 'LC',  
 Amount = tblArHistFinch.FinchAmt,  
 CheckNum = ' ',  
 Method =' ',
 --Below columns added on 06 May 2015
 PostRun,'' as TransID,'' as BatchID      
FROM tblArHistFinch  
WHERE  tblArHistFinch.CustId=@CCcustID  
ORDER BY 
--Order by changed on 10 Apr 2015 by NSK.Earlier it was InvcNum and then by Date.
 [Date] DESC,  
 InvcNum DESC