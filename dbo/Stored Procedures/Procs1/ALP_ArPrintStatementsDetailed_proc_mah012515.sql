CREATE PROCEDURE [dbo].[ALP_ArPrintStatementsDetailed_proc_mah012515]      
@CutoffDate datetime,       
@ClosingDate datetime,       
@StatementDate datetime,       
@InvcFinch varchar(15), --Finance charge invoice number      
@PrintStatements tinyint = 0, -- 0 = All, 1 = With Activity, 2 = Nonzero balances, 3 = Positive balances, 4 = 30+, 5 = 60+, 6 = 90+      
@ApplyUnappliedCreditToOldest bit = 1,      
@InvoiceSort tinyint = 1 -- Invoice Sort option (0 = Invoice number, 1 = Invoice Date)  --MAH ADD:  2 = PostalCode/CustID/SiteID    
AS      
SET NOCOUNT ON      
BEGIN TRY      
    
 --PET:http://webfront:801/view.php?id=232405      
 --PET:http://webfront:801/view.php?id=236015      
 --MOD:Finance Charge Enhancements      
 --PET:http://webfront:801/view.php?id=239119      
 --PET:http://webfront:801/view.php?id=242891      
 --MAH 06/22/14 - created this proc.  Based on trav_ArPrintStatements_proc.  major changes to data returned. Summary:  
 --   return invoice details ( line items ) as additional detail records  
 --   return SiteID info, and additional Cust info   
 --         add more sort order options - to allow sort by Postal Code before Cust, and to include SiteID in sort  
 --   add custom statement messages based on cust Group Code   
 --   add Company Name to footer   
 --MAH 11/19/2014 several changes to control display of invoice  
      
 ----expects the list of customers to be provided via the #CustomerList table      
 --CREATE TABLE #CustomerList (CustId pCustId, PRIMARY KEY (CustId))    
     
 --mah: section below is ONLY for testing the resultset.  TO BE REMOVED!    
 CREATE TABLE #CustomerList (CustId pCustId, PRIMARY KEY (CustId))    
 INSERT INTO #CustomerList (CustId) SELECT CustID from dbo.tblArCust where CustID = '106330' --GroupCode = 'C' OR GroupCode = 'A'--      
   
 --MAH: get company name  
 DECLARE @CompanyName varchar(50)  
  SET @CompanyName = (SELECT Name FROM SYS.dbo.tblSmCompInfo WHERE SYS.dbo.tblSmCompInfo.CompID = db_name() )  
 --MAH - TEMPORARY! - use parameter to control display of open invoices  
 DECLARE @IncludeOnlyOpenInvoices tinyint  
 SET @IncludeOnlyOpenInvoices  = 0      
     
 --setup a temp table for the invoices to age      
 CREATE TABLE #AgeInvoiceList       
 (      
  CustId pCustId,       
  InvcNum varchar(15),       
  RecType smallint,       
  AgingDate datetime,       
  AmountDue pDec default(0)     
    -- mah:  add site info here     
   ,AlpSiteId integer NULL,    
   AlpSiteName varchar(150),    
   AlpSiteAddr1 varchar(40),    
   AlpSiteAddr2 varchar(60)       
 )   
 --MAH 11/18/14 - added :  
  CREATE TABLE #AgeInvoiceListBySite       
 (      
   CustId pCustId,       
   InvcNum varchar(15),       
   AlpSiteId integer NULL,    
   AlpSiteName varchar(150),    
   AlpSiteAddr1 varchar(40),    
   AlpSiteAddr2 varchar(60),  
   PRIMARY KEY (CustId, InvcNum)       
 )          
      
 --setup a table to capture the aged invoice detail      
 CREATE TABLE #InvoiceAging      
 (      
  CustId pCustId,       
  InvcNum varchar(15),       
  UnappliedCredit pDec DEFAULT(0),       
  UnpaidFinch pDec DEFAULT(0),      
  AmtCurrent pDec DEFAULT(0),       
  AmtDue1 pDec DEFAULT(0),       
  AmtDue2 pDec DEFAULT(0),       
  AmtDue3 pDec DEFAULT(0),       
  AmtDue4 pDec DEFAULT(0),       
  PRIMARY KEY (CustId, InvcNum)      
 )      
      
 --setup a table to capture invoice activity      
 CREATE TABLE #InvoiceActivity      
 (      
  [Counter] INT,      
  CustId pCustId,       
  CurrencyId pCurrency,      
  InvcNum varchar(15),       
  TransDate datetime,       
  RecType smallint,       
  CheckNum nvarchar(25) NULL,       
  Charges pDec DEFAULT(0),       
  Credits pDec DEFAULT(0),      
  AmountDue pDec DEFAULT(0),       
  GroupType tinyint NOT NULL,    
  -- mah:  add site and invoice details info here     
   AlpSiteId integer NULL,    
   AlpSiteName varchar(150),    
   AlpSiteAddr1 varchar(40),    
   AlpSiteAddr2 varchar(60),  
   AlpGroupTypeTxt varchar(10),
   --mah 01/25/15:
   TransId pTransId NULL     
   PRIMARY KEY ([Counter])    
     
 )      
      
 --setup a table for the customer summary      
 CREATE TABLE #CustomerSummary      
 (      
  CustId pCustId,       
  AcctType tinyint,      
  YTDFinch pDec DEFAULT(0),      
  UnpaidFinch pDec DEFAULT(0),      
  AmtCurrent pDec DEFAULT(0),       
  AmtDue1 pDec DEFAULT(0),       
  AmtDue2 pDec DEFAULT(0),       
  AmtDue3 pDec DEFAULT(0),       
  AmtDue4 pDec DEFAULT(0),       
  UnappliedCredit pDec DEFAULT(0),   
  --mah 06/13/14 - added PostalCode and GroupCode to summary - to allow sorting by this field  
  PostalCode varchar(10) DEFAULT(''),  
  GroupCode varchar(1) DEFAULT('')      
  PRIMARY KEY (CustId)      
 )      
      
      
 --=========================      
 --Balance Forward Customers      
 --=========================      
      
 --populate the customer summary with any balance forward customers   
 --mah added postalcode capture     
 INSERT INTO #CustomerSummary (CustId, AcctType, YTDFinch, UnpaidFinch      
  , AmtCurrent, AmtDue1, AmtDue2, AmtDue3, AmtDue4, UnappliedCredit, PostalCode, GroupCode)      
 SELECT l.CustId, AcctType, 0, ISNULL(c.NewFinch, 0) + ISNULL(c.UnpaidFinch, 0)      
  , ISNULL(c.CurAmtDue, 0), ISNULL(c.BalAge1, 0), ISNULL(c.BalAge2, 0)      
  , ISNULL(c.BalAge3, 0), ISNULL(c.BalAge4, 0), ISNULL(c.UnapplCredit, 0)  
  ,ISNULL(c.PostalCode,' ' ) , ISNULL(c.GroupCode,' ')    
 FROM #CustomerList l      
 INNER JOIN dbo.tblArCust c ON l.CustId = c.CustId      
 WHERE c.AcctType = 1      
  AND (c.StmtInvcCode = 1 OR c.StmtInvcCode = 3)      
      
 --rollup the available UnappliedCredit for each balance forward customer      
 -- (flip the sign on any existing credit and move any negative bucketed balances into the credit column)      
 IF EXISTS (SELECT * FROM #CustomerSummary WHERE AcctType = 1)      
 BEGIN      
  UPDATE #CustomerSummary SET UnappliedCredit = -UnappliedCredit      
         
  UPDATE #CustomerSummary SET UnappliedCredit = UnappliedCredit + AmtCurrent, AmtCurrent = 0 WHERE AmtCurrent < 0      
      
  UPDATE #CustomerSummary SET UnappliedCredit = UnappliedCredit + AmtDue1, AmtDue1 = 0 WHERE AmtDue1 < 0      
      
  UPDATE #CustomerSummary SET UnappliedCredit = UnappliedCredit + AmtDue2, AmtDue2 = 0 WHERE AmtDue2 < 0      
      
  UPDATE #CustomerSummary SET UnappliedCredit = UnappliedCredit + AmtDue3, AmtDue3 = 0 WHERE AmtDue3 < 0      
      
  UPDATE #CustomerSummary SET UnappliedCredit = UnappliedCredit + AmtDue4, AmtDue4 = 0 WHERE AmtDue4 < 0      
      
  UPDATE #CustomerSummary SET UnappliedCredit = UnpaidFinch + UnappliedCredit, UnpaidFinch = 0 WHERE UnpaidFinch < 0      
      
  --distribute the UnappliedCredit       
  IF @ApplyUnappliedCreditToOldest = 1      
  BEGIN      
   UPDATE #CustomerSummary SET UnpaidFinch = UnpaidFinch + UnappliedCredit, UnappliedCredit = UnpaidFinch + UnappliedCredit WHERE UnappliedCredit < 0      
      
   UPDATE #CustomerSummary SET AmtDue4 = AmtDue4 + UnappliedCredit, UnappliedCredit = AmtDue4 + UnappliedCredit WHERE UnappliedCredit < 0      
         
   UPDATE #CustomerSummary SET AmtDue3 = AmtDue3 + UnappliedCredit, UnappliedCredit = AmtDue3 + UnappliedCredit WHERE UnappliedCredit < 0      
         
   UPDATE #CustomerSummary SET AmtDue2 = AmtDue2 + UnappliedCredit, UnappliedCredit = AmtDue2 + UnappliedCredit WHERE UnappliedCredit < 0      
         
   UPDATE #CustomerSummary SET AmtDue1 = AmtDue1 + UnappliedCredit, UnappliedCredit = AmtDue1 + UnappliedCredit WHERE UnappliedCredit < 0      
         
   UPDATE #CustomerSummary SET AmtCurrent = AmtCurrent + UnappliedCredit, UnappliedCredit = AmtCurrent + UnappliedCredit WHERE UnappliedCredit < 0      
  END      
  ELSE   --DO NOT APPLY TO OLDEST FIRST      
  BEGIN      
   UPDATE #CustomerSummary SET AmtCurrent = AmtCurrent + UnappliedCredit, UnappliedCredit = AmtCurrent + UnappliedCredit WHERE UnappliedCredit < 0 AND AmtCurrent > 0      
      
   UPDATE #CustomerSummary SET AmtDue1 = AmtDue1 + UnappliedCredit, UnappliedCredit = AmtDue1 + UnappliedCredit WHERE UnappliedCredit < 0      
         
   UPDATE #CustomerSummary SET AmtDue2 = AmtDue2 + UnappliedCredit, UnappliedCredit = AmtDue2 + UnappliedCredit WHERE UnappliedCredit < 0      
      
   UPDATE #CustomerSummary SET AmtDue3 = AmtDue3 + UnappliedCredit, UnappliedCredit = AmtDue3 + UnappliedCredit WHERE UnappliedCredit < 0      
         
   UPDATE #CustomerSummary SET AmtDue4 = AmtDue4 + UnappliedCredit, UnappliedCredit = AmtDue4 + UnappliedCredit WHERE UnappliedCredit < 0      
         
   UPDATE #CustomerSummary SET UnpaidFinch = UnpaidFinch + UnappliedCredit, UnappliedCredit = UnpaidFinch + UnappliedCredit WHERE UnappliedCredit < 0      
      
   -- put remaining UnappliedCredit into curamt       
   UPDATE #CustomerSummary SET AmtCurrent = AmtCurrent + UnappliedCredit, UnappliedCredit = AmtCurrent + UnappliedCredit WHERE UnappliedCredit < 0 AND AmtCurrent > 0      
  END      
      
  --adjust each bucket for over applied UnappliedCredit      
  UPDATE #CustomerSummary      
   SET AmtCurrent = CASE WHEN AmtCurrent > 0 THEN AmtCurrent ELSE 0 END      
   , AmtDue1 = CASE WHEN AmtDue1 > 0 THEN AmtDue1 ELSE 0 END      
   , AmtDue2 = CASE WHEN AmtDue2 > 0 THEN AmtDue2 ELSE 0 END      
   , AmtDue3 = CASE WHEN AmtDue3 > 0 THEN AmtDue3 ELSE 0 END      
   , AmtDue4 = CASE WHEN AmtDue4 > 0 THEN AmtDue4 ELSE 0 END      
   , UnpaidFinch = CASE WHEN UnpaidFinch > 0 THEN UnpaidFinch ELSE 0 END      
   , UnappliedCredit = CASE WHEN UnappliedCredit < 0 THEN ABS(UnappliedCredit) ELSE 0 END      
 END      
      
      
 --=========================      
 --Open Invoice Customers      
 --=========================      
      
 --build the list of invoices to age for open invoice customers      
 -- non-held invoices for open invoice customers    
    
  --mah: modified to add Alp fields into this open invoice table   
      
  --mod begin:     
 --INSERT INTO #AgeInvoiceList (CustId, InvcNum, RecType, AgingDate, AmountDue)      
 -- SELECT i.CustId, i.InvcNum, i.RecType, i.TransDate, i.AmtFgn      
 -- FROM #CustomerList l      
 -- INNER JOIN dbo.tblArOpenInvoice i on l.CustId = i.CustId      
 -- INNER JOIN dbo.tblArCust c ON l.CustId = c.CustId      
 -- WHERE c.AcctType = 0 AND i.TransDate <= @CutoffDate AND i.[Status] <> 1      
 --  AND (c.StmtInvcCode = 1 OR c.StmtInvcCode = 3) AND i.RecType <> 5 --Exclude pro forma invoice      
     
 INSERT INTO #AgeInvoiceList (CustId, InvcNum, RecType, AgingDate, AmountDue    
  , AlpSiteId, AlpSiteName, AlpSiteAddr1, AlpSiteAddr2)      
  SELECT i.CustId, i.InvcNum, i.RecType, i.TransDate, i.AmtFgn      
  ,alpO.AlpSiteId  
  ,alpS.SiteName  
  , alpS.Addr1, alpS.Addr2    
   FROM #CustomerList l      
  INNER JOIN dbo.tblArOpenInvoice i on l.CustId = i.CustId    
  INNER JOIN dbo.tblArCust c ON l.CustId = c.CustId     
  LEFT OUTER JOIN dbo.ALP_tblArOpenInvoice alpO on i.[Counter] = alpO.[AlpCounter]      
  LEFT OUTER JOIN dbo.ALP_tblArAlpSite alpS on  alpO.AlpSiteID = alpS.SiteId    
  WHERE c.AcctType = 0 AND i.TransDate <= @CutoffDate   
  --AND i.[Status] <> 1   
   --mah added @IncludeOnlyOpenInvoices condition:  
   AND ((@IncludeOnlyOpenInvoices = 1 and i.[Status] <> 1 and i.[Status] <> 4)  OR (@IncludeOnlyOpenInvoices <> 1 AND i.[Status] <> 1))      
   AND (c.StmtInvcCode = 1 OR c.StmtInvcCode = 3) AND i.RecType <> 5 --Exclude pro forma invoice       
   --mod end   
     
      
 ----MAH ADDED FOR TESTING    
 -- select * from  #AgeInvoiceList  
     
 --MAH 11/18/14 - summary of invoices - and primary SiteID to be assigned   
  INSERT INTO #AgeInvoiceListBySite (CustId, InvcNum, AlpSiteId)    
  SELECT CustId, InvcNum, MAX(AlpSiteId)  
  FROM #AgeInvoiceList  
  --WHERE InvcNum <> 'ON ACCT'  
  GROUP BY CustId, InvcNum  
  UPDATE #AgeInvoiceListBySite  
  SET AlpSiteName = CASE WHEN alpS.AlpFirstName is null THEN alpS.SiteName  
   WHEN alpS.AlpFirstName = '' THEN alpS.SiteName  
   WHEN alpS.AlpFirstName = ' ' THEN alpS.SiteName  
   ELSE alpS.SiteName + ', ' + alpS.AlpFirstName  
  END,   
  --alpS.SiteName,   
  AlpSiteAddr1 = alpS.Addr1, AlpSiteAddr2 = alpS.Addr2  
  FROM #AgeInvoiceListBySite BySite INNER JOIN dbo.ALP_tblArAlpSite alpS on  BySite.AlpSiteID = alpS.SiteId    
    
 --issue an aging of the identified invoices      
 INSERT INTO #InvoiceAging      
 EXEC dbo.trav_ArInvoiceAging_proc @StatementDate, @InvcFinch, 1      
   

      
 --populate the customer summary with any open invoice customers      
 -- use aged balances for open invoice customers      
 --  capture the YTD finance charges from history      
 INSERT INTO #CustomerSummary (CustId, AcctType, YTDFinch, UnpaidFinch      
  , AmtCurrent, AmtDue1, AmtDue2, AmtDue3, AmtDue4, UnappliedCredit, PostalCode,GroupCode)     
 SELECT l.CustId, AcctType, 0, ISNULL(c.NewFinch, 0) + ISNULL(b.UnpaidFinch, 0)       
  , ISNULL(b.AmtCurrent, 0), ISNULL(b.AmtDue1, 0), ISNULL(b.AmtDue2, 0)      
  , ISNULL(b.AmtDue3, 0), ISNULL(b.AmtDue4, 0), ISNULL(b.UnappliedCredit, 0)  
  --mah 06/13/14 - added postal code and group code properties  
  ,ISNULL(c.PostalCode,' ' ) , ISNULL(c.GroupCode,' ')        
 FROM #CustomerList l      
 INNER JOIN dbo.tblArCust c ON l.CustId = c.CustId      
 LEFT JOIN (SELECT CustId, SUM(UnappliedCredit) UnappliedCredit      
  , SUM(UnpaidFinch) UnpaidFinch, SUM(AmtCurrent) AmtCurrent      
  , SUM(AmtDue1) AmtDue1, SUM(AmtDue2) AmtDue2, SUM(AmtDue3) AmtDue3, SUM(AmtDue4) AmtDue4      
  FROM #InvoiceAging      
  GROUP BY CustId) b ON l.CustId = b.CustId      
 WHERE c.AcctType = 0      
  AND (c.StmtInvcCode = 1 OR c.StmtInvcCode = 3)      
      
 --   --MAH ADDED FOR TESTIN     
 --select * from #CustomerSummary  
     
 --===================      
 --All customers types      
 --===================      
 --capture the invoice activity for all customers      
 -- exclude gain/loss entries - cutoff date doesn't apply to balance forward customers     
     
 --mah:  modified to include Alp fields:   
    
 --begin mod:     
 --INSERT INTO #InvoiceActivity ([Counter], CustId, CurrencyId      
 -- , InvcNum, TransDate, RecType, CheckNum, Charges, Credits, AmountDue, GroupType)      
 --SELECT i.[Counter], i.CustId, i.CurrencyId      
 -- , i.InvcNum, i.TransDate, i.RecType      
 -- , CASE WHEN i.Rectype = 1 OR i.Rectype = -1 THEN i.CustPONum ELSE CheckNum END AS CheckNum      
 -- , CASE WHEN i.RecType > 0 THEN AmtFgn ELSE 0 END AS Charges      
 -- , CASE WHEN i.RecType < 0 THEN AmtFgn ELSE 0 END AS Credits      
 -- , SIGN(i.RecType) * AmtFgn AS AmountDue, 0      
 --FROM #CustomerList l      
 --INNER JOIN dbo.tblArOpenInvoice i ON l.CustId = i.CustId      
 --INNER JOIN dbo.tblArCust c ON i.CustId = c.CustId       
 --WHERE ((i.TransDate <= @CutoffDate AND c.AcctType = 0) OR c.AcctType = 1)       
 -- AND i.[Status] = 0 AND i.Rectype <> -3 --exclude gain/loss invoices      
 -- AND (c.StmtInvcCode = 1 OR c.StmtInvcCode = 3) AND i.RecType <> 5 --Exclude pro forma invoice      
 --UNION ALL      
 --SELECT i.[Counter], i.CustId, i.CurrencyId      
 -- , i.InvcNum, i.TransDate, i.RecType      
 -- , CASE WHEN i.AmtFgn > 0 THEN i.CustPONum ELSE CheckNum END AS CheckNum      
 -- , CASE WHEN i.AmtFgn > 0 THEN AmtFgn ELSE 0 END AS Charges      
 -- , CASE WHEN i.AmtFgn < 0 THEN -AmtFgn ELSE 0 END AS Credits      
 -- , AmtFgn AS AmountDue, 1      
 --FROM #CustomerList l      
 --INNER JOIN dbo.tblArOpenInvoice i ON l.CustId = i.CustId      
 --INNER JOIN dbo.tblArCust c ON i.CustId = c.CustId       
 --WHERE ((i.TransDate <= @CutoffDate AND c.AcctType = 0) OR c.AcctType = 1)       
 -- AND i.[Status] = 0 AND i.Rectype = 5 --Only pro forma invoice      
 -- AND (c.StmtInvcCode = 1 OR c.StmtInvcCode = 3)     
     
  INSERT INTO #InvoiceActivity ([Counter], CustId, CurrencyId      
  , InvcNum, TransDate, RecType, CheckNum, Charges, Credits, AmountDue, GroupType    
  , AlpSiteId, AlpSiteName, AlpSiteAddr1, AlpSiteAddr2,AlpGroupTypeTxt, TransID)      
 SELECT i.[Counter], i.CustId, i.CurrencyId      
  , i.InvcNum, i.TransDate, i.RecType      
  , CASE WHEN i.Rectype = 1 OR i.Rectype = -1 THEN i.CustPONum ELSE CheckNum END AS CheckNum      
  , CASE WHEN i.RecType > 0 THEN AmtFgn ELSE 0 END AS Charges      
  , CASE WHEN i.RecType < 0 THEN AmtFgn ELSE 0 END AS Credits      
  , SIGN(i.RecType) * AmtFgn AS AmountDue, 0  
  --MAH 11/18/14:    
  --, alpO.AlpSiteId  
  ,BySite.AlpSiteId  
  --MAH 11/19/14:  
  ,BySite.AlpSiteName  
  ,BySite.AlpSiteAddr1, BySite.AlpSiteAddr2  
  --, CASE WHEN alpS.AlpFirstName is null THEN alpS.SiteName  
  -- WHEN alpS.AlpFirstName = '' THEN alpS.SiteName  
  -- WHEN alpS.AlpFirstName = ' ' THEN alpS.SiteName  
  -- ELSE alpS.SiteName + ', ' + alpS.AlpFirstName  
  --END  
  --, alpS.Addr1, alpS.Addr2  
  , CASE WHEN i.RecType > 0 THEN 'INVOICE'   
   WHEN i.RecType = -1 THEN 'CREDIT'  
   WHEN i.RecType = -2 THEN 'PAYMENT'  
   ELSE 'CREDIT'  
   END
   --mah 01/25/15:
   , i.TransId    
 FROM #CustomerList l      
   INNER JOIN dbo.tblArOpenInvoice i ON l.CustId = i.CustId    
   INNER JOIN dbo.tblArCust c ON i.CustId = c.CustId    
   ---MAH 11/18/14:  
   LEFT OUTER JOIN #AgeInvoiceListBySite BySite on i.CustId = BySite.CustId  and i.InvcNum = BySite.InvcNum  
   LEFT OUTER JOIN dbo.ALP_tblArOpenInvoice alpO on i.[Counter] = alpO.[AlpCounter]  
   --MAH 11/18/14:      
   --LEFT OUTER JOIN dbo.ALP_tblArAlpSite alpS on  alpO.AlpSiteID = alpS.SiteId    
   LEFT OUTER JOIN dbo.ALP_tblArAlpSite alpS on  BySite.AlpSiteID = alpS.SiteId      
 WHERE ((i.TransDate <= @CutoffDate AND c.AcctType = 0) OR c.AcctType = 1)       
  AND i.[Status] = 0 AND i.Rectype <> -3 --exclude gain/loss invoices      
  AND (c.StmtInvcCode = 1 OR c.StmtInvcCode = 3) AND i.RecType <> 5 --Exclude pro forma invoice   
       
 UNION ALL      
 SELECT i.[Counter], i.CustId, i.CurrencyId      
  , i.InvcNum, i.TransDate, i.RecType      
  , CASE WHEN i.AmtFgn > 0 THEN i.CustPONum ELSE CheckNum END AS CheckNum      
  , CASE WHEN i.AmtFgn > 0 THEN AmtFgn ELSE 0 END AS Charges      
  , CASE WHEN i.AmtFgn < 0 THEN -AmtFgn ELSE 0 END AS Credits      
  , AmtFgn AS AmountDue, 1     
  , BySite.AlpSiteId  
    --MAH 11/19/14:  
  ,BySite.AlpSiteName  
  ,BySite.AlpSiteAddr1, BySite.AlpSiteAddr2  
  --, CASE WHEN alpS.AlpFirstName is null THEN alpS.SiteName  
  -- WHEN alpS.AlpFirstName = '' THEN alpS.SiteName  
  -- WHEN alpS.AlpFirstName = ' ' THEN alpS.SiteName  
  -- ELSE alpS.SiteName + ', ' + alpS.AlpFirstName  
  --END  
  --, alpS.Addr1, alpS.Addr2   
  , CASE WHEN i.RecType > 0 THEN 'INVOICE'   
   WHEN i.RecType = -1 THEN 'CREDIT'  
   WHEN i.RecType = -2 THEN 'PAYMENT'  
   ELSE 'CREDIT'  
   END 
    --mah 01/25/15:
   , i.TransId         
 FROM #CustomerList l      
   INNER JOIN dbo.tblArOpenInvoice i ON l.CustId = i.CustId     
   INNER JOIN dbo.tblArCust c ON i.CustId = c.CustId    
      ---MAH 11/18/14:  
   LEFT OUTER JOIN #AgeInvoiceListBySite BySite on i.CustId = BySite.CustId  and i.InvcNum = BySite.InvcNum   
   LEFT OUTER JOIN dbo.ALP_tblArOpenInvoice alpO on i.[Counter] = alpO.[AlpCounter]   
      --MAH 11/18/14:      
   --LEFT OUTER JOIN dbo.ALP_tblArAlpSite alpS on  alpO.AlpSiteID = alpS.SiteId    
   LEFT OUTER JOIN dbo.ALP_tblArAlpSite alpS on  BySite.AlpSiteID = alpS.SiteId         
      
 WHERE ((i.TransDate <= @CutoffDate AND c.AcctType = 0) OR c.AcctType = 1)       
  AND i.[Status] = 0 AND i.Rectype = 5 --Only pro forma invoice      
  AND (c.StmtInvcCode = 1 OR c.StmtInvcCode = 3)      
 --end mod     
   
   
 --  --MAH ADDED FOR TESTIN     
 --select * from #InvoiceActivity  
   
      
 --lookup the fiscal year and period based upon the cutoff date      
 DECLARE @FiscalYear smallint, @FiscalPeriod smallint      
      
 SELECT @FiscalYear = GlYear, @FiscalPeriod = GlPeriod      
 FROM dbo.tblSmPeriodConversion       
 WHERE @CutoffDate BETWEEN BegDate AND EndDate      
      
 --  capture the YTD finance charges from history      
 UPDATE #CustomerSummary SET YTDFinch = ISNULL(finch.YTDFinch, 0)      
 FROM (SELECT f.CustId, SUM(f.FinchAmtFgn) YTDFinch       
  FROM dbo.tblArHistFinch f      
  WHERE f.FiscalYear = @FiscalYear AND f.GlPeriod <= @FiscalPeriod      
  GROUP BY f.CustId) finch      
 WHERE #CustomerSummary.CustId = finch.CustId      
      
   --FOR TESTING!!
    -- --MAH ADDED FOR TESTING - TO BE COMMENTED OUT!
    select 'OpenInvoiceView', * from ALP_tblArOpenInvoice_view O inner join #CustomerList C ON O.CustID = C.CustId order by InvcNum
 select '#AgeInvoiceList',* from #AgeInvoiceList order by InvcNum
 select '#AgeInvoiceListBySite',* from #AgeInvoiceListBySite    
 select '#InvoiceAging',* from #InvoiceAging
 select '#CustomerSummary',* from #CustomerSummary   
 select '#Invoice activity',* from #InvoiceActivity order by InvcNUm  
 --==============      
 --return results - Table0     
 --==============       
      
 --retrieve the customer balance resultset      
 SELECT @StatementDate AS StatementDate, @ClosingDate AS ClosingDate, @CutoffDate AS CutoffDate      
  , c.CustId, c.CurrencyId  
  --mah use AlpCustFullName instead of just traverse CustName  
  , CASE WHEN ac.AlpCommYn = 1 THEN c.CustName  
  ELSE  
   CASE WHEN ac.AlpFirstName is null THEN c.CustName   
   ELSE ac.AlpFirstName + ' ' + c.CustName  END  
  END  
  AS CustName  
  --, c.CustName  
  , c.Attn, c.Addr1, c.Addr2, c.City, c.Region, c.PostalCode, c.Country      
  , c.TaxExemptId, (c.CreditLimit - c.CurAmtDue) AS RemainingCredit      
  , c.CalcFinch, s.YTDFinch, c.NewFinch, s.UnpaidFinch AS Finch      
  , (s.AmtCurrent + s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4 + s.UnpaidFinch - s.UnappliedCredit) AS TotalAmountDue      
  , (s.AmtCurrent - s.UnappliedCredit) AS CurrentAmountDue      
  , s.AmtDue1 AS Balance31To60      
  , s.AmtDue2 AS Balance61To90      
  , (s.AmtDue3 + s.AmtDue4) AS BalanceOver90   
   --mah 06/13/14 - made terms description appear as 'Easy Pay' for Credit Card and ACH customers,    
 -- , t.[Desc] AS [Description]   
  , CASE WHEN s.GroupCode = 'A' THEN 'Easy Pay'  
   WHEN s.GroupCode = 'C' THEN 'Easy Pay'  
   ELSE t.[Desc]  
   END AS [Description]     
  , CAST(CASE WHEN (s.AmtDue3 + s.AmtDue4) > 0 THEN 3        
   ELSE CASE WHEN s.AmtDue2 > 0 THEN 2      
    ELSE CASE WHEN s.AmtDue1 > 0 THEN 1      
     ELSE 0 END      
    END      
   END AS tinyint) AS OldestBalanceId   
   --mah 06/13/14 - added Group Code, GCComment, and field to allow main sort by Postal Code, rather than CustID  
   , s.GroupCode  
   , acomm.GCStmtComment  
   , CASE WHEN s.GroupCode = 'A' THEN 'DEBIT NOTICE'  
    WHEN s.GroupCode = 'C' THEN 'DEBIT NOTICE'  
    ELSE 'STATEMENT' END AS AlpDocHeading  
 , @CompanyName AS AlpCompanyName  
 , acomm.CloseDateComment  
     
 FROM #CustomerSummary s      
 INNER JOIN dbo.tblArCust c ON s.CustId = c.CustId   
 INNER JOIN dbo.ALP_tblArCust ac ON s.CustId = ac.AlpCustId     
 LEFT JOIN dbo.tblArTermsCode t ON c.TermsCode = t.TermsCode    
 LEFT JOIN dbo.ALP_tblArAlpStmtComment acomm ON c.GroupCode = acomm.GroupCode      
 WHERE (@PrintStatements = 0)       
  OR (@PrintStatements = 1 AND EXISTS(SELECT * FROM #InvoiceActivity a WHERE a.CustId = s.CustId))       
  OR (@PrintStatements = 2 AND (s.AmtCurrent + s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4 + s.UnpaidFinch - s.UnappliedCredit) <> 0)       
  OR (@PrintStatements = 3 AND (s.AmtCurrent + s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4 + s.UnpaidFinch - s.UnappliedCredit) > 0)       
  OR (@PrintStatements = 4 AND (s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4) > 0)       
  OR (@PrintStatements = 5 AND (s.AmtDue2 + s.AmtDue3 + s.AmtDue4) > 0)       
  OR (@PrintStatements = 6 AND (s.AmtDue3 + s.AmtDue4) > 0)       
 --MAH   
  ORDER BY c.PostalCode, c.CustId  
 --CASE WHEN @InvoiceSort = 0 THEN c.CustId  
 -- WHEN @InvoiceSort = 1 THEN c.CustId  
 -- WHEN @InvoiceSort = 2 THEN c.PostalCode  
 -- ELSE  c.CustId  
 -- END,  
 --c.CustId   
  
  --Table1 - Invoice and Payment Details    
 --retrieve the invoice detail - This is the UNION of the Invoice details plus the Payment details     
 SELECT 'invoiceDETAIL', i.CustId, i.TransDate AS InvoiceDate, i.InvcNum AS InvoiceNo, i.RecType      
  , i.CheckNum AS CheckNo, i.Charges  
  --, i.Credits  
  , 0 AS Credits   
  ,i.Charges - 0 AS Balance      
  --, CASE WHEN @InvoiceSort = 0 THEN i.InvcNum ELSE CONVERT(nvarchar, i.TransDate, 112) END AS GrpId     
  , CASE WHEN @InvoiceSort = 0 THEN i.InvcNum   
  WHEN @InvoiceSort = 1 THEN CONVERT(nvarchar, i.TransDate, 112)   
  ELSE CONVERT(varchar(8),i.AlpSiteId) END AS GrpId    
  , t.InvoiceCount, i.GroupType      
  --mah:  insert invoice details and site info below.  NOTE!  All detail amount fields must be cast  as varchar, rather than sending back decimal values  
 , i.AlpGroupTypeTxt  
   , CAST(CAST(h.TaxSubTotal AS DECIMAL(12,2)) AS varchar) AS TaxSubTotal  
 , CAST(CAST(h.NonTaxSubTotal AS DECIMAL(12,2)) AS varchar)   AS NonTaxSubTotal  
 , CAST(CAST(h.SalesTax AS DECIMAL(12,2))  AS varchar)  AS SalesTax  
 , CAST(CAST(h.Freight AS DECIMAL(12,2))  AS varchar)  AS Freight  
 , CAST(CAST(h.Misc AS DECIMAL(12,2))  AS varchar)   AS Misc  
 , CAST(CAST((h.TaxSubTotal + h.NonTaxSubTotal) AS DECIMAL(12,2)) AS varchar) AS Items   
 , i.AlpSiteId, i.AlpSiteName, i.AlpSiteAddr1, i.AlpSiteAddr2,   
 CASE WHEN i.AlpSiteAddr1 is null  
   THEN i.AlpSiteAddr2   
   ELSE CASE WHEN i.AlpSiteAddr2 IS NULL THEN i.AlpSiteAddr1  
      ELSE i.AlpSiteAddr1 + ', ' + i.AlpSiteAddr2  
    END  
 END AS AlpSiteAddrFull  
 , s.PostalCode    
 , d.PartId, d.[Desc]  
 , CONVERT(varchar(2000), d.AddnlDesc) as AddnlDesc   
 , CAST(CAST(ROUND(d.QtyShipSell * d.UnitPriceSell,2) AS DECIMAL(12,2)) AS varchar) AS ExtPrice  
 , h.TransId  
 , d.EntryNum  
 , t.AmountDue AS AlpInvcBalance  
  --end of mah additions  
 FROM #CustomerSummary s      
 INNER JOIN #InvoiceActivity i ON s.CustId = i.CustId   
     --mah 06/13/14 - added details of the transaction  
        INNER JOIN dbo.tblArHistHeader h ON i.InvcNum = h.InvcNum  
        --mah 01/25/15:
        AND i.TransID = h.TransId
    AND  i.CustId = h.CustId  
  INNER JOIN dbo.tblArHistDetail d ON h.TransId = d.TransId      
 INNER JOIN (SELECT a.CustId, a.InvcNum, a.GroupType, COUNT(1) AS InvoiceCount, SUM(a.AmountDue) AS AmountDue      
     FROM #InvoiceActivity a      
     GROUP BY a.CustId, a.InvcNum, a.GroupType) t      
  ON i.CustId = t.CustId AND i.InvcNum = t.InvcNum AND i.GroupType = t.GroupType      
  --mah modified the where clause, to pull transactions only for the Invoice type records  
  --WHERE (@PrintStatements = 0)   
 WHERE (i.RecType > 0)  AND t.AmountDue <> 0  
 AND ((@PrintStatements = 0)       
  OR (@PrintStatements = 1 AND EXISTS(SELECT * FROM #InvoiceActivity a WHERE a.CustId = s.CustId))       
  OR (@PrintStatements = 2 AND (s.AmtCurrent + s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4 + s.UnpaidFinch - s.UnappliedCredit) <> 0)       
  OR (@PrintStatements = 3 AND (s.AmtCurrent + s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4 + s.UnpaidFinch - s.UnappliedCredit) > 0)       
  OR (@PrintStatements = 4 AND (s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4) > 0)       
  OR (@PrintStatements = 5 AND (s.AmtDue2 + s.AmtDue3 + s.AmtDue4) > 0)       
  OR (@PrintStatements = 6 AND (s.AmtDue3 + s.AmtDue4) > 0))  
    
  UNION  
  --get the Payment details  
  SELECT 'pAYMENT DETAIL', i.CustId, i.TransDate AS InvoiceDate, i.InvcNum AS InvoiceNo, i.RecType      
  , CASE WHEN i.CheckNum IS NULL THEN '' 
		WHEN i.CheckNum <> '' THEN 'Ck# ' + i.CheckNum 
		ELSE '' END AS CheckNo  
  , 0 AS Charges  
  , (-1 * i.Credits) AS Credits, 0 - i.Credits AS Balance      
  --, CASE WHEN @InvoiceSort = 0 THEN i.InvcNum ELSE CONVERT(nvarchar, i.TransDate, 112) END AS GrpId     
  , CASE WHEN @InvoiceSort = 0 THEN i.InvcNum   
  WHEN @InvoiceSort = 1 THEN CONVERT(nvarchar, i.TransDate, 112)   
  ELSE CONVERT(varchar(8),i.AlpSiteId) END AS GrpId    
  , t.InvoiceCount, i.GroupType      
  --mah:  insert invoice details and site info below  
 , i.AlpGroupTypeTxt  
   , '' as TaxSubTotal  
 , '' as NonTaxSubTotal   
 , '' as SalesTax  
 , '' as Freight  
 , '' as Misc   
 , '' as Items   
 , i.AlpSiteId, i.AlpSiteName, i.AlpSiteAddr1, i.AlpSiteAddr2,   
 CASE WHEN i.AlpSiteAddr1 is null  
   THEN i.AlpSiteAddr2   
   ELSE CASE WHEN i.AlpSiteAddr2 IS NULL THEN i.AlpSiteAddr1  
      ELSE i.AlpSiteAddr1 + ', ' + i.AlpSiteAddr2  
    END  
 END AS AlpSiteAddrFull  
 , s.PostalCode 

 --mah 01/25/15:  changed PartID, Desc, AddtlDesc    
 --, '' AS PartId, '' AS [Desc]  
 --, '' AS AddnlDesc   
 , CASE WHEN d.PartId IS NULL THEN ''  ELSE d.PartId END
 , CASE WHEN d.[Desc] IS NULL THEN ''  ELSE d.[Desc] END 
 , CASE WHEN d.AddnlDesc IS NULL THEN '' ELSE CONVERT(varchar(2000), d.AddnlDesc) END as AddnlDesc 
 , '' AS ExtPrice  
 , h.TransId  
 , '' AS EntryNum  
 , t.AmountDue AS AlpInvcBalance  
  --end of mah additions  
 FROM #CustomerSummary s      
 INNER JOIN #InvoiceActivity i ON s.CustId = i.CustId   
	--mah 07/14/14 - changed this to left outer join  
        LEFT OUTER JOIN dbo.tblArHistHeader h ON i.InvcNum = h.InvcNum  
			AND  i.CustId = h.CustId  
    --mah 01/25/15:
			AND i.TransID = h.TransId
			LEFT OUTER JOIN dbo.tblArHistDetail d ON h.TransId = d.TransId   
 INNER JOIN (SELECT a.CustId, a.InvcNum, a.GroupType, COUNT(1) AS InvoiceCount , SUM(a.AmountDue) AS AmountDue     
     FROM #InvoiceActivity a      
     GROUP BY a.CustId, a.InvcNum, a.GroupType) t      
  ON i.CustId = t.CustId AND i.InvcNum = t.InvcNum AND i.GroupType = t.GroupType      
 --WHERE (@PrintStatements = 0)  
 --mah modified the where clause, to pull invoice details only where invcBalance <> 0   
 WHERE (i.RecType <= 0) AND t.AmountDue <> 0  
 AND ((@PrintStatements = 0)        
  OR (@PrintStatements = 1 AND EXISTS(SELECT * FROM #InvoiceActivity a WHERE a.CustId = s.CustId))       
  OR (@PrintStatements = 2 AND (s.AmtCurrent + s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4 + s.UnpaidFinch - s.UnappliedCredit) <> 0)       
  OR (@PrintStatements = 3 AND (s.AmtCurrent + s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4 + s.UnpaidFinch - s.UnappliedCredit) > 0)       
  OR (@PrintStatements = 4 AND (s.AmtDue1 + s.AmtDue2 + s.AmtDue3 + s.AmtDue4) > 0)       
  OR (@PrintStatements = 5 AND (s.AmtDue2 + s.AmtDue3 + s.AmtDue4) > 0)       
  OR (@PrintStatements = 6 AND (s.AmtDue3 + s.AmtDue4) > 0) )  
    
 --ORDER BY i.CustId, CASE WHEN @InvoiceSort = 0 THEN i.InvcNum ELSE CONVERT(nvarchar, i.TransDate, 112) END   
 --MAH changed sort order options  
 ORDER BY  s.PostalCode,i.CustId,i.AlpSiteId, InvoiceNo   
  --CASE WHEN @InvoiceSort = 0 THEN i.CustId  
  --WHEN @InvoiceSort = 1 THEN i.CustId  
  --WHEN @InvoiceSort = 2 THEN s.PostalCode  
  --ELSE  i.CustId  
  --END   
 --,CASE WHEN @InvoiceSort = 0 THEN CONVERT(nvarchar(15),i.InvcNum)  
 -- WHEN @InvoiceSort = 1 THEN CONVERT(varchar(10), i.TransDate, 112)  
 -- WHEN @InvoiceSort = 2 THEN s.CustId  
 -- ELSE CONVERT(nvarchar(8),i.AlpSiteId)  
 -- END  
 --,CASE WHEN @InvoiceSort = 0 THEN CONVERT(nvarchar(15),i.InvcNum)  
 -- WHEN @InvoiceSort = 1 THEN CONVERT(varchar(10), i.TransDate, 112)  
 -- WHEN @InvoiceSort = 2 THEN CONVERT(nvarchar(8),i.AlpSiteId)  
 -- ELSE CONVERT(nvarchar(15),i.InvcNum)  
 -- END  
 --,EntryNum  
            
END TRY      
BEGIN CATCH      
 EXEC dbo.trav_RaiseError_proc      
END CATCH