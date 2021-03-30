
  CREATE FUNCTION [dbo].[ALP_ufxJmComm_GetInvoiceDataForEligibleJobs]()  
-- Get status of invoice from AR Hist table.  
-- Includes only Invoices in table ALP_tmpJmComm_EligibleJobs   
-- Returns:  
-- Invoice Number   
-- Invoice date,  
-- total amt billed,   
-- total billed for recurring services,  
-- total billed for parts and labor,  
-- invoice balance,  
-- invoice status ('open' or 'paid')  
-- created 06/04/04 EFI#1440  MAH    
RETURNS TABLE  
AS  
RETURN  
SELECT  ALP_tmpJmComm_EligibleJobs.InvcNum,   InvoiceDate = MIN(tblArHistHeader.InvcDate),
-- mah 02/17/13: changed from grabbing line item info to getting total from header  
-- AmtBilled = SUM(tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell), 
 AmtBilled = SUM(CASE WHEN tblArHistHeader.TransType > 0 
				THEN (tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell)
				ELSE (tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell * -1 )
				END),   
 RecurAmt = SUM(CASE WHEN AlpServiceType = 0 THEN tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell   
				WHEN AlpServiceType >= 4 THEN tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell  
				ELSE 0 END),  
 PartsLaborAmt = SUM(CASE WHEN AlpServiceType = 1 THEN tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell  
				WHEN AlpServiceType = 2 THEN tblArHistDetail.UnitPriceSell * tblArHistDetail.QtyShipSell  
				ELSE 0 END),  
 Balance = dbo.ALP_ufxJmComm_CheckInvcBalance(ALP_tmpJmComm_EligibleJobs.InvcNum),  
 PaidStatus = dbo.ALP_ufxJmComm_CheckInvcStatus(ALP_tmpJmComm_EligibleJobs.InvcNum)  
FROM    ALP_tmpJmComm_EligibleJobs   
   INNER JOIN tblArHistHeader   
				ON ALP_tmpJmComm_EligibleJobs.InvcNum = tblArHistHeader.InvcNum  
   INNER JOIN tblArHistDetail  
                ON tblArHistDetail.PostRun = tblArHistHeader.PostRun   
					 AND   
					tblArHistDetail.TRansID = tblArHistHeader.TRansID  
   LEFT OUTER JOIN ALP_tblInItem   
				ON tblArHistDetail.PartId = ALP_tblInItem.AlpItemId  
GROUP BY ALP_tmpJmComm_EligibleJobs.InvcNum
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_ufxJmComm_GetInvoiceDataForEligibleJobs] TO [JMCommissions]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_ufxJmComm_GetInvoiceDataForEligibleJobs] TO [JMCommissions]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_ufxJmComm_GetInvoiceDataForEligibleJobs] TO [JMCommissions]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_ufxJmComm_GetInvoiceDataForEligibleJobs] TO [JMCommissions]
    AS [dbo];

