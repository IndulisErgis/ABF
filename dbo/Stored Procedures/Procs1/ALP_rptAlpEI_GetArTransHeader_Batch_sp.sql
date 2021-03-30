CREATE Procedure [dbo].[ALP_rptAlpEI_GetArTransHeader_Batch_sp]              
 @CompID pCompID,  --EFI# 1890 SUDHARSON 09/29/2010 - Added to show the Company Logo              
 @CboBase bit = 0  --EFI# 1890 SUDHARSON 10/28/2010 - Added to show in Base Currency              
As              
Begin              
SET NOCOUNT ON              
              
--MAH 06/20/11 - changed logic to force it to ignore multi-currency for now.              
--   ( i.e. always use base amounts, rather than foreign amounts)              
--   This is a temporary change until the insertion of foreign amounts               
--   in all transactions is verified.  Did this by adding following statement,               
--   which forces @cboBase to be 1.               
--MAH 08/29/11- corrected Union logic;  added HistPmt source of credits   
--RAVI 02/10/2015 - New External procedure (Alp_rptAlpEI_GetArTransHeader_BatchTotal_sp) called for batch invoice total on the bottom.           
--MAH 02/21/15 - format cust and site postalcode
--DMM 04/05/2017 - added BatchId to the return set fro use by email status popup window
--MAH 05/05/17 - modified to increase Alpine userID length of 50 from 20

SET @cbobase = 1 --To be removed once fgn fields in all transactions are correctlt populated   
  
         
              
declare @UserID varchar(50), @WrkStnId pWrkStnId              
exec alp_currentuser @UserId out, @WrkStnId out              
              
              
select CustID, A.InvcNum, TransId as TransID2 into #temp1 from               
(SELECT   distinct h.custid as CustID,              
  isnull(h.InvcNum,'') as InvcNum, h.TransId              
FROM (ALP_tblArCust_View c (NOLOCK) LEFT JOIN sys.dbo.tblSmCountry s (NOLOCK) ON c.Country = s.Country)               
  RIGHT JOIN (((sys.dbo.tblSmCountry AS ShipTotblSmCountry RIGHT JOIN (((ALP_tblArTransHeader_view h (NOLOCK)               
  LEFT JOIN sys.dbo.tblSmCurrency y (NOLOCK) ON h.CurrencyID = y.CurrId)              
  LEFT JOIN tblArTermsCode t (NOLOCK) ON h.TermsCode = t.TermsCode)              
  LEFT JOIN ALP_tblArAlpSite(NOLOCK) ON h.AlpSiteID =ALP_tblArAlpSite.SiteId)              
  ON ShipTotblSmCountry.Country = h.ShipToCountry) INNER JOIN tblSmTaxGroup x (NOLOCK)               
  ON h.TaxGrpID = x.TaxGrpID))ON c.CustId = h.CustId              
  LEFT OUTER JOIN ALP_tblArTransDetail_view  d (NOLOCK) ON d.TransId = h.TransId              
 WHERE               
 --h.Transtype =1 and --#EFI 1890 SUDHARSON 062011 Commented to display records for credit memo              
 h.TransId in               
  (              
   Select   TransId from  ALP_tmpTransactionList          
   --select distinct h.TransID FROM                
   --(dbo.ALP_tblArTransHeader_view h (NOLOCK)               
   --INNER JOIN dbo.tblArTransBatchcs b (NOLOCK)               
   --ON h.BatchId = b.BatchID) LEFT JOIN dbo.ALP_tblArTransDetail_view d   (NOLOCK)               
   --ON h.TransId = d.TransID               
   --WHERE (b.UserID = @UserID And b.WrkStnID= @WrkStnId) AND              
   -- (h.PrintStatus=0 Or h.PrintStatus=2)              
  )              
)A              
              
select * into #temp2 from               
(              
              
SELECT                 
  'D' AS TableType, h.TransId as TransId1,
  h.BatchId as BatchId,		--added to display on email result report #DMM 04/05/2017
  isnull(h.InvcNum,'') as InvcNum ,               
  (select UseLogo from sys.dbo.tblSmCompInfo where CompID = @CompID) as UseLogo,              
  (select TEXTPTR(Logo) from sys.dbo.tblSmCompInfo where CompID = @CompID) as Logo,              
  h.PrintStatus, c.CustId as CustId, c.Attn, c.CustName, c.Contact, c.Addr1, c.Addr2, c.City, c.Region,               
  c.Country, 
  --c.PostalCode,
  --mah 02/21/15 - format postalcode
  CASE WHEN c.PostalCode IS NULL THEN ''
  ELSE
	CASE WHEN LEN(c.PostalCode) <= 5 THEN c.PostalCode
		ELSE LEFT(c.PostalCode,5) + '-' 
		+ SUBSTRING(c.PostalCode, 6,LEN(c.PostalCode) - 5)
		END 
  END AS PostalCode,
  h.ShipToID, h.ShipToName, h.ShipToAddr1, h.ShipToAddr2, h.ShipToCity,               
  h.ShipToCountry, h.ShipToRegion, h.ShipToPostalCode, h.ShipVia, h.TermsCode, t.[Desc] AS TermDesc,               
  t.DiscDayOfMonth, t.DiscDays, t.DiscMinDays, t.NetDueDays, h.TransType, h.OrderDate, h.ShipDate,               
  h.ShipNum, h.InvcDate, h.Rep1Id, h.Rep2Id,   
  --added SalesRepName by mah 09/13/13:   
  r.Name as SalesRepName,            
  h.DiscDueDate,              
  h.NetDueDate,              
   case when @CboBase=1 Then h.TaxSubtotal else h.TaxSubtotalFgn end as TaxSubtotal ,               
   case when @CboBase=1 Then h.NonTaxSubtotal else h.NonTaxSubtotalFgn end as NonTaxSubtotal,    
   --mah 05/22/14 - added SalesTax adjustment value , so Sales Tax going to all report formats is already total amount   
   case when @CboBase=1 Then h.SalesTax + h.TaxAmtAdj else h.SalesTaxFgn  + h.TaxAmtAdjFgn  end as SalesTax,           
   --case when @CboBase=1 Then h.SalesTax else h.SalesTaxFgn end as SalesTax,               
   case when @CboBase=1 Then h.Freight else h.FreightFgn end as Freight,               
   case when @CboBase=1 Then h.Misc else h.MiscFgn end as Misc,               
   case when @CboBase=1 Then h.TotCost else h.TotCostFgn end as TotCost,               
  -- case when @CboBase=1 Then h.TotPmtAmt else h.TotPmtAmtFgn end as TotPmtAmt,               
   case when @CboBase=1 Then h.TaxAmtAdj else h.TaxAmtAdjFgn end as TaxAmtAdj,              
  h.TaxAdj, h.CustPONum,               
  case  when @CboBase=1 Then (select top 1 BaseCurrency  from sys.dbo.tblSmCompInfo where CompID = @CompID)               
   else h.CurrencyID               
   end as  CurrencyID ,               
  y.CurrMask ,              
  s.PostalCodeMask, ShipTotblSmCountry.PostalCodeMask AS ShipToPostalCodeMask,                
  case when @CboBase=1 Then 1 else h.ExchRate end as  ExchRate ,              
  s.[Name],               
--  tblArAlpSite.AlpFirstName AS SiteFirstName, tblArAlpSite.SiteName, tblArAlpSite.Attn AS SiteAttn, tblArAlpSite.Addr1 AS SiteAddr1,               
--  tblArAlpSite.Addr2 AS SiteAddr2, tblArAlpSite.City AS SiteCity, tblArAlpSite.Region AS SiteRegion, tblArAlpSite.Country AS SiteCountry,               
--  tblArAlpSite.PostalCode AS SitePostalCode, h.AlpMailSiteYN, c.AlpFirstName AS CustFirstName, tblArAlpSite.SiteId as SiteId1              
  isnull(ALP_tblArAlpSite.AlpFirstName,'') AS SiteFirstName,               
  isnull(ALP_tblArAlpSite.SiteName,'') as SiteName,               
  isnull(ALP_tblArAlpSite.Attn,'') AS SiteAttn,               
  isnull(ALP_tblArAlpSite.Addr1,'') AS SiteAddr1,               
  isnull(ALP_tblArAlpSite.Addr2,'') AS SiteAddr2,               
  isnull(ALP_tblArAlpSite.City,'') AS SiteCity,               
  isnull(ALP_tblArAlpSite.Region,'') AS SiteRegion,               
  isnull(ALP_tblArAlpSite.Country,'') AS SiteCountry,               
  --isnull(ALP_tblArAlpSite.PostalCode,'') AS SitePostalCode, 
  --mah 02/21/15 - format postalcode
  CASE WHEN ALP_tblArAlpSite.PostalCode IS NULL THEN ''
  ELSE
	CASE WHEN LEN(ALP_tblArAlpSite.PostalCode) <= 5 THEN ALP_tblArAlpSite.PostalCode
		ELSE LEFT(ALP_tblArAlpSite.PostalCode,5) + '-' 
		+ SUBSTRING(ALP_tblArAlpSite.PostalCode, 6,LEN(ALP_tblArAlpSite.PostalCode) - 5)
		END 
  END AS SitePostalCode,               
  isnull(h.AlpMailSiteYN,'false') As AlpMailSiteYN ,               
  isnull(c.AlpFirstName ,'') AS CustFirstName,               
  isnull(ALP_tblArAlpSite .SiteId,0) as SiteId1              
              
 --#EFI 1890 07/13/2010 - Added By Sudharson to calculate applied Credits              
 ,(select isnull(SUM(Paymentamt),0) from              
 (               
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:              
  Select case when @CboBase=1 Then sum(PmtAmt) else sum(PmtAmtFgn) end as PaymentAmt              
   from tblArHistPmt HP              
   where HP.CustID = c.CustId and HP.InvcNum = h.InvcNum               
    and PmtAmt<>0 --and PmtAmtfgn<>0              
    and NOT EXISTS               
    (Select ALP_tblArOpenInvoice_View.InvcNum from ALP_tblArOpenInvoice_View where CustID = c.CustId and ALP_tblArOpenInvoice_View.InvcNum = h.InvcNum)              
  union all              
  --MAH 08/06/11 end                 
  Select  case when @CboBase=1 Then sum(Amt) else sum(AmtFgn) end as PaymentAmt              
   from ALP_tblArOpenInvoice_View where               
   CustID = c.CustId and               
   ALP_tblArOpenInvoice_View.InvcNum = h.InvcNum              
   and RecType < 0 and amt<>0-- and Status <> 4  (Removed By Sudharson 10/28/2010 - As per TestResults_102610_SOLUTION_MAHComments.docx              
   GROUP BY CustId, ALP_tblArOpenInvoice_View.InvcNum              
  UNION all              
  Select case when @CboBase=1 Then SUM(QtyOrdSell  *  UnitPriceSell) else SUM(QtyOrdSell  *  UnitPriceSellFgn) end as PaymentAmt               
   from ALP_tblArTransDetail_view inner join ALP_tblArTransHeader_view               
   on ALP_tblArTransHeader_view.TransId = ALP_tblArTransDetail_view.TransId               
   where ALP_tblArTransHeader_view.CustID = c.CustId and               
   ALP_tblArTransHeader_view.InvcNum = h.InvcNum              
   and ALP_tblArTransHeader_view.TransId <> h.TransId              
   and ALP_tblArTransHeader_view.TransType < 0               
   GROUP BY CustId, ALP_tblArTransHeader_view.InvcNum            
   having SUM(QtyOrdSell  *  UnitPriceSell)<>0              
  UNION all              
  SELECT case when @CboBase=1 Then SUM(ALP_tblArCashRcptDetail_View.PmtAmt) else SUM(ALP_tblArCashRcptDetail_View.PmtAmtFgn) end as PaymentAmt              
   from ALP_tblArCashRcptDetail_View inner join tblArCashRcptHeader               
   on tblArCashRcptHeader.RcptHeaderID = ALP_tblArCashRcptDetail_View.RcptHeaderID              
   where              
   ALP_tblArCashRcptDetail_View.PmtAmt > 0 and                  
   tblArCashRcptHeader.CustID = c.CustId  and               
   ALP_tblArCashRcptDetail_View.InvcNum = h.InvcNum              
 ) AppliedCredits              
 ) as PaymentAmtTotal,              
              
 --EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits Record Count              
 (select isnull(sum(reccount),0) from               
 (              
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:              
  Select count(HP.CustId) as reccount              
   from tblArHistPmt HP              
   where HP.CustID = c.CustId and HP.InvcNum = h.InvcNum               
    and PmtAmt<>0 --and PmtAmtfgn<>0              
    and NOT EXISTS               
    (Select ALP_tblArOpenInvoice_View.InvcNum from ALP_tblArOpenInvoice_View where CustID = c.CustID and ALP_tblArOpenInvoice_View.InvcNum = h.InvcNum)              
 union all              
  --MAH 08/06/11 end              
              
  Select  count(AOI.CustId) as reccount              
  from ALP_tblArOpenInvoice_View AOI              
  left outer JOIN tblArPmtMethod PM ON AOI.PmtMethodID = PM.PmtMethodID               
  where AOI.CustID = c.CustId and AOI.InvcNum = h.InvcNum              
  and RecType < 0 and amt<>0               
 union all              
  Select  count(CustId) as reccount              
  from ALP_tblArTransDetail_view inner join ALP_tblArTransHeader_view               
  on ALP_tblArTransHeader_view.TransId = ALP_tblArTransDetail_view.TransId               
  where ALP_tblArTransHeader_view.CustID = c.CustId and ALP_tblArTransHeader_view.InvcNum = h.InvcNum              
   and ALP_tblArTransHeader_view.TransId <> h.TransId              
   and ALP_tblArTransHeader_view.TransType < 0              
  having SUM(QtyOrdSell  *  UnitPriceSell)<>0              
 union all              
  Select  count(CRH.CustId) as reccount              
  from ALP_tblArCashRcptDetail_View CRD inner join tblArCashRcptHeader CRH              
  on CRH.RcptHeaderID = CRD.RcptHeaderID              
  INNER JOIN tblArPmtMethod PM ON CRH.PmtMethodID = PM.PmtMethodID              
  where CRH.CustID = c.CustId and CRD.InvcNum = h.InvcNum              
   and CRD.PmtAmt > 0 ) as SubRecCount              
  )  as SubRecCount,              
              
 isnull(d.PartId,'') as PartId, d.EntryNum,               
 isnull(d.[Desc],'') AS PartDesc,               
 isnull(d.AddnlDesc,'') as AddnlDesc, d.TaxClass,               
 d.QtyOrdSell, d.UnitsSell, d.UnitsBase, d.QtyShipBase, d.QtyShipSell, d.QtyBackordSell, d.PriceCode,               
 case when @CboBase=1 Then UnitPriceSell else UnitPriceSellFgn end as UnitPriceSell1 ,               
 case when @CboBase=1 Then UnitCostSell else UnitCostSellFgn end as UnitCostSell1,               
 d.PartType, d.LottedYn,              
 null as CustId1, null as SiteID, isnull(h.InvcNum,'') as InvoiceNum, null as TransId, null as Source,               
 null as PostedYn, null as PaymentMethodID, null as CheckNum, null as [Description], null as PaymentDate, 0 as PaymentAmt               
 FROM (ALP_tblArCust_View c (NOLOCK) LEFT JOIN sys.dbo.tblSmCountry s (NOLOCK) ON c.Country = s.Country)               
  RIGHT JOIN (((sys.dbo.tblSmCountry AS ShipTotblSmCountry RIGHT JOIN (((ALP_tblArTransHeader_view h (NOLOCK)               
  LEFT JOIN sys.dbo.tblSmCurrency y (NOLOCK) ON h.CurrencyID = y.CurrId)              
  LEFT JOIN tblArTermsCode t (NOLOCK) ON h.TermsCode = t.TermsCode)              
  LEFT JOIN ALP_tblArAlpSite(NOLOCK) ON h.AlpSiteID = ALP_tblArAlpSite.SiteID)              
  ON ShipTotblSmCountry.Country = h.ShipToCountry) INNER JOIN tblSmTaxGroup x (NOLOCK)               
  ON h.TaxGrpID = x.TaxGrpID))ON c.CustId = h.CustId              
  LEFT OUTER JOIN ALP_tblArTransDetail_view d (NOLOCK) ON d.TransId = h.TransId    
  LEFT OUTER JOIN dbo.tblArSalesRep r ON h.Rep1Id = r.SalesRepID         
 WHERE               
-- h.Transtype =1 and  --#EFI 1890 SUDHARSON 062011 Commented to display records for credit memo              
 h.TransId  in               
  (  Select   TransId from  ALP_tmpTransactionList          
   --select distinct h.TransID FROM                
   --(dbo.ALP_tblArTransHeader_view h (NOLOCK)               
   --INNER JOIN dbo.tblArTransBatchcs b (NOLOCK)               
   --ON h.BatchId = b.BatchID) LEFT JOIN dbo.ALP_tblArTransDetail_view d   (NOLOCK)               
   --ON h.TransId = d.TransID               
   --WHERE (b.UserID = @UserID And b.WrkStnID= @WrkStnId) AND              
   -- (h.PrintStatus=0 Or h.PrintStatus=2)              
  )              
 --order by h.TransID              
              
              
UNION ALL              
              
Select              
  'S' AS TableType, TransId as TransId1,
  '' as BatchId,		--added to display on email result report #DMM 04/05/2017
  InvoiceNum as InvcNum ,               
  (select UseLogo from sys.dbo.tblSmCompInfo where CompID = @CompID) as UseLogo,              
  (select TEXTPTR(Logo) from sys.dbo.tblSmCompInfo where CompID = @CompID) as Logo,          
  null as PrintStatus, c.CustId as CustId, c.Attn, c.CustName, c.Contact, c.Addr1, c.Addr2, c.City, c.Region,               
  c.Country, 
  --c.PostalCode,
  --mah 02/21/15 - format postalcode
  CASE WHEN c.PostalCode IS NULL THEN ''
  ELSE
	CASE WHEN LEN(c.PostalCode) <= 5 THEN c.PostalCode
		ELSE LEFT(c.PostalCode,5) + '-' 
		+ SUBSTRING(c.PostalCode, 6,LEN(c.PostalCode) - 5)
		END 
  END AS PostalCode,
  null as ShipToID, null as ShipToName, null as ShipToAddr1, null as ShipToAddr2, null as ShipToCity,               
  null as ShipToCountry, null as ShipToRegion, null as ShipToPostalCode, null as ShipVia, null as TermsCode, null as TermDesc,               
  null as DiscDayOfMonth, null as DiscDays, null as DiscMinDays, null as NetDueDays, null as TransType, null as OrderDate, null as ShipDate,               
  null as ShipNum, null as InvcDate, null as Rep1Id, null as Rep2Id,   
  --added by mah 09/13/13:  
  null as SalesRepName,             
  null as DiscDueDate,              
  null as NetDueDate,              
  null as TaxSubtotal ,               
  null as NonTaxSubtotal,              
  null as SalesTax,               
  null as Freight,               
  null as Misc,               
  null as TotCost,               
  --null as TotPmtAmt,               
  null as TaxAmtAdj,              
  null as TaxAdj, null as CustPONum,               
  null as CurrencyID ,               
  null as CurrMask ,              
  null as PostalCodeMask, null as ShipToPostalCodeMask,              
  null as ExchRate ,              
  null as [Name],               
  null as SiteFirstName, null as SiteName, null as SiteAttn, null as SiteAddr1,               
  null as SiteAddr2, null as SiteCity, null as SiteRegion, null as SiteCountry,               
  null as SitePostalCode, null as AlpMailSiteYN, null AS CustFirstName, null as SiteId1,              
  --0 as PaymentAmtTotal,              
  --0 as SubRecCount,              
              
  (select isnull(SUM(Paymentamt),0) from              
  (               
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:              
   Select case when @CboBase=1 Then sum(PmtAmt) else sum(PmtAmtFgn) end as PaymentAmt              
   from tblArHistPmt HP              
   where HP.CustID = c.CustId and HP.InvcNum = InvcNum              
    and PmtAmt<>0 --and PmtAmtfgn<>0              
    and NOT EXISTS               
    (Select ALP_tblArOpenInvoice_View.InvcNum from ALP_tblArOpenInvoice_View where CustID = c.CustId and ALP_tblArOpenInvoice_View.InvcNum = InvcNum)              
  union all              
  --MAH 08/06/11 end                 
   Select  case when @CboBase=1 Then sum(Amt) else sum(AmtFgn) end as PaymentAmt              
    from ALP_tblArOpenInvoice_View where               
    CustID = T.CustId and               
    ALP_tblArOpenInvoice_View.InvcNum = T.InvcNum              
    and RecType < 0 and amt<>0 -- and Status <> 4  (Removed By Sudharson 10/28/2010 - As per TestResults_102610_SOLUTION_MAHComments.docx              
    GROUP BY CustId, ALP_tblArOpenInvoice_View.InvcNum              
   UNION all              
   Select case when @CboBase=1 Then SUM(QtyOrdSell  *  UnitPriceSell) else SUM(QtyOrdSell  *  UnitPriceSellFgn) end as PaymentAmt               
    from ALP_tblArTransDetail_view inner join ALP_tblArTransHeader_view               
    on ALP_tblArTransHeader_view.TransId = ALP_tblArTransDetail_view.TransId               
    where ALP_tblArTransHeader_view.CustID = T.CustId and               
    ALP_tblArTransHeader_view.InvcNum = T.InvcNum              
   and ALP_tblArTransHeader_view.TransId <> T.TransID2              
    and ALP_tblArTransHeader_view.TransType < 0               
    GROUP BY CustId, ALP_tblArTransHeader_view.InvcNum              
    having SUM(QtyOrdSell  *  UnitPriceSell)<>0              
   UNION all              
   SELECT case when @CboBase=1 Then SUM(ALP_tblArCashRcptDetail_View.PmtAmt) else SUM(ALP_tblArCashRcptDetail_View.PmtAmtFgn) end as PaymentAmt              
    from ALP_tblArCashRcptDetail_View inner join tblArCashRcptHeader               
    on tblArCashRcptHeader.RcptHeaderID = ALP_tblArCashRcptDetail_View.RcptHeaderID              
    where              
    ALP_tblArCashRcptDetail_View.PmtAmt > 0 and                  
    tblArCashRcptHeader.CustID = T.CustId  and               
    ALP_tblArCashRcptDetail_View.InvcNum = T.InvcNum              
  ) AppliedCredits              
  ) as PaymentAmtTotal,              
              
  (select isnull(sum(reccount),0) from               
  (              
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:              
  Select count(HP.CustId) as reccount              
   from tblArHistPmt HP              
   where HP.CustID = c.CustId and HP.InvcNum = InvcNum               
    and PmtAmt<>0 --and PmtAmtfgn<>0              
    and NOT EXISTS               
    (Select ALP_tblArOpenInvoice_View.InvcNum from ALP_tblArOpenInvoice_View where CustID = c.CustID and ALP_tblArOpenInvoice_View.InvcNum = InvcNum)              
  union all              
  --MAH 08/06/11 end              
              
   Select  count(AOI.CustId) as reccount              
   from ALP_tblArOpenInvoice_View AOI              
   left outer JOIN tblArPmtMethod PM ON AOI.PmtMethodID = PM.PmtMethodID               
   where AOI.CustID =T.CustID and AOI.InvcNum = T.InvcNum              
   and RecType < 0 and amt<>0               
  union all              
 Select  count(CustId) as reccount              
   from ALP_tblArTransDetail_view inner join ALP_tblArTransHeader_view               
   on ALP_tblArTransHeader_view.TransId = ALP_tblArTransDetail_view.TransId               
   where ALP_tblArTransHeader_view.CustID =T.CustID and ALP_tblArTransHeader_view.InvcNum = T.InvcNum              
   and ALP_tblArTransHeader_view.TransId <> T.TransID2              
    and ALP_tblArTransHeader_view.TransType < 0              
   having SUM(QtyOrdSell  *  UnitPriceSell)<>0              
  union all              
   Select  count(CRH.CustId) as reccount              
   from ALP_tblArCashRcptDetail_View CRD inner join tblArCashRcptHeader CRH              
   on CRH.RcptHeaderID = CRD.RcptHeaderID              
   INNER JOIN tblArPmtMethod PM ON CRH.PmtMethodID = PM.PmtMethodID              
   where CRH.CustID =T.CustID and CRD.InvcNum = T.InvcNum              
    and CRD.PmtAmt > 0 ) as SubRecCount              
   )  as SubRecCount,              
              
 'PartID1' as PartId, null as EntryNum,               
 'PartDesc1'  as PartDesc,               
 'PartAddnlDesc1' as AddnlDesc, null as TaxClass,               
 null as QtyOrdSell, null as UnitsSell, null as UnitsBase, null as QtyShipBase, null as QtyShipSell, null as QtyBackordSell, null as PriceCode,               
 null as UnitPriceSell1 , null as UnitCostSell1,               
 null as PartType, null as LottedYn,              
 B.CustId as CustID1, B.SiteID, InvoiceNum, B.TransId, Source, PostedYn, PaymentMethodID, CheckNum, [Description], PaymentDate, PaymentAmt              
from               
#temp1 T inner join               
(              
-- if @Source = 1              
 Select  AOI.CustId,AOI.AlpSiteId as SiteID,AOI.InvcNum as InvoiceNum,              
  min(AlpTransId) as TransId,1 as Source,cast(1 as bit) as PostedYn,              
  AOI.PmtMethodId as PaymentMethodID, CheckNum,              
  case when CheckNum is null then PM.[Desc] else PM.[Desc] + '-' + CheckNum end as [Description],              
  TransDate as PaymentDate, --sum(AmtFgn)  as PaymentAmt               
  case when @CboBase=1 Then sum(Amt) else sum(AmtFgn) end as PaymentAmt              
 from ALP_tblArOpenInvoice_View AOI              
 left outer JOIN tblArPmtMethod PM ON AOI.PmtMethodID = PM.PmtMethodID               
-- where AOI.CustID = @CustId and InvcNum = @InvcNum              
 where AOI.CustID in (Select CustID from #temp1) and AOI.InvcNum in (Select InvcNum from #temp1)              
 and RecType < 0 and amt<>0 -- and Status <> 4  (Removed By Sudharson 10/28/2010 - As per TestResults_102610_SOLUTION_MAHComments.docx              
 GROUP BY              
  AOI.CustId,AOI.AlpSiteId, AOI.InvcNum,              
  AOI.PmtMethodId, CheckNum,              
  case when CheckNum is null then PM.[Desc] else PM.[Desc] + '-' + CheckNum end,              
  TransDate              
-- if @Source = 2              
union all              
 Select  CustId,ALP_tblArTransDetail_view.AlpSiteId as SiteID,ALP_tblArTransHeader_view.InvcNum as InvoiceNum,              
  min(ALP_tblArTransDetail_view.TransId) as TransId,2 as Source,cast(0 as bit) as PostedYn,              
  'Credit' as PaymentMethodID, '' as CheckNum,              
--  'credit-' + case when isnull(PartID,'') != '' then isnull(PartID,'') + ' - ' else '' end +              
--  case when isnull([Desc],'') != '' then isnull([Desc],'') + ' - ' else '' end +              
--  cast(AddnlDesc as varchar(255)) as [Description],              
  'Credit - ' + case when isnull([Desc],'') != ''               
      then isnull([Desc],'') + ' - '               
      else isnull(PartID,'') + ' - ' end +              
     cast(isnull(AddnlDesc,'') as varchar(255)) as [Description],              
  InvcDate as PaymentDate, --SUM(QtyOrdSell  *  UnitPriceSellFgn)  as PaymentAmt               
  case when @CboBase=1 Then SUM(QtyOrdSell  *  UnitPriceSell) else SUM(QtyOrdSell  *  UnitPriceSellFgn) end as PaymentAmt              
 from ALP_tblArTransDetail_view inner join ALP_tblArTransHeader_view               
 on ALP_tblArTransHeader_view.TransId = ALP_tblArTransDetail_view.TransId               
 --where ALP_tblArTransHeader_view.CustID = @CustId and ALP_tblArTransHeader_view.InvcNum = @InvcNum              
 where ALP_tblArTransHeader_view.CustID in (Select CustID from #temp1) and ALP_tblArTransHeader_view.InvcNum in (Select #temp1.InvcNum from #temp1)              
   and ALP_tblArTransHeader_view.TransId not in (select TransID2 from #temp1)               
  and ALP_tblArTransHeader_view.TransType < 0               
 GROUP BY              
  CustId,ALP_tblArTransDetail_view.AlpSiteId, ALP_tblArTransHeader_view.InvcNum,              
--  'credit-' + case when isnull(PartID,'') != '' then isnull(PartID,'') + ' - ' else '' end +              
--  case when isnull([Desc],'') != '' then isnull([Desc],'') + ' - ' else '' end +              
--  cast(AddnlDesc as varchar(255)),              
  'Credit - ' + case when isnull([Desc],'') != ''               
      then isnull([Desc],'') + ' - '               
      else isnull(PartID,'') + ' - ' end +              
     cast(isnull(AddnlDesc,'') as varchar(255)),              
  InvcDate              
 having SUM(QtyOrdSell  *  UnitPriceSell)<>0              
-- if @Source = 3              
union all              
 Select  CRH.CustId,CRD.AlpSiteId as SiteID,CRD.InvcNum as InvoiceNum,              
  min(InvcTransId) as TransId,3 as Source,cast(0 as bit)  as PostedYn,              
  CRH.PmtMethodId as PaymentMethodID, CheckNum,              
--  case when CheckNum is null then PM.[Desc] else              
--  case when note is null then PM.[Desc] + '-' + CheckNum else PM.[Desc] + '-' + CheckNum + '-' + note end end as [Description],              
  case when CheckNum is null then              
   case when note is null then PM.[Desc]               
     else PM.[Desc] + ' - ' + note               
   end               
  --PM.[Desc] + ' - ' + note                
  else case when note is null then PM.[Desc] + ' - #' + CheckNum               
     else PM.[Desc] + ' - #' + CheckNum + ' - ' + note               
    end               
  end as [Description],              
  CRH.PmtDate as PaymentDate, --SUM(CRD.PmtAmtFgn)  as PaymentAmt              
  case when @CboBase=1 Then SUM(CRD.PmtAmt) else SUM(CRD.PmtAmtFgn) end as PaymentAmt              
 from ALP_tblArCashRcptDetail_View CRD inner join tblArCashRcptHeader CRH              
 on CRH.RcptHeaderID = CRD.RcptHeaderID              
 INNER JOIN tblArPmtMethod PM ON CRH.PmtMethodID = PM.PmtMethodID              
-- where CRH.CustID = @CustId and CRD.InvcNum = @InvcNum              
 where CRH.CustID in (Select CustID from #temp1)and CRD.InvcNum in (Select InvcNum from #temp1)              
   and CRD.PmtAmt > 0               
 GROUP BY              
  CRH.CustId,CRD.AlpSiteId, CRD.InvcNum ,              
  CRH.PmtMethodId, CheckNum,              
  case when CheckNum is null then              
   case when note is null then PM.[Desc]               
     else PM.[Desc] + ' - ' + note               
   end               
  --PM.[Desc] + ' - ' + note                
  else case when note is null then PM.[Desc] + ' - #' + CheckNum               
     else PM.[Desc] + ' - #' + CheckNum + ' - ' + note               
    end               
  end,              
--  case when CheckNum is null then PM.[Desc] else              
--  case when note is null then PM.[Desc] + '-' + CheckNum else PM.[Desc] + '-' + CheckNum + '-' + note end end ,              
  CRH.PmtDate              
) B              
on T.CustID = B.CustID and T.InvcNum= B.InvoiceNum               
left outer join ALP_tblArCust_View c (NOLOCK) on  T.CustID = C.CustID              
)CC              
          
              
Select * from #temp2 order by InvcNum, TableType    
--RAVI 02/10/2015 - Below code added by ravi. to calculate batch invoice total
exec Alp_rptAlpEI_GetArTransHeader_BatchTotal_sp  1 ,'USD'
            
drop table #temp2              
drop table #temp1              
End