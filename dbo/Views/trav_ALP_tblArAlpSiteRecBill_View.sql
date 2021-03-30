﻿CREATE VIEW [dbo].[trav_ALP_tblArAlpSiteRecBill_View]
AS
SELECT t.[AcctCode]
, t.[ActiveCost]
, t.[ActivePrice]
, t.[ActiveRMR]
, t.[AddnlDesc]
, t.[BillCycleId]
, t.[CatId]
, t.[ContractID]
, t.[CostTotal]
, t.[CreateDate]
, t.[CustId]
, t.[CustPODate]
, t.[CustPONum]
, t.[Desc]
, t.[GLAcctCOGS]
, t.[GLAcctInv]
, t.[GLAcctSales]
, t.[InvcConsolidationSiteId]
, t.[ItemId]
, t.[LastUpdateDate]
, t.[LocID]
, t.[MailSiteYN]
, t.[ModifiedBy]
, t.[ModifiedDate]
, t.[NextBillDate]
, t.[NonTaxTotal]
, t.[NonTaxTotalFgn]
, t.[RecBillId]
, t.[RecBillNum]
, t.[SalesTaxTotal]
, t.[SalesTaxTotalFgn]
, t.[SiteId]
, t.[TaxAdj]
, t.[TaxAmtAdj]
, t.[TaxClass]
, t.[TaxClassAdj]
, t.[TaxLocAdj]
, t.[TaxTotal]
, t.[TaxTotalFgn]
, t.[UploadDate]
, t.[UseInvcConsolidationSiteYn]
 FROM dbo.[ALP_tblArAlpSiteRecBill] t