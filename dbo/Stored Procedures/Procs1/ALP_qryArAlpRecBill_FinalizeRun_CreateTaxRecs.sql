 
CREATE  Procedure [dbo].[ALP_qryArAlpRecBill_FinalizeRun_CreateTaxRecs]        
--mah 11/13/15 - created to build Tax records for Recurring Billing auto generated transactions.  
--					After recent OSAS updates, the AR bulk insert of transactions is not handling it. 
--  This version assigns all tax amounts to one ( max ) taxclass used in the transaction.  
--        Reason, splitting it across tax classes involves trying to calculate the tax amount by detail record, 
--        and apply rounding at that lower level.  Situations exist where the sum of these rounded detail tax amounts 
--		  would not equal the rounded total already in the transaction header. 
--  The Sales Tax allocation process needs to be reviewed and possibly revamped within the Recurring Billing Process.
--		 The goal is to prepare Tax records by each tax level within the tax group.     
 @RunId integer    
AS        
SET NOCOUNT ON        

--find all sites touched, all recurring invoices just created   
SELECT DISTINCT      
  [rr].[SiteId]   INTO #TouchedSites     
 FROM [dbo].[ALP_tblArAlpRecBillRunRecords] AS [rr]      
 WHERE [rr].[RunId] = @RunId 
      
--SELECT D.TransId, D.TaxClass, SUM(D.UnitPriceSell * D.QtyShipSell) AS TaxableAmtByTaxClass  INTO #RecTransIDs
--FROM tblArTransDetail D INNER JOIN tblArTransHeader H ON D.TransId = H.TransId
--	INNER JOIN ALP_tblArTransHeader AH ON H.TransID = AH.AlpTransID
--	INNER JOIN #TouchedSites S ON AH.AlpSiteID = S.SiteId
--WHERE H.InvcNum LIKE 'R%' AND H.BatchID LIKE 'REC%'  AND  H.TransType = 1 AND H.TaxableYN = 1
--GROUP BY D.TransId, D.TaxClass

SELECT D.TransId, MAX(D.TaxClass) AS TaxClass INTO #RecTransIDs
FROM tblArTransDetail D INNER JOIN tblArTransHeader H ON D.TransId = H.TransId
	INNER JOIN ALP_tblArTransHeader AH ON H.TransID = AH.AlpTransID
	INNER JOIN #TouchedSites S ON AH.AlpSiteID = S.SiteId
WHERE H.InvcNum LIKE 'R%' AND H.BatchID LIKE 'REC%'  AND  H.TransType = 1 AND H.TaxableYN = 1
GROUP BY D.TransId

--If no tax records exist yet, create one, but only for TaxClass that is not already table and non-zero taxrate.  
--  --Do not want to duplicate the total tax amount of the transaction as a whole.   
INSERT into tblArTransTax ( TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn, Taxable, TaxableFgn,   
    NonTaxable, NonTaxableFgn, LiabilityAcct )        
  --SELECT tblSmTaxLocDetail.SalesTaxPct, R.TaxableAmtByTaxClass, CalTaxAmt = CAST(((tblSmTaxLocDetail.SalesTaxPct * R.TaxableAmtByTaxClass) / 100.00) AS Decimal(10,2)),R.TransId, tblArTransHeader.TaxGrpID, R.TaxClass,tblSmTaxLoc.TaxLevel,     
  SELECT R.TransId, tblArTransHeader.TaxGrpID, R.TaxClass,tblSmTaxLoc.TaxLevel,     
    TaxAmt = tblArTransHeader.SalesTax ,    
    TaxAmtFgn =  tblArTransHeader.SalesTaxFgn,    
    Taxable = tblArTransHeader.TaxSubtotal,     
    TaxableFgn = tblArTransHeader.TaxSubtotalFgn,     
    NonTaxable = tblArTransHeader.NonTaxSubtotal,     
    NonTaxableFgn = tblArTransHeader.NonTaxSubtotalFgn,         
    LiabilityAcct = tblSmTaxLoc.GLAcct    
   FROM  #RecTransIDs R INNER JOIN tblArTransHeader ON R.TransId = tblArTransHeader.TransId
		INNER JOIN tblSmTaxLoc ON tblArTransHeader.TaxGrpID = tblSmTaxLoc.TaxLocID    
		INNER JOIN tblSmTaxLocDetail ON tblSmTaxLoc.TaxLocID = tblSmTaxLocDetail.TaxLocId     
			AND  tblSmTaxLocDetail.TaxClassCode = R.TaxClass  
        LEFT OUTER JOIN tblArTransTax ON  R.TransId = tblArTransTax.TransId
			--AND R.TaxClass = tblArTransTax.TaxClass    
   WHERE tblArTransTax.TransId is null    
		 AND tblSmTaxLocDetail.SalesTaxPct <> 0  --AND tblSmTaxLocDetail.TaxableYn <> 0  