  
    
CREATE PROCEDURE [dbo].[trav_ArInvoiceAging_proc_MAHTEST]    
@AgingDate datetime, --base date for the aging dates    
@InvcFinch pInvoiceNum, --Finance charge invoice number    
@AgeUnappliedCredits bit = 0 --option to age unapplied payments    
AS    
SET NOCOUNT ON    
BEGIN TRY    
--MOD:Finance Charge Enhancements    
    
 DECLARE @Day1 datetime, @Day2 datetime, @Day3 datetime, @Day4 datetime    
 DECLARE @MaxInvcAgingDate datetime, @MaxPmtAgingDate datetime   
 DECLARE @CustId varchar(10)
 SET @CustId = '110624'  
    
 --expects the list of invoices to age to be provided via the #AgeInvoiceList table    
 --CREATE TABLE #AgeInvoiceList     
 --(    
 -- CustId pCustId, InvcNum pInvoiceNum, RecType smallint, AgingDate datetime, AmountDue pDec default(0)    
 --)     
    
 CREATE TABLE #InvoiceAgingBuckets    
 (    
  CustId pCustId,     
  InvcNum pInvoiceNum,     
  MinAgingDate datetime NULL,     
  MaxRecType smallint,     
  UnappliedCredit pDec DEFAULT(0),     
  UnpaidFinch pDec DEFAULT(0),    
  AmtCurrent pDec DEFAULT(0),     
  AmtDue1 pDec DEFAULT(0),     
  AmtDue2 pDec DEFAULT(0),     
  AmtDue3 pDec DEFAULT(0),     
  AmtDue4 pDec DEFAULT(0),     
  PRIMARY KEY (CustId, InvcNum)    
 )    
 --mah insert:  
  --setup a temp table for the invoices to age      
 CREATE TABLE #AgeInvoiceList       
 (      
  CustId pCustId,       
  InvcNum varchar(15),       
  RecType smallint,       
  AgingDate datetime,       
  AmountDue pDec default(0)     
    -- mah:  add site info here     
   ,AlpSiteId integer,    
   AlpSiteName varchar(80),    
   AlpSiteAddr1 varchar(40),    
   AlpSiteAddr2 varchar(60),       
 )    
  ----mah: section below is ONLY for testing the resultset.  TO BE REMOVED!    
 CREATE TABLE #CustomerList (CustId pCustId, PRIMARY KEY (CustId))   
    
 INSERT INTO #CustomerList (CustId) SELECT CustID from dbo.tblArCust where CustID = @CustID    
        
 INSERT INTO #AgeInvoiceList (CustId, InvcNum, RecType, AgingDate, AmountDue    
  , AlpSiteId, AlpSiteName, AlpSiteAddr1, AlpSiteAddr2)      
  SELECT i.CustId, i.InvcNum, i.RecType, i.TransDate, i.AmtFgn      
  ,alpO.AlpSiteId, alpS.SiteName, alpS.Addr1, alpS.Addr2    
   FROM #CustomerList l      
  INNER JOIN dbo.tblArOpenInvoice i on l.CustId = i.CustId    
  INNER JOIN dbo.tblArCust c ON l.CustId = c.CustId     
  LEFT OUTER JOIN dbo.ALP_tblArOpenInvoice alpO on i.[Counter] = alpO.[AlpCounter]      
  LEFT OUTER JOIN dbo.ALP_tblArAlpSite alpS on  alpO.AlpSiteID = alpS.SiteId    
  WHERE c.AcctType = 0 --AND i.TransDate <= @CutoffDate   
 AND i.[Status] <> 1      
   AND (c.StmtInvcCode = 1 OR c.StmtInvcCode = 3) AND i.RecType <> 5 --Exclude pro forma invoice    
 
 
 SELECT i.CustId, i.InvcNum, i.RecType, i.TransDate, i.AmtFgn      
  ,alpO.AlpSiteId, alpS.SiteName, alpS.Addr1, alpS.Addr2    
   FROM #CustomerList l      
  INNER JOIN dbo.tblArOpenInvoice i on l.CustId = i.CustId    
  INNER JOIN dbo.tblArCust c ON l.CustId = c.CustId     
  LEFT OUTER JOIN dbo.ALP_tblArOpenInvoice alpO on i.[Counter] = alpO.[AlpCounter]      
  LEFT OUTER JOIN dbo.ALP_tblArAlpSite alpS on  alpO.AlpSiteID = alpS.SiteId    
  WHERE c.AcctType = 0 --AND i.TransDate <= @CutoffDate   
 AND i.[Status] <> 1      
   AND (c.StmtInvcCode = 1 OR c.StmtInvcCode = 3) AND i.RecType <> 5 --Exclude pro forma invoice 
   ORDER BY i.InvcNum, i.TransDate
    
 select * from   dbo.tblArOpenInvoice where custID = @CustID order by invcnum  
 select * from #AgeInvoiceList order by InvcNum  
    
 --Set each aging dates based upon the initial aging date    
 SELECT @Day1 = DATEADD(DAY, -30, @AgingDate)    
  , @Day2 = DATEADD(DAY, -60, @AgingDate)    
  , @Day3 = DATEADD(DAY, -90, @AgingDate)    
  , @Day4 = DATEADD(DAY, -120, @AgingDate)    
    
    
 --initialize the list of aged values for invoices with an outstanding balance    
 INSERT INTO #InvoiceAgingBuckets (CustId, InvcNum)     
 SELECT CustId, InvcNum     
 FROM #AgeInvoiceList     
 GROUP BY CustId, InvcNum    
 HAVING SUM(SIGN(RecType) * AmountDue) <> 0    
    
 select * from #InvoiceAgingBuckets  
   
  SELECT CustId, InvcNum     
 FROM #AgeInvoiceList     
 GROUP BY CustId, InvcNum    
 HAVING SUM(SIGN(RecType) * AmountDue) <> 0   
    
 --capture the max invoice and payment dates for calculating the MinAgingDates    
 SELECT @MaxInvcAgingDate = MAX(AgingDate) FROM #AgeInvoiceList WHERE RecType > 0 AND NOT(AgingDate IS NULL)    
 SELECT @MaxPmtAgingDate = MAX(AgingDate) FROM #AgeInvoiceList WHERE RecType < 0 AND NOT(AgingDate IS NULL)    
 SELECT @MaxInvcAgingDate = COALESCE(@MaxInvcAgingDate, GETDATE()), @MaxPmtAgingDate = COALESCE(@MaxPmtAgingDate, GETDATE())    
    
    
 --process invoices/payments by Min aging date and max rec typ so that over payments on invoices are aged with the invoice    
 UPDATE #InvoiceAgingBuckets     
  SET MinAgingDate = m.MinAgingDate, MaxRecType = m.MaxRecType    
  FROM #InvoiceAgingBuckets     
  INNER JOIN (SELECT CustId, InvcNum, Max(RecType) MaxRecType, CASE WHEN Max(RecType) > 0 THEN Min(InvcDate) ELSE Min(PmtDate) END MinAgingDate    
    FROM (SELECT CustId, InvcNum, ISNULL(RecType, 1) RecType    
      , CASE WHEN ISNULL(RecType, 1) > 0 THEN AgingDate ELSE @MaxInvcAgingDate END InvcDate    
      , Case When ISNULL(RecType, 1) < 0 THEN AgingDate ELSE @MaxPmtAgingDate END PmtDate    
      FROM #AgeInvoiceList) d GROUP BY CustId, InvcNum) m    
  ON #InvoiceAgingBuckets.CustId = m.CustId AND #InvoiceAgingBuckets.InvcNum = m.InvcNum    
    
    
 --separate amounts into aging buckets    
 UPDATE #InvoiceAgingBuckets    
  SET UnappliedCredit = ISNULL(s.UnappliedCredit, 0), UnpaidFinch = ISNULL(s.UnpaidFinch, 0), AmtCurrent = ISNULL(s.AmtCurrent, 0)    
   , AmtDue1 = ISNULL(s.AmtDue1, 0), AmtDue2 = ISNULL(s.AmtDue2, 0), AmtDue3 = ISNULL(s.AmtDue3, 0), AmtDue4 = ISNULL(s.AmtDue4, 0)    
  FROM #InvoiceAgingBuckets 
	INNER JOIN (SELECT i.CustId, i.InvcNum    
   , SUM(CASE WHEN i.MaxRecType = 4 THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) UnpaidFinch    
   , SUM(CASE WHEN (i.maxrectype < 0 AND @AgeUnappliedCredits <> 1) THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) UnappliedCredit    
   , SUM(CASE WHEN (i.maxrectype > 0 OR @AgeUnappliedCredits = 1) AND i.MaxRecType <> 4 AND i.MinAgingDate >= @Day1 THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) AmtCurrent    
   , SUM(CASE WHEN (i.maxrectype > 0 OR @AgeUnappliedCredits = 1) AND i.MaxRecType <> 4 AND i.MinAgingDate BETWEEN @Day2 AND DateAdd(Day, -1, @Day1) THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) AmtDue1    
   , SUM(CASE WHEN (i.maxrectype > 0 OR @AgeUnappliedCredits = 1) AND i.MaxRecType <> 4 AND i.MinAgingDate BETWEEN @Day3 AND DateAdd(Day, -1, @Day2) THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) AmtDue2    
   , SUM(CASE WHEN (i.maxrectype > 0 OR @AgeUnappliedCredits = 1) AND i.MaxRecType <> 4 AND i.MinAgingDate BETWEEN @Day4 AND DateAdd(Day, -1, @Day3) THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) AmtDue3    
   , SUM(CASE WHEN (i.maxrectype > 0 OR @AgeUnappliedCredits = 1) AND i.MaxRecType <> 4 AND i.MinAgingDate < @Day4  THEN SIGN(o.RecType) * o.AmountDue ELSE 0 END) AmtDue4    
   FROM #InvoiceAgingBuckets i INNER JOIN #AgeInvoiceList o ON i.CustId = o.CustId AND i.InvcNum = o.InvcNum    
   GROUP BY i.CustId, i.InvcNum) s    
  ON #InvoiceAgingBuckets.CustId = s.CustId AND #InvoiceAgingBuckets.InvcNum = s.InvcNum    
    
    
 --return the aged balances by customer and invoice number    
 SELECT CustId, InvcNum    
  , ISNULL(UnappliedCredit, 0) UnappliedCredit    
  , ISNULL(UnpaidFinch, 0) UpaidFinch    
  , ISNULL(AmtCurrent, 0) AmtCurrent     
  , ISNULL(AmtDue1, 0) AmtDue1    
  , ISNULL(AmtDue2, 0) AmtDue2    
  , ISNULL(AmtDue3, 0) AmtDue3    
  , ISNULL(AmtDue4, 0) AmtDue4    
  FROM #InvoiceAgingBuckets     
    
    
END TRY    
BEGIN CATCH    
 EXEC dbo.trav_RaiseError_proc    
END CATCH