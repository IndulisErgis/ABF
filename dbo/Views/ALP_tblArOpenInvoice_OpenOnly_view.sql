  
CREATE VIEW dbo.ALP_tblArOpenInvoice_OpenOnly_view      
AS      
      
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
  LEFT JOIN dbo.tblArCust s on p.CustId = s.CustId WHERE p.[Status] <> 4)ds