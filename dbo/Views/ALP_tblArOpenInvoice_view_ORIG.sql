CREATE VIEW dbo.ALP_tblArOpenInvoice_view_ORIG    
AS    
  
  
--SELECT     p.*, dbo.ALP_tblArOpenInvoice.*  ,  
--  s.[CustName], s.[ClassId], s.[GroupCode], s.[AcctType], s.[PriceCode], s.[CreditLimit], s.[TerrId],  
--       s.[CustLevel], s.[Status] CustomerStatus   
--FROM         dbo.trav_tblArOpenInvoice_view p  
-- LEFT OUTER JOIN  dbo.ALP_tblArOpenInvoice ON p.Counter = dbo.ALP_tblArOpenInvoice.AlpCounter    
--   LEFT JOIN  tblArCust  s on p.CustId = s.CustId  WHERE p.[Status] <> 4  
  
SELECT * FROM (SELECT p.[Counter], p.[CustId], p.[InvcNum], p.[CredMemNum],   
 p.[RecType], p.[Status], p.[DistCode], p.[TermsCode], p.[TransDate], p.[DiscDueDate], p.[NetDueDate],   
 SIGN(p.[RecType]) * p.[Amt] AS [Amt], SIGN(p.[RecType]) * p.[AmtFgn] AS [AmtFgn], SIGN(p.[RecType]) * p.[DiscAmt]   
 AS [DiscAmt], SIGN(p.[RecType]) * p.[DiscAmtFgn] AS [DiscAmtFgn], p.[PmtMethodId], p.[CheckNum], p.[JobId],   
 p.[CurrencyId], p.[ExchRate], p.[GlPeriod], p.[FiscalYear], p.[PhaseId], p.[ProjId], p.[PostRun], p.[TransId],   
 p.[GainLossStatus], p.[CustPONum], p.[SourceApp], s.[CustName], s.[ClassId], s.[GroupCode], s.[AcctType],  
  s.[PriceCode], s.[CreditLimit], s.[TerrId], s.[CustLevel], s.[Status] CustomerStatus ,  
 AlpCounter,AlpCustId,AlpInvcNum,AlpSiteID,AlpMailSiteYn,AlpPostRun,AlpTransID,AlpSubscriberInvcYn  
    FROM  dbo.trav_tblArOpenInvoice_view p   
   LEFT JOIN dbo.ALP_tblArOpenInvoice a on p.counter=a.alpcounter  
  LEFT JOIN dbo.tblArCust s on p.CustId = s.CustId WHERE p.[Status] <> 4)ds