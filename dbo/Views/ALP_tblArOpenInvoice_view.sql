CREATE VIEW dbo.ALP_tblArOpenInvoice_view      
AS      
 -- MAH 02/22/14 - removed Status check - so ALL items in the OPen Invoice table are available.
 -- This is necessary so that all reports and invoice reprints can show payments made against invoices.
 -- I created another view, 'ALP_tblArOpenInvoice_OpenOnly_view', that can be used when status = '4' items are to be excluded   
SELECT * FROM (SELECT p.[Counter], p.[CustId], p.[InvcNum], p.[CredMemNum],     
 p.[RecType], p.[Status], p.[DistCode], p.[TermsCode], p.[TransDate], p.[DiscDueDate], p.[NetDueDate],     
 p.[Amt],  p.[AmtFgn], p.[DiscAmt]     
 ,p.[DiscAmtFgn], p.[PmtMethodId], p.[CheckNum], p.[JobId],     
 p.[CurrencyId], p.[ExchRate], p.[GlPeriod], p.[FiscalYear], p.[PhaseId], p.[ProjId], p.[PostRun], p.[TransId],     
 p.[GainLossStatus], p.[CustPONum], p.[SourceApp], s.[CustName], s.[ClassId], s.[GroupCode], s.[AcctType],    
 s.[PriceCode], s.[CreditLimit], s.[TerrId], s.[CustLevel], s.[Status] CustomerStatus,    
 AlpCounter,AlpCustId,AlpInvcNum,AlpSiteID,AlpMailSiteYn,AlpPostRun,AlpTransID,AlpSubscriberInvcYn    
    FROM  dbo.trav_tblArOpenInvoice_view p     
   LEFT JOIN dbo.ALP_tblArOpenInvoice a on p.counter=a.alpcounter    
  LEFT JOIN dbo.tblArCust s on p.CustId = s.CustId --WHERE p.[Status] <> 4
  )ds