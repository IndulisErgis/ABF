 CREATE Procedure dbo.ALP_qryArAlpAppendCreditMemoHeader  
@sTransId pTransId, @sBatchId pBatchId, @sInvcDate datetime, @nFiscalYear smallint, @nGLPeriod smallint, @ID pTransId,  
--blm 11/18/03 Added CustId  
@CustId pCustId  
AS  
SET NOCOUNT ON  
INSERT INTO tblArTransHeader( TransId, TransType, BatchId, CustId, ShipToID, ShipToName, ShipToAddr1, ShipToAddr2, ShipToCity,   
 ShipToRegion, ShipToCountry, ShipToPostalCode, ShipVia, TermsCode, TaxableYN, InvcNum, WhseId, OrderDate, ShipNum,   
 ShipDate, InvcDate, Rep1Id, Rep1Pct, Rep2Id, Rep2Pct, TaxOnFreight, TaxClassFreight, TaxClassMisc, PostDate, FiscalYear, GLPeriod,   
 TaxGrpID, TaxSubtotal, NonTaxSubtotal, SalesTax, Freight, Misc, TotCost,  TaxSubtotalFgn, NonTaxSubtotalFgn, SalesTaxFgn,   
 FreightFgn, MiscFgn, TotCostFgn,  PrintStatus, CustPONum, DistCode, CurrencyID, ExchRate, DiscDueDate, NetDueDate, DiscAmt,   
 SumHistPeriod, TaxAmtAdj, TaxAmtAdjFgn, TaxAdj, TaxLocAdj, TaxClassAdj, BillingPeriodFrom, PMTransType, ProjItem, BillingPeriodThru,   
 BillingFormat )  
SELECT @sTransId , -1 , @sBatchId , tblArHistHeader.CustId, tblArHistHeader.ShipToID,   
 tblArHistHeader.ShipToName, tblArHistHeader.ShipToAddr1, tblArHistHeader.ShipToAddr2, tblArHistHeader.ShipToCity,   
 tblArHistHeader.ShipToRegion, tblArHistHeader.ShipToCountry, tblArHistHeader.ShipToPostalCode, tblArHistHeader.ShipVia,   
 tblArHistHeader.TermsCode, tblArHistHeader.TaxableYN, tblArHistHeader.InvcNum, tblArHistHeader.WhseId, @sInvcDate ,   
 tblArHistHeader.ShipNum, @sInvcDate , @sInvcDate, tblArHistHeader.Rep1Id, tblArHistHeader.Rep1Pct,   
 tblArHistHeader.Rep2Id, tblArHistHeader.Rep2Pct, tblArHistHeader.TaxOnFreight, tblArHistHeader.TaxClassFreight, tblArHistHeader.TaxClassMisc,   
 Null , @nFiscalYear, @nGLPeriod, tblArHistHeader.TaxGrpID, tblArHistHeader.TaxSubtotal, tblArHistHeader.NonTaxSubtotal,  
 tblArHistHeader.SalesTax, tblArHistHeader.Freight, tblArHistHeader.Misc, tblArHistHeader.TotCost,    
 tblArHistHeader.TaxSubtotalFgn, tblArHistHeader.NonTaxSubtotalFgn, tblArHistHeader.SalesTaxFgn, tblArHistHeader.FreightFgn,   
 tblArHistHeader.MiscFgn, tblArHistHeader.TotCostFgn,  0 , tblArHistHeader.CustPONum,   
 tblArHistHeader.DistCode, tblArHistHeader.CurrencyID, tblArHistHeader.ExchRate, tblArHistHeader.DiscDueDate, tblArHistHeader.NetDueDate,   
 tblArHistHeader.DiscAmt, tblArHistHeader.SumHistPeriod, tblArHistHeader.TaxAmtAdj, tblArHistHeader.TaxAmtAdjFgn, tblArHistHeader.TaxAdj,   
 tblArHistHeader.TaxLocAdj, tblArHistHeader.TaxClassAdj, tblArHistHeader.BillingPeriodFrom, tblArHistHeader.PMTransType, tblArHistHeader.ProjItem,   
 tblArHistHeader.BillingPeriodThru, tblArHistHeader.BillingFormat  
FROM tblArHistHeader 
WHERE tblArHistHeader.TransId =@ID AND CustID = @CustId 
--TotPmtAmt,   TotPmtAmtFgn,tblArHistHeader.TotPmtAmt,tblArHistHeader.TotPmtAmtFgn,
INSERT INTO ALP_tblArTransHeader  (AlpTransId , AlpSiteID, AlpMailSiteYN, AlpJobNum )  
SELECT @sTransId , ALP_tblArHistHeader.AlpSiteID, ALP_tblArHistHeader.AlpMailSiteYN, ALP_tblArHistHeader.AlpJobNum  
FROM ALP_tblArHistHeader  
WHERE ALP_tblArHistHeader.AlpTransId  =@ID