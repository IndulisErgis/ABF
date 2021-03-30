    
    
CREATE                      Procedure [dbo].[ALP_rptAlpEI_GetArTransHeader_sp]       
 @TransID pTransID,      
 @PrintType varchar(50) = 'PRINT',      
 @CompID pCompID,   --EFI# 1890 SUDHARSON 09/29/2010 - Added to show the Company Logo      
 @CustId varchar(30),    --EFI# 1890 SUDHARSON 01/24/2010 - Added while merging subapplied credits query      
 @InvcNum varchar(30),   --EFI# 1890 SUDHARSON 01/24/2010 - Added while merging subapplied credits query      
 @CboBase bit = 0   --EFI# 1890 SUDHARSON 01/24/2010 - Added while merging subapplied credits query      
As      
--MAH 06/16/11 - modifications: force use of non-fgn fields; ignore 0 amount credits;  TransID check(except in OpenInvoice file)..     
--MAH 01/26/15 - corrections related to Credit Memo display     
--MAH 02/05/15 - changes to accomodate credits where detail data is now missing in history files    
--mah 10/19/15 - corrections related to builder credit memo displays..  
Begin      
SET NOCOUNT ON      
--MAH 06/16/11 - changed logic to force it to ignore multi-currency for now.      
--   ( i.e. always use base amounts, rather than foreign amounts)      
--   This is a temporary change until the insertion of foreign amounts       
--   in all transactions is verified.  Did this by adding following statement,       
--   which forces @cboBase to be 1.       
--MAH 08/06/11 - added hist pmt logic, and corrected transaction selection      
SET @CboBase = 1 --To be removed once fgn fields in all transactions are corrected.      
      
IF @PrintType = 'PRINT'       
BEGIN      
SELECT     
--mah 01/26/15 TEST    
'D-FIRST' as Step,        
  'D' AS TableType,      
  (select UseLogo from sys.dbo.tblSmCompInfo where CompID = @CompID) as UseLogo,      
  (select TEXTPTR(Logo) from sys.dbo.tblSmCompInfo where CompID = @CompID) as Logo,      
  h.PrintStatus, c.CustId, c.Attn, c.CustName, c.Contact, c.Addr1, c.Addr2, c.City, c.Region,       
  c.Country,     
  --mah 021915-format postalcode    
  --c.PostalCode,    
  CASE WHEN LEN(c.PostalCode) <= 5 THEN c.PostalCode    
  ELSE LEFT(c.PostalCode,5) + '-'     
  + SUBSTRING(c.PostalCode, 6,LEN(c.PostalCode) - 5)    
  END AS PostalCode,     
  h.ShipToID, h.ShipToName, h.ShipToAddr1, h.ShipToAddr2, h.ShipToCity,       
  h.ShipToCountry, h.ShipToRegion, h.ShipToPostalCode, h.ShipVia, h.TermsCode, t.[Desc] AS TermDesc,       
  t.DiscDayOfMonth, t.DiscDays, t.DiscMinDays, t.NetDueDays, h.TransType, h.OrderDate, h.ShipDate,       
  h.ShipNum, h.InvcDate, h.Rep1Id, h.Rep2Id,      
  h.DiscDueDate,      
  h.NetDueDate,      
  case when @CboBase=1 Then h.TaxSubtotal else h.TaxSubtotalFgn end as TaxSubtotal ,       
  case when @CboBase=1 Then h.NonTaxSubtotal else h.NonTaxSubtotalFgn end as NonTaxSubtotal,    
   --mah 04/15/15 - added SalesTax adjustment value , so Sales Tax going to all report formats is already total amount     
   case when @CboBase=1 Then h.SalesTax + h.TaxAmtAdj else h.SalesTaxFgn  + h.TaxAmtAdjFgn  end as SalesTax,         
  ----case when @CboBase=1 Then h.SalesTax else h.SalesTaxFgn end as SalesTax,    
  ----mah 01/27/15: need to revert back tax calc      
  --case when @CboBase=1 Then h.SalesTax else h.SalesTaxFgn end as SalesTax,        
  case when @CboBase=1 Then h.Freight else h.FreightFgn end as Freight,       
  case when @CboBase=1 Then h.Misc else h.MiscFgn end as Misc,       
  case when @CboBase=1 Then h.TotCost else h.TotCostFgn end as TotCost,       
  0 as TotPmtAmt,--case when @CboBase=1 Then h.TotPmtAmt else h .TotPmtAmtFgn end as TotPmtAmt,       
  0 as TaxAmtAdj, -- case when @CboBase=1 Then h.TaxAmtAdj else h.TaxAmtAdjFgn end as TaxAmtAdj,      
  h.TaxAdj, h.CustPONum,       
  case  when @CboBase=1 Then (select top 1 BaseCurrency  from sys.dbo.tblSmCompInfo where CompID = @CompID)       
   else h.CurrencyID       
   end as  CurrencyID ,       
  h.InvcNum, y.CurrMask ,      
  s.PostalCodeMask, ShipTotblSmCountry.PostalCodeMask AS ShipToPostalCodeMask, h.TransId,       
  case when @CboBase=1 Then 1 else h.ExchRate end as  ExchRate ,      
  s.[Name],       
  ALP_tblArAlpSite.AlpFirstName AS SiteFirstName, ALP_tblArAlpSite.SiteName, ALP_tblArAlpSite.Attn AS SiteAttn,       
  ALP_tblArAlpSite.Addr1 AS SiteAddr1, ALP_tblArAlpSite.Addr2 AS SiteAddr2,       
  ALP_tblArAlpSite.City AS SiteCity, ALP_tblArAlpSite.Region AS SiteRegion, ALP_tblArAlpSite.Country AS SiteCountry,    
  --mah 02/19/15 - format postalcode    
  --ALP_tblArAlpSite.PostalCode AS SitePostalCode,    
  CASE WHEN LEN(ALP_tblArAlpSite.PostalCode) <= 5 THEN ALP_tblArAlpSite.PostalCode    
  ELSE LEFT(ALP_tblArAlpSite.PostalCode,5) + '-'     
  + SUBSTRING(ALP_tblArAlpSite.PostalCode, 6,LEN(ALP_tblArAlpSite.PostalCode) - 5)    
  END AS SitePostalCode,        
  h.AlpMailSiteYN, c.AlpFirstName AS CustFirstName,       
  isnull(ALP_tblArAlpSite.SiteId,0) as SiteId,      
      
  --EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits Record Count      
  (select isnull(sum(reccount),0) from       
  (      
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
  Select count(HP.CustId) as reccount      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end      
  Select count(AOI.CustId) as reccount     
  --mah 01/26/15:    
   --from tblArOpenInvoice AOI     
   from ALP_tblArOpenInvoice_view AOI      
   where AOI.CustID = c.CustId and InvcNum = h.InvcNum      
   --mah 1/26/15:  
   --mah 10/19/15:    
    and (AOI.TransID IS NULL  OR AOI.TransID <> @TransID )   
    and RecType < 0 and amt<>0 --and amtfgn<>0      
  union all      
   Select count(CustId) as reccount      
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = c.CustId       
    and tblArTransHeader.InvcNum = h.InvcNum       
    and tblArTransHeader.TransID <> @TransID      
    and tblArTransHeader.TransType < 0      
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  union all      
   Select  count(CRH.CustId) as reccount      
   from tblArCashRcptDetail CRD inner join tblArCashRcptHeader CRH      
   on CRH.RcptHeaderID = CRD.RcptHeaderID      
   INNER JOIN tblArPmtMethod PM ON CRH.PmtMethodID = PM.PmtMethodID      
   where CRH.CustID = c.CustId and CRD.InvcNum = h.InvcNum       
    and CRD.PmtAmt > 0) as SubRecCount      
   )  as SubRecCount,      
      
  (select isnull(SUM(Paymentamt),0) from      
  (      
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
   Select case when @CboBase=1 Then sum(PmtAmt) else sum(PmtAmtFgn) end as PaymentAmt      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end       
   Select  case when @CboBase=1 Then sum(Amt) else sum(AmtFgn) end as PaymentAmt     
   --mah 01/26/15:    
   --from tblArOpenInvoice where      
   from ALP_tblArOpenInvoice_view where       
   CustID = c.CustId and       
   InvcNum = h.InvcNum    
   --mah 10/19/15:   
    and (ALP_tblArOpenInvoice_view.TransID IS NULL OR  ALP_tblArOpenInvoice_view.TransID <> @TransID  )  
   and RecType < 0      
   GROUP BY CustId, InvcNum      
   having sum(Amt)<>0 --and sum(amtfgn)<>0      
  UNION all      
  Select case when @CboBase=1 Then SUM(QtyOrdSell  *  UnitPriceSell) else SUM(QtyOrdSell  *  UnitPriceSellFgn) end as PaymentAmt       
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = c.CustId       
    and tblArTransHeader.InvcNum = h.InvcNum       
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   GROUP BY CustId, InvcNum      
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  UNION all      
  SELECT case when @CboBase=1 Then SUM(tblArCashRcptDetail.PmtAmt) else SUM(tblArCashRcptDetail.PmtAmtFgn) end as PaymentAmt      
   from tblArCashRcptDetail inner join tblArCashRcptHeader       
   on tblArCashRcptHeader.RcptHeaderID = tblArCashRcptDetail.RcptHeaderID      
   where       
   tblArCashRcptDetail.PmtAmt > 0 and       
   tblArCashRcptHeader.CustID = c.CustId  and       
   tblArCashRcptDetail.InvcNum = h.InvcNum      
  ) as AppliedCredits      
  ) as PaymentAmtTotal,      
      
  isnull(d.PartId,'') as PartId, d.EntryNum,       
  isnull(d.[Desc],'') AS PartDesc,       
  isnull(d.AddnlDesc,'') as AddnlDesc, d.TaxClass,       
  d.QtyOrdSell, d.UnitsSell, d.UnitsBase, d.QtyShipBase, d.QtyShipSell, d.QtyBackordSell, d.PriceCode,       
  case when @CboBase=1 Then UnitPriceSell else UnitPriceSellFgn end AS UnitPriceSell1,       
  case when @CboBase=1 Then UnitCostSell else UnitCostSellFgn end AS UnitCostSell1,       
  d.PartType, d.LottedYn,      
  null as CustId, null as  SiteID, h.InvcNum as InvoiceNum,      
  null as TransId,null as Source,null as PostedYn,      
  null as PaymentMethodID, null as CheckNum,      
  null as Description,      
  null as PaymentDate,       
  null as PaymentAmt       
      
 FROM (ALP_tblArCust_view c (NOLOCK) LEFT JOIN sys.dbo.tblSmCountry s (NOLOCK) ON c.Country = s.Country)       
  RIGHT JOIN (((sys.dbo.tblSmCountry AS ShipTotblSmCountry RIGHT JOIN (((ALP_tblArTransHeader_view h (NOLOCK)       
  LEFT JOIN sys.dbo.tblSmCurrency y (NOLOCK) ON h.CurrencyID = y.CurrId)      
  LEFT JOIN tblArTermsCode t (NOLOCK) ON h.TermsCode = t.TermsCode)      
  LEFT JOIN ALP_tblArAlpSite(NOLOCK) ON h.AlpSiteID = ALP_tblArAlpSite.SiteID)      
  ON ShipTotblSmCountry.Country = h.ShipToCountry) INNER JOIN tblSmTaxGroup x (NOLOCK)       
  ON h.TaxGrpID = x.TaxGrpID))ON c.CustId = h.CustId LEFT OUTER JOIN tblArTransDetail d (NOLOCK) ON d.TransId = h.TransId      
 WHERE h.TransId = @TransID      
UNION ALL      
--============================================================================================      
--EFI 1918 08/06/11 - Added By MAH to get hist payments for fully paid invoices no longer in OpenInvoice file      
--  Source = 0      
--============================================================================================      
Select       
--mah 01/26/15 TEST    
'S-FIRST' as Step,         
  'S' AS TableType,      
  null as UseLogo,      
  null as Logo,      
  null as PrintStatus, null as CustId, null as Attn, null as CustName, null as Contact, null as Addr1, null as Addr2, null as City, null as Region,       
  null as Country, null as PostalCode, null as ShipToID, null as ShipToName, null as ShipToAddr1, null as ShipToAddr2, null as ShipToCity,       
  null as ShipToCountry, null as ShipToRegion, null as ShipToPostalCode, null as ShipVia, null as TermsCode, null as TermDesc,       
  null as DiscDayOfMonth, null as DiscDays, null as DiscMinDays, null as NetDueDays, null as TransType, null as OrderDate, null as ShipDate,       
  null as ShipNum, null as InvcDate, null as Rep1Id, null as Rep2Id,      
  null as DiscDueDate,      
  null as NetDueDate,      
  null as TaxSubtotal , null as NonTaxSubtotal,      
  null as SalesTax, null as Freight, null as Misc, null as TotCost,       
  null as TotPmtAmt, null as TaxAmtAdj,      
  null as TaxAdj, null as CustPONum, null as CurrencyID,       
  null as InvcNum, null as CurrMask ,      
  null as PostalCodeMask, null as ShipToPostalCodeMask, min(TransId) as TransId,       
  null as ExchRate, null as [Name],       
  null as SiteFirstName, null as SiteName, null as SiteAttn, null as SiteAddr1,       
  null as SiteAddr2, null as SiteCity, null as SiteRegion, null as SiteCountry,       
  null as SitePostalCode, null as AlpMailSiteYN, null as CustFirstName, null as SiteId,      
      
  --EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits Record Count      
  (select isnull(sum(reccount),0) from       
  (      
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
  Select count(HP.CustId) as reccount      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS      
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end      
  Select count(AOI.CustId) as reccount      
   from tblArOpenInvoice AOI      
   where AOI.CustID = @CustId and InvcNum = @InvcNum     
 -- mah 10/19/15:     
   and (AOI.TransID IS NULL  OR  AOI.TransID <> @TransID )     
   and RecType < 0 and amt<>0 --and amtfgn<>0       
  union all      
   Select count(CustId) as reccount      
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = @CustId       
    and tblArTransHeader.InvcNum = @InvcNum      
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  union all      
   Select  count(CRH.CustId) as reccount      
  from tblArCashRcptDetail CRD inner join tblArCashRcptHeader CRH      
  on CRH.RcptHeaderID = CRD.RcptHeaderID      
  INNER JOIN tblArPmtMethod PM ON CRH.PmtMethodID = PM.PmtMethodID      
  where CRH.CustID = @CustId and CRD.InvcNum = @InvcNum      
   and CRD.PmtAmt > 0) as SubRecCount      
   )  as SubRecCount,      
      
  (select isnull(SUM(Paymentamt),0) from      
  (       
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
   Select case when @CboBase=1 Then sum(PmtAmt) else sum(PmtAmtFgn) end as PaymentAmt      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end        
  Select  case when @CboBase=1 Then sum(Amt) else sum(AmtFgn) end as PaymentAmt      
   from tblArOpenInvoice where       
   CustID = @CustId and       
   InvcNum = @InvcNum     
 --mah 10/19/15:  
   and (TransID IS NULL OR TransID <> @TransID )      
   and RecType < 0      
   GROUP BY CustId, InvcNum      
   having sum(Amt)<>0 --and sum(amtfgn)<>0      
  UNION all      
  Select case when @CboBase=1 Then SUM(QtyOrdSell  *  UnitPriceSell) else SUM(QtyOrdSell  *  UnitPriceSellFgn) end as PaymentAmt       
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = @CustId       
    and tblArTransHeader.InvcNum = @InvcNum       
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   GROUP BY CustId, InvcNum      
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  UNION all      
  SELECT case when @CboBase=1 Then SUM(tblArCashRcptDetail.PmtAmt) else SUM(tblArCashRcptDetail.PmtAmtFgn) end as PaymentAmt      
   from tblArCashRcptDetail inner join tblArCashRcptHeader       
   on tblArCashRcptHeader.RcptHeaderID = tblArCashRcptDetail.RcptHeaderID      
   where       
   tblArCashRcptDetail.PmtAmt > 0 and       
   tblArCashRcptHeader.CustID = @CustId and       
   tblArCashRcptDetail.InvcNum = @InvcNum      
  ) as AppliedCredits      
  ) as PaymentAmtTotal,      
      
  'PartID1' as PartId, null as EntryNum,       
  'PartDesc1'  as PartDesc,       
  'PartAddnlDesc1' as AddnlDesc, null as TaxClass,       
  0 as QtyOrdSell, null as UnitsSell, null as UnitsBase, 0 as QtyShipBase, 0 as QtyShipSell, 0 as QtyBackordSell, 0 as PriceCode,       
  0 as UnitPriceSell1,       
  0 as UnitCostSell1,       
  null as PartType, null as LottedYn      
  ,HP.CustId,0 as SiteID,InvcNum as InvoiceNum,      
  min(TransId) as TransId,0 as Source,cast(1 as bit) as PostedYn,      
  HP.PmtMethodId as PaymentMethodID, CheckNum,      
  --case when CheckNum is null     
-- then PM.[Desc] else PM.[Desc] + ' - #' + CheckNum end as [Description],  --'HERE-2' as [Description] , --      
  -- add Note field from tblArHistPmt to the Description???     
  case when CheckNum is null     
  --then PM.[Desc]     
  then  case when note is null     
   then PM.[Desc]     
   else PM.[Desc] + '-' + note     end     
  else  case when note is null     
   then PM.[Desc] + '-' + CheckNum     
   else PM.[Desc] + '-' + CheckNum + '-' + note     
  end     
  end as [Description],      
      
  PmtDate as PaymentDate,       
  case @CboBase       
   when 0 then sum(PmtAmtFgn)        
   when 1 then sum(PmtAmt)      
  End      
  as PaymentAmt       
 from tblArHistPmt HP      
 left outer JOIN tblArPmtMethod PM ON HP.PmtMethodID = PM.PmtMethodID      
 where HP.CustID = @CustId and HP.InvcNum = @InvcNum      
  and NOT EXISTS (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
 GROUP BY      
  HP.CustId,HP.InvcNum,      
  HP.PmtMethodId, HP.CheckNum,     
    case when CheckNum is null     
  --then PM.[Desc]     
  then  case when note is null     
   then PM.[Desc]     
   else PM.[Desc] + '-' + note     
  end     
  else  case when note is null     
   then PM.[Desc] + '-' + CheckNum     
   else PM.[Desc] + '-' + CheckNum + '-' + note     
  end     
  end ,     
  --case when HP.CheckNum is null then PM.[Desc] else PM.[Desc] + ' - #' + HP.CheckNum end,      
  HP.PmtDate      
UNION ALL      
--============================================================================================      
--EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits for Source = 1      
--============================================================================================      
Select       
--mah 01/26/15 TEST    
'S-SECOND' as Step,         
  'S' AS TableType,      
  null as UseLogo,      
  null as Logo,      
  null as PrintStatus, null as CustId, null as Attn, null as CustName, null as Contact, null as Addr1, null as Addr2, null as City, null as Region,       
  null as Country, null as PostalCode, null as ShipToID, null as ShipToName, null as ShipToAddr1, null as ShipToAddr2, null as ShipToCity,       
  null as ShipToCountry, null as ShipToRegion, null as ShipToPostalCode, null as ShipVia, null as TermsCode, null as TermDesc,       
  null as DiscDayOfMonth, null as DiscDays, null as DiscMinDays, null as NetDueDays, null as TransType, null as OrderDate, null as ShipDate,       
  null as ShipNum, null as InvcDate, null as Rep1Id, null as Rep2Id,      
  null as DiscDueDate,      
null as NetDueDate,      
  null as  TaxSubtotal , null as NonTaxSubtotal,      
  null as SalesTax, null as Freight, null as Misc, null as TotCost,       
  null as TotPmtAmt, null as TaxAmtAdj,      
  null as TaxAdj, null as CustPONum, null as CurrencyID,       
  null as InvcNum, null as CurrMask ,      
  null as PostalCodeMask, null as ShipToPostalCodeMask, min(AlpTransId) as TransId,       
  null as ExchRate, null as [Name],       
  null as SiteFirstName, null as SiteName, null as SiteAttn, null as SiteAddr1,       
  null as SiteAddr2, null as SiteCity, null as SiteRegion, null as SiteCountry,       
  null as SitePostalCode, null as AlpMailSiteYN, null as CustFirstName, null as SiteId,      
      
  --EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits Record Count      
  (select isnull(sum(reccount),0) from       
  (      
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
  Select count(HP.CustId) as reccount      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS      
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end      
  Select count(AOI.CustId) as reccount      
   from tblArOpenInvoice AOI      
   where AOI.CustID = @CustId and InvcNum = @InvcNum    
 --mah 10/19/15:  
   and (AOI.TransID IS NULL OR AOI.TransID <> @TransID  )    
   and RecType < 0 and amt<>0 --and amtfgn<>0      
  union all      
   Select count(CustId) as reccount      
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = @CustId       
    and tblArTransHeader.InvcNum = @InvcNum       
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
 having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  union all      
   Select  count(CRH.CustId) as reccount      
   from tblArCashRcptDetail CRD inner join tblArCashRcptHeader CRH      
   on CRH.RcptHeaderID = CRD.RcptHeaderID      
   INNER JOIN tblArPmtMethod PM ON CRH.PmtMethodID = PM.PmtMethodID      
   where CRH.CustID = @CustId and CRD.InvcNum = @InvcNum      
   and CRD.PmtAmt > 0) as SubRecCount      
   )  as SubRecCount,      
      
  (select isnull(SUM(Paymentamt),0) from      
  (       
         
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
  Select case when @CboBase=1 Then sum(PmtAmt) else sum(PmtAmtFgn) end as PaymentAmt      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end       
  Select  case when @CboBase=1 Then sum(Amt) else sum(AmtFgn) end as PaymentAmt      
   from tblArOpenInvoice where       
   CustID = @CustId and       
   InvcNum = @InvcNum     
   --mah 10/19/15:  
   and (TransID IS NULL OR TransID <> @TransID)      
   and RecType < 0      
   GROUP BY CustId, InvcNum      
   having sum(Amt)<>0 --and sum(amtfgn)<>0      
  UNION all      
  Select case when @CboBase=1 Then SUM(QtyOrdSell  *  UnitPriceSell) else SUM(QtyOrdSell  *  UnitPriceSellFgn) end as PaymentAmt       
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = @CustId       
    and tblArTransHeader.InvcNum = @InvcNum       
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   GROUP BY CustId, InvcNum      
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  UNION all      
  SELECT case when @CboBase=1 Then SUM(tblArCashRcptDetail.PmtAmt) else SUM(tblArCashRcptDetail.PmtAmtFgn) end as PaymentAmt      
   from tblArCashRcptDetail inner join tblArCashRcptHeader       
   on tblArCashRcptHeader.RcptHeaderID = tblArCashRcptDetail.RcptHeaderID      
   where       
   tblArCashRcptDetail.PmtAmt > 0 and       
   tblArCashRcptHeader.CustID = @CustId and       
   tblArCashRcptDetail.InvcNum = @InvcNum      
  ) as AppliedCredits      
  ) as PaymentAmtTotal,      
      
  'PartID1' as PartId, null as EntryNum,       
  'PartDesc1'  as PartDesc,       
  'PartAddnlDesc1' as AddnlDesc, null as TaxClass,       
  0 as QtyOrdSell, null as UnitsSell, null as UnitsBase, 0 as QtyShipBase, 0 as QtyShipSell, 0 as QtyBackordSell, 0 as PriceCode,       
  0 as UnitPriceSell1,       
  0 as UnitCostSell1,       
  null as PartType, null as LottedYn      
  ,AOI.CustId,AlpSiteId as SiteID,InvcNum as InvoiceNum,      
  min(AlpTransId) as TransId,1 as Source,cast(1 as bit) as PostedYn,      
  AOI.PmtMethodId as PaymentMethodID, CheckNum,      
  --case when CheckNum is null then PM.[Desc] else PM.[Desc] + '-' + CheckNum end as [Description],  --'HERE-3' as [Description], --    
   case when AOI.RecType = -1 then 'CREDIT MEMO'    
    when AOI.RecType = -2 then     
     CASE WHEN CheckNum is null then PM.[Desc]     
      else PM.[Desc] + ' - #' + CheckNum     
     END    
  when AOI.RecType = 1 then 'CREDIT'    
  end as [Description],     
  TransDate as PaymentDate,       
  case @CboBase       
   when 0 then sum(AmtFgn)        
   when 1 then sum(Amt)      
  End      
  as PaymentAmt       
 from ALP_tblArOpenInvoice_view AOI      
 left outer JOIN tblArPmtMethod PM ON AOI.PmtMethodID = PM.PmtMethodID      
 where AOI.CustID = @CustId and InvcNum = @InvcNum      
 and RecType < 0    
 --mah 02/09/15 --mah 01/26/15 :  
 --mah 10/19/15:    
 and (AOI.TransID IS NULL  OR AOI.TransID <> @TransId   )   
 GROUP BY      
  AOI.CustId,AlpSiteId, InvcNum, RecType,      
  AOI.PmtMethodId, CheckNum,    
  --case when CheckNum is null then PM.[Desc] else PM.[Desc] + '-' + CheckNum end,    
     case when AOI.RecType = -1 then 'CREDIT MEMO'    
    when AOI.RecType = -2 then     
     CASE WHEN CheckNum is null then PM.[Desc]     
      else PM.[Desc] + ' - #' + CheckNum     
     END    
  when AOI.RecType = 1 then 'CREDIT'    
  end ,      
  TransDate      
UNION ALL      
--============================================================================================      
--EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits for Source = 2      
--============================================================================================      
Select      
--mah 01/26/15 TEST    
'S-THIRD' as Step,          
  'S' AS TableType,      
  null as UseLogo,      
  null as Logo,      
  null as PrintStatus, null as CustId, null as Attn, null as CustName, null as Contact, null as Addr1, null as Addr2, null as City, null as Region,       
  null as Country, null as PostalCode, null as ShipToID, null as ShipToName, null as ShipToAddr1, null as ShipToAddr2, null as ShipToCity,       
  null as ShipToCountry, null as ShipToRegion, null as ShipToPostalCode, null as ShipVia, null as TermsCode, null as TermDesc,       
  null as DiscDayOfMonth, null as DiscDays, null as DiscMinDays, null as NetDueDays, null as TransType, null as OrderDate, null as ShipDate,       
  null as ShipNum, null as InvcDate, null as Rep1Id, null as Rep2Id,      
  null as DiscDueDate,      
  null as NetDueDate,      
  tblArTransHeader.TaxSubtotalFgn as  TaxSubtotal , tblArTransHeader.NonTaxSubtotalFgn as  NonTaxSubtotal,     
   --mah 04/15/15 - added SalesTax adjustment value , so Sales Tax going to all report formats is already total amount     
   case when @CboBase=1 Then tblArTransHeader.SalesTax + tblArTransHeader.TaxAmtAdj     
     else tblArTransHeader.SalesTaxFgn  + tblArTransHeader.TaxAmtAdjFgn  end as SalesTax,        
  -- --mah 01/27/15: need to revert back tax calc      
  --case when @CboBase=1 Then tblArTransHeader.SalesTax else tblArTransHeader.SalesTaxFgn end as SalesTax, --tblArTransHeader.SalesTaxFgn as SalesTax,     
  tblArTransHeader.FreightFgn as Freight, tblArTransHeader.MiscFgn as Misc, null as TotCost,       
  null as TotPmtAmt, null as TaxAmtAdj,      
  null as TaxAdj, null as CustPONum, null as CurrencyID,       
  null as InvcNum, null as CurrMask ,      
  null as PostalCodeMask, null as ShipToPostalCodeMask, min(ALP_tblArTransDetail_view.TransId) as TransId,       
  null as ExchRate, null as [Name],       
  null as SiteFirstName, null as SiteName, null as SiteAttn, null as SiteAddr1,       
  null as SiteAddr2, null as SiteCity, null as SiteRegion, null as SiteCountry,       
  null as SitePostalCode, null as AlpMailSiteYN, null as CustFirstName, null as SiteId,      
      
  --EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits Record Count      
  (select isnull(sum(reccount),0) from       
  (      
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
  Select count(HP.CustId) as reccount      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end      
  Select count(AOI.CustId) as reccount      
   from tblArOpenInvoice AOI      
   where AOI.CustID = @CustId and InvcNum = @InvcNum      
 --mah 10/19/15:  
   and (AOI.TransID IS NULL  OR AOI.TransID <> @TransID)      
   and RecType < 0 and amt<>0 --and amtfgn<>0      
  union all      
   Select count(CustId) as reccount      
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = @CustId       
    and tblArTransHeader.InvcNum = @InvcNum       
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  union all      
   Select  count(CRH.CustId) as reccount      
   from tblArCashRcptDetail CRD inner join tblArCashRcptHeader CRH      
   on CRH.RcptHeaderID = CRD.RcptHeaderID      
   INNER JOIN tblArPmtMethod PM ON CRH.PmtMethodID = PM.PmtMethodID      
   where CRH.CustID = @CustId and CRD.InvcNum = @InvcNum      
   and CRD.PmtAmt > 0) as SubRecCount      
   )  as SubRecCount,      
      
  (select isnull(SUM(Paymentamt),0) from      
  (       
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
   Select case when @CboBase=1 Then sum(PmtAmt) else sum(PmtAmtFgn) end as PaymentAmt      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end        
   Select  case when @CboBase=1 Then sum(Amt) else sum(AmtFgn) end as PaymentAmt      
   from tblArOpenInvoice where       
   CustID = @CustId and       
   InvcNum = @InvcNum     
   --mah 10/19/15:  
   and (TransID IS NULL OR TransID <> @TransID )      
   and RecType < 0      
   GROUP BY CustId, InvcNum      
   having sum(Amt)<>0 --and sum(amtfgn)<>0      
  UNION all      
  Select case when @CboBase=1 Then SUM(QtyOrdSell  *  UnitPriceSell) else SUM(QtyOrdSell  *  UnitPriceSellFgn) end as PaymentAmt       
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = @CustId       
    and tblArTransHeader.InvcNum = @InvcNum       
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   GROUP BY CustId, InvcNum      
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  UNION all      
  SELECT case when @CboBase=1 Then SUM(tblArCashRcptDetail.PmtAmt) else SUM(tblArCashRcptDetail.PmtAmtFgn) end as PaymentAmt      
   from tblArCashRcptDetail inner join tblArCashRcptHeader       
   on tblArCashRcptHeader.RcptHeaderID = tblArCashRcptDetail.RcptHeaderID      
   where       
   tblArCashRcptDetail.PmtAmt > 0 and       
   tblArCashRcptHeader.CustID = @CustId and       
   tblArCashRcptDetail.InvcNum = @InvcNum      
  ) as AppliedCredits      
  ) as PaymentAmtTotal,      
      
      
  'PartID2' as PartId, null as EntryNum,       
  'PartDesc2'  as PartDesc,       
  'PartAddnlDesc2' as AddnlDesc, null as TaxClass,       
  0 as QtyOrdSell, null as UnitsSell, null as UnitsBase, 0 as QtyShipBase, 0 as QtyShipSell, 0 as QtyBackordSell, 0 as PriceCode,       
  0 as UnitPriceSell1,       
  0 as UnitCostSell1,       
  null as PartType, null as LottedYn,      
  CustId,ALP_tblArTransDetail_view.AlpSiteId as SiteID,InvcNum as InvoiceNum,      
  min(ALP_tblArTransDetail_view.TransId) as TransId,2 as Source,cast(0 as bit) as PostedYn,      
  'Credit' as PaymentMethodID, '' as CheckNum,      
--mah 061611: cleaned up description displayed:      
--  'credit-' + case when isnull(PartID,'') != '' then isnull(PartID,'') + ' - ' else '' end +      
--  case when isnull([Desc],'') != '' then isnull([Desc],'') + ' - ' else '' end +      
--  cast(isnull(AddnlDesc,'') as varchar(255)) as [Description],      
  'Credit - ' + case when isnull([Desc],'') != ''       
      then isnull([Desc],'') + ' - '       
      else isnull(PartID,'') + ' - ' end +      
     cast(isnull(AddnlDesc,'') as varchar(255)) as [Description],      
  InvcDate as PaymentDate,       
  SUM(QtyOrdSell  *        
   case @CboBase       
    when 0 then UnitPriceSellFgn       
    when 1 then UnitPriceSell      
  End)  as PaymentAmt       
 from ALP_tblArTransDetail_view inner join tblArTransHeader       
 on tblArTransHeader.TransId = ALP_tblArTransDetail_view.TransId       
 where tblArTransHeader.CustID = @CustId       
  and tblArTransHeader.InvcNum = @InvcNum      
  and tblArTransHeader.TransID <> @TransID      
  and tblArTransHeader.TransType < 0       
 GROUP BY      
  tblArTransHeader.TaxSubtotalFgn, tblArTransHeader.NonTaxSubtotalFgn,    
  --mah 04/15/15:    
  case when @CboBase=1 Then tblArTransHeader.SalesTax + tblArTransHeader.TaxAmtAdj else tblArTransHeader.SalesTaxFgn  + tblArTransHeader.TaxAmtAdjFgn end,     
  ----tblArTransHeader.SalesTaxFgn,     
  ----mah 01/27/15: need to revert back tax calc      
  --case when @CboBase=1 Then tblArTransHeader.SalesTax else tblArTransHeader.SalesTaxFgn end,     
  tblArTransHeader.FreightFgn, tblArTransHeader.MiscFgn,      
  CustId,ALP_tblArTransDetail_view.AlpSiteId, InvcNum,      
  'Credit - ' + case when isnull([Desc],'') != ''       
      then isnull([Desc],'') + ' - '       
      else isnull(PartID,'') + ' - ' end +      
     cast(isnull(AddnlDesc,'') as varchar(255)), InvcDate      
UNION ALL      
--============================================================================================      
--EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits for Source = 3      
--============================================================================================      
Select      
--mah 01/26/15 TEST    
'S-Fourth' as Step,          
  'S' AS TableType,      
  null as UseLogo,      
  null as Logo,      
  null as PrintStatus, null as CustId, null as Attn, null as CustName, null as Contact, null as Addr1, null as Addr2, null as City, null as Region,       
  null as Country, null as PostalCode, null as ShipToID, null as ShipToName, null as ShipToAddr1, null as ShipToAddr2, null as ShipToCity,       
  null as ShipToCountry, null as ShipToRegion, null as ShipToPostalCode, null as ShipVia, null as TermsCode, null as TermDesc,       
  null as DiscDayOfMonth, null as DiscDays, null as DiscMinDays, null as NetDueDays, null as TransType, null as OrderDate, null as ShipDate,       
  null as ShipNum, null as InvcDate, null as Rep1Id, null as Rep2Id,      
  null as DiscDueDate,      
  null as NetDueDate,      
  null as  TaxSubtotal , null as NonTaxSubtotal,      
  null as SalesTax, null as Freight, null as Misc, null as TotCost,       
  null as TotPmtAmt, null as TaxAmtAdj,      
  null as TaxAdj, null as CustPONum, null as CurrencyID,       
  null as InvcNum, null as CurrMask ,      
  null as PostalCodeMask, null as ShipToPostalCodeMask, min(InvcTransId) as  TransId,       
  null as ExchRate, null as [Name],       
  null as SiteFirstName, null as SiteName, null as SiteAttn, null as SiteAddr1,       
  null as SiteAddr2, null as SiteCity, null as SiteRegion, null as SiteCountry,       
  null as SitePostalCode, null as AlpMailSiteYN, null as CustFirstName, null as SiteId,      
      
  --EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits Record Count      
  (select isnull(sum(reccount),0) from       
  (      
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
  Select count(HP.CustId) as reccount      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end      
  Select count(AOI.CustId) as reccount      
   from tblArOpenInvoice AOI      
   where AOI.CustID = @CustId and InvcNum = @InvcNum       
 --mah 10/19/15:      
   and (AOI.TransID IS NULL OR AOI.TRansID <> @TransID )      
   and RecType < 0 and amt<>0 --and amtfgn<>0      
  union all      
   Select count(CustId) as reccount      
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = @CustId       
    and tblArTransHeader.InvcNum = @InvcNum       
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  union all      
   Select  count(CRH.CustId) as reccount      
  from tblArCashRcptDetail CRD inner join tblArCashRcptHeader CRH      
  on CRH.RcptHeaderID = CRD.RcptHeaderID      
  INNER JOIN tblArPmtMethod PM ON CRH.PmtMethodID = PM.PmtMethodID      
  where CRH.CustID = @CustId and CRD.InvcNum = @InvcNum      
   and CRD.PmtAmt > 0) as SubRecCount      
   )  as SubRecCount,      
      
  (select isnull(SUM(Paymentamt),0) from      
  (       
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
   Select case when @CboBase=1 Then sum(PmtAmt) else sum(PmtAmtFgn) end as PaymentAmt      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end        
   Select  case when @CboBase=1 Then sum(Amt) else sum(AmtFgn) end as PaymentAmt      
   from tblArOpenInvoice where       
   CustID = @CustId and       
   InvcNum = @InvcNum     
   --mah 10/19/15:  
   and (TransID IS NULL OR TransID <> @TransID   )   
   and RecType < 0      
   GROUP BY CustId, InvcNum      
   having sum(Amt)<>0 --and sum(amtfgn)<>0      
  UNION all      
  Select case when @CboBase=1 Then SUM(QtyOrdSell  *  UnitPriceSell) else SUM(QtyOrdSell  *  UnitPriceSellFgn) end as PaymentAmt       
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = @CustId       
    and tblArTransHeader.InvcNum = @InvcNum       
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   GROUP BY CustId, InvcNum      
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  UNION all      
  SELECT case when @CboBase=1 Then SUM(tblArCashRcptDetail.PmtAmt) else SUM(tblArCashRcptDetail.PmtAmtFgn) end as PaymentAmt      
   from tblArCashRcptDetail inner join tblArCashRcptHeader       
   on tblArCashRcptHeader.RcptHeaderID = tblArCashRcptDetail.RcptHeaderID      
   where       
   tblArCashRcptDetail.PmtAmt > 0 and       
   tblArCashRcptHeader.CustID = @CustId and       
   tblArCashRcptDetail.InvcNum = @InvcNum      
  ) as AppliedCredits      
  ) as PaymentAmtTotal,      
      
  'PartID3' as PartId, null as EntryNum,       
  'PartDesc3'  as PartDesc,       
  'PartAddnlDesc3' as AddnlDesc, null as TaxClass,       
  0 as QtyOrdSell, null as UnitsSell, null as UnitsBase, 0 as QtyShipBase, 0 as QtyShipSell, 0 as QtyBackordSell, 0 as PriceCode,       
  0 as UnitPriceSell1,       
  0 as UnitCostSell1,       
  null as PartType, null as LottedYn,      
  CRH.CustID,CRD.AlpSiteId as SiteID,InvcNum as InvoiceNum,      
  min(InvcTransId) as TransId,3 as Source,cast(0 as bit)  as PostedYn,      
  CRH.PmtMethodId as PaymentMethodID, CheckNum,      
  case when CheckNum is null then PM.[Desc] else      
  case when note is null then PM.[Desc] + '-' + CheckNum else PM.[Desc] + '-' + CheckNum + '-' + note end end as [Description],      
  CRH.PmtDate as PaymentDate,       
  SUM(case @CboBase       
   when 0 then CRD.PmtAmtFgn       
   when 1 then CRD.PmtAmt      
  End      
  )  as PaymentAmt      
 from ALP_tblArCashRcptDetail_View CRD inner join tblArCashRcptHeader CRH      
 on CRH.RcptHeaderID = CRD.RcptHeaderID      
 INNER JOIN tblArPmtMethod PM ON CRH.PmtMethodID = PM.PmtMethodID      
 where CRH.CustID = @CustId and CRD.InvcNum = @InvcNum      
  and CRD.PmtAmt > 0       
 GROUP BY      
  CRH.CustID,CRD.AlpSiteId, InvcNum,      
  CRH.PmtMethodId, CheckNum,      
  case when CheckNum is null then PM.[Desc] else      
  case when note is null then PM.[Desc] + '-' + CheckNum else PM.[Desc] + '-' + CheckNum + '-' + note end end ,      
  CRH.PmtDate      
END      
      
ELSE      
--============================================================================================      
-- Execute for History Invoice Print      
--============================================================================================      
BEGIN      
SELECT      
--mah 01/26/15 TEST    
'D-FIRST-H' as Step,           
  'D' AS TableType,      
  (select UseLogo from sys.dbo.tblSmCompInfo where CompID = @CompID) as UseLogo,      
  (select TEXTPTR(Logo) from sys.dbo.tblSmCompInfo where CompID = @CompID) as Logo,      
  --0,'',      
  h.PrintStatus, c.CustId, c.Attn, c.CustName, c.Contact, c.Addr1, c.Addr2, c.City, c.Region,       
  c.Country,    
  --mah 021915-format postalcode    
  CASE WHEN LEN(c.PostalCode) <= 5 THEN c.PostalCode    
  ELSE LEFT(c.PostalCode,5) + '-'     
  + SUBSTRING(c.PostalCode, 6,LEN(c.PostalCode) - 5)    
  END AS PostalCode,      
  --c.PostalCode,     
  h.ShipToID, h.ShipToName, h.ShipToAddr1, h.ShipToAddr2, h.ShipToCity,       
  h.ShipToCountry, h.ShipToRegion, h.ShipToPostalCode, h.ShipVia, h.TermsCode, t.[Desc] AS TermDesc,       
  t.DiscDayOfMonth, t.DiscDays, t.DiscMinDays, t.NetDueDays, h.TransType, h.OrderDate, h.ShipDate,       
  h.ShipNum, h.InvcDate, h.Rep1Id, h.Rep2Id,      
  h.DiscDueDate,      
  h.NetDueDate,      
  case when @CboBase=1 Then h.TaxSubtotal else h.TaxSubtotalFgn end as TaxSubtotal ,       
  case when @CboBase=1 Then h.NonTaxSubtotal else h.NonTaxSubtotalFgn end as NonTaxSubtotal,    
  ----mah 05/22/14 - sales tax added adj to make correct total    
  --case when @CboBase=1 Then h.SalesTax + h.TaxAmtAdj else h.SalesTaxFgn  + h.TaxAmtAdjFgn end as SalesTax,       
  --case when @CboBase=1 Then h.SalesTax else h.SalesTaxFgn end as SalesTax,     
  --mah 04/15/15 - revert sales tax changes.  This is correct ONLY for HISTORY ( because Posting has already adjusted these amounts:    
  case when @CboBase=1 Then h.SalesTax else h.SalesTaxFgn end as SalesTax,       
  case when @CboBase=1 Then h.Freight else h.FreightFgn end as Freight,       
  case when @CboBase=1 Then h.Misc else h.MiscFgn end as Misc,       
  case when @CboBase=1 Then h.TotCost else h.TotCostFgn end as TotCost,       
  case when @CboBase=1 Then h.TotPmtAmt else h.TotPmtAmtFgn end as TotPmtAmt,       
  case when @CboBase=1 Then h.TaxAmtAdj else h.TaxAmtAdjFgn end as TaxAmtAdj,      
  h.TaxAdj, h.CustPONum, h.CurrencyID,       
  h.InvcNum, y.CurrMask ,      
  s.PostalCodeMask, ShipTotblSmCountry.PostalCodeMask AS ShipToPostalCodeMask, h.TransId,       
  h.ExchRate, s.[Name],       
  ALP_tblArAlpSite.AlpFirstName AS SiteFirstName, ALP_tblArAlpSite.SiteName, ALP_tblArAlpSite.Attn AS SiteAttn, ALP_tblArAlpSite.Addr1 AS SiteAddr1,       
  ALP_tblArAlpSite.Addr2 AS SiteAddr2, ALP_tblArAlpSite.City AS SiteCity, ALP_tblArAlpSite.Region AS SiteRegion, ALP_tblArAlpSite.Country AS SiteCountry,       
  --ALP_tblArAlpSite.PostalCode AS SitePostalCode,    
  --mah 02/19/15 - format postalcode    
  CASE WHEN LEN(ALP_tblArAlpSite.PostalCode) <= 5 THEN ALP_tblArAlpSite.PostalCode    
  ELSE LEFT(ALP_tblArAlpSite.PostalCode,5) + '-'     
  + SUBSTRING(ALP_tblArAlpSite.PostalCode, 6,LEN(ALP_tblArAlpSite.PostalCode) - 5)    
  END AS SitePostalCode,     
  h.AlpMailSiteYN, c.AlpFirstName AS CustFirstName,       
  isnull(ALP_tblArAlpSite.SiteId,0) as SiteId,      
  --EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits Record Count      
  (select isnull(sum(reccount),0) from       
  (      
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
  Select count(HP.CustId) as reccount      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end      
  Select count(AOI.CustId) as reccount      
   from tblArOpenInvoice AOI      
   where AOI.CustID = c.CustId and InvcNum = h.InvcNum      
 --mah 10/19/15:     
   and (AOI.TransID IS NULL OR AOI.TransID <> @TransID )     
   and RecType < 0 and amt<>0 --and amtfgn<>0       
  union all      
   Select count(CustId) as reccount      
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = c.CustId       
    and tblArTransHeader.InvcNum = h.InvcNum       
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  union all      
   Select  count(CRH.CustId) as reccount      
   from tblArCashRcptDetail CRD inner join tblArCashRcptHeader CRH      
   on CRH.RcptHeaderID = CRD.RcptHeaderID      
   INNER JOIN tblArPmtMethod PM ON CRH.PmtMethodID = PM.PmtMethodID      
   where CRH.CustID = c.CustId and CRD.InvcNum = h.InvcNum      
   and CRD.PmtAmt > 0) as SubRecCount      
   )  as SubRecCount,      
      
  (select isnull(SUM(Paymentamt),0) from      
  (       
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
  Select case when @CboBase=1 Then sum(PmtAmt) else sum(PmtAmtFgn) end as PaymentAmt      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end        
  Select  case when @CboBase=1 Then sum(tblArOpenInvoice.Amt) else sum(tblArOpenInvoice.AmtFgn) end as PaymentAmt      
   from tblArOpenInvoice   
   where  tblArOpenInvoice.CustID = c.CustId and tblArOpenInvoice.InvcNum = h.InvcNum     
   --mah 10/19/15:    
   and (tblArOpenInvoice.TransID IS NULL OR tblArOpenInvoice.TransID <> @TransID  )   
   and tblArOpenInvoice.RecType <> 1     
   --   where AOI.CustID = c.CustId and InvcNum = h.InvcNum      
   ----WHY??    
   ----mah 06/16/11 - removed follwoing criteria:      
   ----and AOI.AlpTransID <> @TransID      
   --and RecType < 0 and amt<>0 --and amtfgn<>0   
   GROUP BY tblArOpenInvoice.CustId, tblArOpenInvoice.InvcNum      
   having sum(tblArOpenInvoice.Amt)<>0 --and sum(amtfgn)<>0      
  UNION all      
  Select case when @CboBase=1 Then SUM(QtyOrdSell  *  UnitPriceSell) else SUM(QtyOrdSell  *  UnitPriceSellFgn) end as PaymentAmt       
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = c.CustId       
    and tblArTransHeader.InvcNum = h.InvcNum       
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   GROUP BY CustId, InvcNum      
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  UNION all      
  SELECT case when @CboBase=1 Then SUM(tblArCashRcptDetail.PmtAmt) else SUM(tblArCashRcptDetail.PmtAmtFgn) end as PaymentAmt      
   from tblArCashRcptDetail inner join tblArCashRcptHeader       
   on tblArCashRcptHeader.RcptHeaderID = tblArCashRcptDetail.RcptHeaderID      
   where       
   tblArCashRcptDetail.PmtAmt > 0 and       
   tblArCashRcptHeader.CustID = c.CustId  and       
   tblArCashRcptDetail.InvcNum = h.InvcNum      
  ) as AppliedCredits      
  ) as PaymentAmtTotal,      
  isnull(d.[PartId],'') as PartId, d.EntryNum,       
  isnull(d.[Desc],'') AS PartDesc,       
  isnull(d.[AddnlDesc],'') as AddnlDesc, d.TaxClass,       
  d.QtyOrdSell, d.UnitsSell, d.UnitsBase, d.QtyShipBase, d.QtyShipSell, d.QtyBackordSell, 0 AS PriceCode,       
  case when @CboBase=1 Then UnitPriceSell else UnitPriceSellFgn end AS UnitPriceSell1,       
  case when @CboBase=1 Then UnitCostSell else UnitCostSellFgn end AS UnitCostSell1,       
  d.PartType, d.LottedYn,      
  null as CustId, null as  SiteID, h.InvcNum as InvoiceNum,      
  null as TransId,null as Source,null as PostedYn,      
  null as PaymentMethodID, null as CheckNum,      
  null as [Description], --'HERE-1' as [Description],  --     
  null as PaymentDate,       
  null as PaymentAmt       
 FROM (ALP_tblArCust_view c (NOLOCK) LEFT JOIN sys.dbo.tblSmCountry s (NOLOCK) ON c.Country = s.Country)       
  RIGHT JOIN (((sys.dbo.tblSmCountry AS ShipTotblSmCountry RIGHT JOIN (((ALP_tblArHistHeader_view  h (NOLOCK)       
  LEFT JOIN sys.dbo.tblSmCurrency y (NOLOCK) ON h.CurrencyID = y.CurrId)      
  LEFT JOIN tblArTermsCode t (NOLOCK) ON h.TermsCode = t.TermsCode)      
  LEFT JOIN ALP_tblArAlpSite(NOLOCK) ON h.AlpSiteID = ALP_tblArAlpSite.SiteID)      
  ON ShipTotblSmCountry.Country = h.ShipToCountry) INNER JOIN tblSmTaxGroup x (NOLOCK)       
  ON h.TaxGrpID = x.TaxGrpID))ON c.CustId = h.CustId LEFT OUTER JOIN tblArHIstDetail d (NOLOCK)       
  --MAH 08/06/11 - added PostRun to select correct detail records      
  ON d.TransId = h.TransId  AND d.PostRun = h.PostRun      
  --ON d.TransId = h.TransId      
 WHERE h.TransId = @TransID      
 --mah - changes to ignore additional new record types in Trav11 ( sales tax, freight, misc, gainloss )    
 and d.EntryNum >= 0    
 --MAH 08/06/11 - added custID selection criteria for hist transaction selection      
  and h.CustID = @CustID      
UNION ALL      
--============================================================================================      
--EFI 1918 08/06/11 - Added By MAH to get hist payments for fully paid invoices no longer in OpenInvoice file      
--  Source = 0      
--============================================================================================      
Select        
--mah 01/26/15 TEST    
'S-FIRST-H' as Step,        
  'S' AS TableType,      
  null as UseLogo,      
  null as Logo,      
  null as PrintStatus, null as CustId, null as Attn, null as CustName, null as Contact, null as Addr1, null as Addr2, null as City, null as Region,       
  null as Country, null as PostalCode, null as ShipToID, null as ShipToName, null as ShipToAddr1, null as ShipToAddr2, null as ShipToCity,       
  null as ShipToCountry, null as ShipToRegion, null as ShipToPostalCode, null as ShipVia, null as TermsCode, null as TermDesc,       
  null as DiscDayOfMonth, null as DiscDays, null as DiscMinDays, null as NetDueDays, null as TransType, null as OrderDate, null as ShipDate,       
  null as ShipNum, null as InvcDate, null as Rep1Id, null as Rep2Id,      
  null as DiscDueDate,      
  null as NetDueDate,      
  null as TaxSubtotal , null as NonTaxSubtotal,      
  null as SalesTax, null as Freight, null as Misc, null as TotCost,       
  null as TotPmtAmt, null as TaxAmtAdj,      
  null as TaxAdj, null as CustPONum, null as CurrencyID,       
  null as InvcNum, null as CurrMask ,      
  null as PostalCodeMask, null as ShipToPostalCodeMask, min(TransId) as TransId,       
  null as ExchRate, null as [Name],       
  null as SiteFirstName, null as SiteName, null as SiteAttn, null as SiteAddr1,       
  null as SiteAddr2, null as SiteCity, null as SiteRegion, null as SiteCountry,       
  null as SitePostalCode, null as AlpMailSiteYN, null as CustFirstName, null as SiteId,      
      
  --EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits Record Count      
  (select isnull(sum(reccount),0) from       
  (      
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
  Select count(HP.CustId) as reccount      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end      
  Select count(AOI.CustId) as reccount      
   from tblArOpenInvoice AOI      
   where AOI.CustID = @CustId and InvcNum = @InvcNum     
 --mah 10/19/15:     
   and (AOI.TransID IS NULL OR  AOI.TransID <> @TransID )     
   and AOI.RecType <> 0 and amt<>0 --and amtfgn<>0       
  union all      
   Select count(CustId) as reccount      
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = @CustId       
    and tblArTransHeader.InvcNum = @InvcNum      
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  union all      
   Select  count(CRH.CustId) as reccount      
  from tblArCashRcptDetail CRD inner join tblArCashRcptHeader CRH      
  on CRH.RcptHeaderID = CRD.RcptHeaderID      
  INNER JOIN tblArPmtMethod PM ON CRH.PmtMethodID = PM.PmtMethodID      
  where CRH.CustID = @CustId and CRD.InvcNum = @InvcNum      
   and CRD.PmtAmt > 0) as SubRecCount      
   )  as SubRecCount,      
      
  (select isnull(SUM(Paymentamt),0) from      
  (       
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
  Select case when @CboBase=1 Then sum(PmtAmt) else sum(PmtAmtFgn) end as PaymentAmt      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end        
  Select  case when @CboBase=1 Then sum(Amt) else sum(AmtFgn) end as PaymentAmt      
   from tblArOpenInvoice where       
   CustID = @CustId and       
   InvcNum = @InvcNum     
   --mah 10/19/15:  
   and (TransID IS NULL OR TransID <> @TransID )     
   and RecType < 0      
   GROUP BY CustId, InvcNum      
   having sum(Amt)<>0 --and sum(amtfgn)<>0      
  UNION all      
  Select case when @CboBase=1 Then SUM(QtyOrdSell  *  UnitPriceSell) else SUM(QtyOrdSell  *  UnitPriceSellFgn) end as PaymentAmt       
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = @CustId       
    and tblArTransHeader.InvcNum = @InvcNum       
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   GROUP BY CustId, InvcNum      
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  UNION all      
  SELECT case when @CboBase=1 Then SUM(tblArCashRcptDetail.PmtAmt) else SUM(tblArCashRcptDetail.PmtAmtFgn) end as PaymentAmt      
   from tblArCashRcptDetail inner join tblArCashRcptHeader       
   on tblArCashRcptHeader.RcptHeaderID = tblArCashRcptDetail.RcptHeaderID      
   where       
   tblArCashRcptDetail.PmtAmt > 0 and       
   tblArCashRcptHeader.CustID = @CustId and       
   tblArCashRcptDetail.InvcNum = @InvcNum      
  ) as AppliedCredits      
  ) as PaymentAmtTotal,      
      
  'PartID1' as PartId, null as EntryNum,       
  'PartDesc1'  as PartDesc,       
  'PartAddnlDesc1' as AddnlDesc, null as TaxClass,       
  0 as QtyOrdSell, null as UnitsSell, null as UnitsBase, 0 as QtyShipBase, 0 as QtyShipSell, 0 as QtyBackordSell, 0 as PriceCode,       
  0 as UnitPriceSell1,       
  0 as UnitCostSell1,       
  null as PartType, null as LottedYn      
  ,HP.CustId,0 as SiteID,InvcNum as InvoiceNum,      
  min(TransId) as TransId,0 as Source,cast(1 as bit) as PostedYn,      
  HP.PmtMethodId as PaymentMethodID, CheckNum,      
  --case when CheckNum is null then PM.[Desc] else PM.[Desc] + ' - #' + CheckNum end as [Description],   --'Here-4' as [Description], --    
   case when CheckNum is null     
  --then PM.[Desc]     
  then  case when note is null     
   then PM.[Desc]     
   else PM.[Desc] + '-' + note     
  end     
  else  case when note is null     
   then PM.[Desc] + '-' + CheckNum     
   else PM.[Desc] + '-' + CheckNum + '-' + note     
  end     
  end as [Description],      
  PmtDate as PaymentDate,       
  case @CboBase       
   when 0 then sum(PmtAmtFgn)        
   when 1 then sum(PmtAmt)      
  End      
  as PaymentAmt       
 from tblArHistPmt HP      
 left outer JOIN tblArPmtMethod PM ON HP.PmtMethodID = PM.PmtMethodID      
 where HP.CustID = @CustId and HP.InvcNum = @InvcNum      
  and NOT EXISTS (Select InvcNum from tblArOpenInvoice where InvcNum = @InvcNum and CustID = @CustID)      
 GROUP BY      
  HP.CustId,HP.InvcNum,      
  HP.PmtMethodId, HP.CheckNum,      
  --case when HP.CheckNum is null then PM.[Desc] else PM.[Desc] + ' - #' + HP.CheckNum end,    
     case when CheckNum is null     
  --then PM.[Desc]     
  then  case when note is null     
   then PM.[Desc]     
   else PM.[Desc] + '-' + note     
  end     
  else  case when note is null     
   then PM.[Desc] + '-' + CheckNum     
   else PM.[Desc] + '-' + CheckNum + '-' + note     
  end     
  end,      
  HP.PmtDate      
UNION ALL      
--============================================================================================      
--EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits for Source = 1      
--============================================================================================      
Select      
--mah 01/26/15 TEST    
'S-SECOND-H' as Step,       
  'S' AS TableType,      
  null as UseLogo,      
  null as Logo,      
  null as PrintStatus, null as CustId, null as Attn, null as CustName, null as Contact, null as Addr1, null as Addr2, null as City, null as Region,       
  null as Country, null as PostalCode, null as ShipToID, null as ShipToName, null as ShipToAddr1, null as ShipToAddr2, null as ShipToCity,       
  null as ShipToCountry, null as ShipToRegion, null as ShipToPostalCode, null as ShipVia, null as TermsCode, null as TermDesc,     null as DiscDayOfMonth, null as DiscDays, null as DiscMinDays, null as NetDueDays, null as TransType, null as OrderDate,   
 
  null as ShipDate,       
  null as ShipNum, null as InvcDate, null as Rep1Id, null as Rep2Id,      
  null as DiscDueDate,      
  null as NetDueDate,      
  null as TaxSubtotal , null as NonTaxSubtotal,      
  null as SalesTax, null as Freight, null as Misc, null as TotCost,       
  null as TotPmtAmt, null as TaxAmtAdj,      
  null as TaxAdj, null as CustPONum, null as CurrencyID,       
  null as InvcNum, null as CurrMask ,      
  null as PostalCodeMask, null as ShipToPostalCodeMask, min(AlpTransId) as TransId,       
  null as ExchRate, null as [Name],       
  null as SiteFirstName, null as SiteName, null as SiteAttn, null as SiteAddr1,       
  null as SiteAddr2, null as SiteCity, null as SiteRegion, null as SiteCountry,       
  null as SitePostalCode, null as AlpMailSiteYN, null as CustFirstName, null as SiteId,      
      
  --EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits Record Count      
  (select isnull(sum(reccount),0) from       
  (      
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
  Select count(HP.CustId) as reccount      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end      
  Select count(AOI.CustId) as reccount      
   from tblArOpenInvoice AOI      
   where AOI.CustID = @CustId and InvcNum = @InvcNum    
   --mah 101515:     
   and (AOI.TransID IS NULL OR AOI.TransID <> @TransID )     
   and RecType < 0 and amt<>0 --and amtfgn<>0       
  union all      
   Select count(CustId) as reccount      
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = @CustId       
    and tblArTransHeader.InvcNum = @InvcNum      
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  union all      
   Select  count(CRH.CustId) as reccount      
  from tblArCashRcptDetail CRD inner join tblArCashRcptHeader CRH      
  on CRH.RcptHeaderID = CRD.RcptHeaderID      
  INNER JOIN tblArPmtMethod PM ON CRH.PmtMethodID = PM.PmtMethodID      
  where CRH.CustID = @CustId and CRD.InvcNum = @InvcNum      
   and CRD.PmtAmt > 0) as SubRecCount      
   )  as SubRecCount,      
      
  (select isnull(SUM(Paymentamt),0) from      
  (       
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
  Select case when @CboBase=1 Then sum(PmtAmt) else sum(PmtAmtFgn) end as PaymentAmt      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end        
  Select  case when @CboBase=1 Then sum(Amt) else sum(AmtFgn) end as PaymentAmt      
   from tblArOpenInvoice where       
   CustID = @CustId and       
   InvcNum = @InvcNum     
 --mah 10/19/15:     
 and (TransID IS NULL OR TransID <> @TransID )     
   and RecType < 0      
   GROUP BY CustId, InvcNum      
   having sum(Amt)<>0 --and sum(amtfgn)<>0      
  UNION all      
  Select case when @CboBase=1 Then SUM(QtyOrdSell  *  UnitPriceSell) else SUM(QtyOrdSell  *  UnitPriceSellFgn) end as PaymentAmt       
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = @CustId       
    and tblArTransHeader.InvcNum = @InvcNum       
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   GROUP BY CustId, InvcNum      
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  UNION all      
  SELECT case when @CboBase=1 Then SUM(tblArCashRcptDetail.PmtAmt) else SUM(tblArCashRcptDetail.PmtAmtFgn) end as PaymentAmt      
   from tblArCashRcptDetail inner join tblArCashRcptHeader       
   on tblArCashRcptHeader.RcptHeaderID = tblArCashRcptDetail.RcptHeaderID      
   where       
   tblArCashRcptDetail.PmtAmt > 0 and       
   tblArCashRcptHeader.CustID = @CustId and       
   tblArCashRcptDetail.InvcNum = @InvcNum      
  ) as AppliedCredits      
  ) as PaymentAmtTotal,      
      
  'PartID1' as PartId, null as EntryNum,       
  'PartDesc1'  as PartDesc,       
  'PartAddnlDesc1' as AddnlDesc, null as TaxClass,       
  0 as QtyOrdSell, null as UnitsSell, null as UnitsBase, 0 as QtyShipBase, 0 as QtyShipSell, 0 as QtyBackordSell, 0 as PriceCode,       
  0 as UnitPriceSell1,       
  0 as UnitCostSell1,       
  null as PartType, null as LottedYn      
  ,AOI.CustId,AlpSiteId as SiteID,InvcNum as InvoiceNum,      
  min(AlpTransId) as TransId,1 as Source,cast(1 as bit) as PostedYn,      
  AOI.PmtMethodId as PaymentMethodID, CheckNum,      
  --'Here-5' + AOI.RecType as [Description],     
  case when AOI.RecType = -1 then 'CREDIT MEMO'    
    when AOI.RecType = -2 then     
     CASE WHEN CheckNum is null then PM.[Desc]     
      else PM.[Desc] + ' - #' + CheckNum     
     END    
  when AOI.RecType = 1 then 'CREDIT'    
  end as [Description],    
  --case when CheckNum is null then PM.[Desc] else PM.[Desc] + ' - #' + CheckNum end as [Description],      
  TransDate as PaymentDate,       
  case @CboBase       
   when 0 then sum(AmtFgn)        
   when 1 then sum(Amt)      
  End      
  as PaymentAmt       
 from ALP_tblArOpenInvoice_view AOI      
 left outer JOIN tblArPmtMethod PM ON AOI.PmtMethodID = PM.PmtMethodID      
 where AOI.CustID = @CustId and InvcNum = @InvcNum      
 --mah 101515: check transid  
 --mah 10/19/15:     
 and (AOI.TransID IS NULL OR AOI.TransID <> @TransID  )    
 and AOI.RecType <> 1      
 GROUP BY      
  AOI.CustId,AlpSiteId, InvcNum, RecType ,    
  AOI.PmtMethodId, CheckNum,      
  case when CheckNum is null then PM.[Desc] else PM.[Desc] + ' - #' + CheckNum end,      
  TransDate      
UNION ALL      
--============================================================================================      
--EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits for Source = 2      
--============================================================================================      
Select     
--mah 01/26/15 TEST    
'S-THIRD-H' as Step,        
  'S' AS TableType,      
  null as UseLogo,      
  null as Logo,      
  null as PrintStatus, null as CustId, null as Attn, null as CustName, null as Contact, null as Addr1, null as Addr2, null as City, null as Region,       
  null as Country, null as PostalCode, null as ShipToID, null as ShipToName, null as ShipToAddr1, null as ShipToAddr2, null as ShipToCity,       
  null as ShipToCountry, null as ShipToRegion, null as ShipToPostalCode, null as ShipVia, null as TermsCode, null as TermDesc,       
  null as DiscDayOfMonth, null as DiscDays, null as DiscMinDays, null as NetDueDays, null as TransType, null as OrderDate, null as ShipDate,       
  null as ShipNum, null as InvcDate, null as Rep1Id, null as Rep2Id,      
  null as DiscDueDate,      
  null as NetDueDate,      
  tblArTransHeader.TaxSubtotalFgn as  TaxSubtotal , tblArTransHeader.NonTaxSubtotalFgn as  NonTaxSubtotal,     
  --mah 04/15/15 - sales tax added adj to make correct total    
  case when @CboBase=1 Then tblArTransHeader.SalesTax + tblArTransHeader.TaxAmtAdj     
  else tblArTransHeader.SalesTaxFgn  + tblArTransHeader.TaxAmtAdjFgn end as SalesTax,     
  ----tblArTransHeader.SalesTaxFgn as SalesTax,     
  ----mah 01/27/15: need to revert back tax calc      
  --case when @CboBase=1 Then tblArTransHeader.SalesTax else tblArTransHeader.SalesTaxFgn end as SalesTax,     
  tblArTransHeader.FreightFgn as Freight, tblArTransHeader.MiscFgn as Misc, null as TotCost,       
  null as TotPmtAmt, null as TaxAmtAdj,      
  null as TaxAdj, null as CustPONum, null as CurrencyID,       
  null as InvcNum, null as CurrMask ,      
  null as PostalCodeMask, null as ShipToPostalCodeMask, min(ALP_tblArTransDetail_view.TransId) as TransId,       
  null as ExchRate, null as [Name],       
  null as SiteFirstName, null as SiteName, null as SiteAttn, null as SiteAddr1,       
  null as SiteAddr2, null as SiteCity, null as SiteRegion, null as SiteCountry,       
  null as SitePostalCode, null as AlpMailSiteYN, null as CustFirstName, null as SiteId,      
      
  --EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits Record Count      
  (select isnull(sum(reccount),0) from       
  (      
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
  Select count(HP.CustId) as reccount      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end      
  Select count(AOI.CustId) as reccount      
   from tblArOpenInvoice AOI      
   where AOI.CustID = @CustId and InvcNum = @InvcNum      
 --mah 10/19/15:     
   and (AOI.TransID IS NULL OR AOI.TransID <> @TransID )     
   and RecType <> 1 and amt<>0 --and amtfgn<>0       
  union all      
   Select count(CustId) as reccount      
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = @CustId       
    and tblArTransHeader.InvcNum = @InvcNum       
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  union all      
   Select  count(CRH.CustId) as reccount      
  from tblArCashRcptDetail CRD inner join tblArCashRcptHeader CRH      
  on CRH.RcptHeaderID = CRD.RcptHeaderID      
  INNER JOIN tblArPmtMethod PM ON CRH.PmtMethodID = PM.PmtMethodID      
  where CRH.CustID = @CustId and CRD.InvcNum = @InvcNum      
   and CRD.PmtAmt > 0) as SubRecCount      
   )  as SubRecCount,      
      
  (select isnull(SUM(Paymentamt),0) from      
  (       
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
  Select case when @CboBase=1 Then sum(PmtAmt) else sum(PmtAmtFgn) end as PaymentAmt      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end       
  Select  case when @CboBase=1 Then sum(Amt) else sum(AmtFgn) end as PaymentAmt      
   from tblArOpenInvoice where       
   CustID = @CustId and       
   InvcNum = @InvcNum     
   --mah 10/19/15:  
   and (TransID IS NULL OR TransID <> @TransID )    
   and RecType < 0      
   GROUP BY CustId, InvcNum      
   having sum(Amt)<>0 --and sum(amtfgn)<>0      
  UNION all      
  Select case when @CboBase=1 Then SUM(QtyOrdSell  *  UnitPriceSell) else SUM(QtyOrdSell  *  UnitPriceSellFgn) end as PaymentAmt       
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = @CustId       
    and tblArTransHeader.InvcNum = @InvcNum       
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   GROUP BY CustId, InvcNum      
   having SUM(QtyOrdSell *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  UNION all      
  SELECT case when @CboBase=1 Then SUM(tblArCashRcptDetail.PmtAmt) else SUM(tblArCashRcptDetail.PmtAmtFgn) end as PaymentAmt      
   from tblArCashRcptDetail inner join tblArCashRcptHeader       
   on tblArCashRcptHeader.RcptHeaderID = tblArCashRcptDetail.RcptHeaderID      
   where       
   tblArCashRcptDetail.PmtAmt > 0 and       
   tblArCashRcptHeader.CustID = @CustId and       
   tblArCashRcptDetail.InvcNum = @InvcNum      
  ) as AppliedCredits      
  ) as PaymentAmtTotal,      
      
      
  'PartID2' as PartId, null as EntryNum,       
  'PartDesc2'  as PartDesc,       
  'PartAddnlDesc2' as AddnlDesc, null as TaxClass,       
  0 as QtyOrdSell, null as UnitsSell, null as UnitsBase, 0 as QtyShipBase, 0 as QtyShipSell, 0 as QtyBackordSell, 0 as PriceCode,       
  0 as UnitPriceSell1,       
  0 as UnitCostSell1,       
  null as PartType, null as LottedYn,      
  CustId,ALP_tblArTransDetail_view.AlpSiteId as SiteID,InvcNum as InvoiceNum,      
  min(ALP_tblArTransDetail_view.TransId) as TransId,2 as Source,cast(0 as bit) as PostedYn,      
  'Credit' as PaymentMethodID, '' as CheckNum,      
--mah 06/16/11 - cleaned up description      
--  'credit-' + case when isnull(PartID,'') != '' then isnull(PartID,'') + ' - ' else '' end +      
--  case when isnull([Desc],'') != '' then isnull([Desc],'') + ' - ' else '' end +      
--  cast(isnull(AddnlDesc,'') as varchar(255)) as [Description],      
  'Credit - ' + case when isnull([Desc],'') != ''       
      then isnull([Desc],'') + ' - '       
      else isnull(PartID,'') + ' - ' end +      
     cast(isnull(AddnlDesc,'') as varchar(255)) as [Description],      
  InvcDate as PaymentDate,       
  SUM(QtyOrdSell  *        
   case @CboBase       
    when 0 then UnitPriceSellFgn       
    when 1 then UnitPriceSell      
  End)  as PaymentAmt       
 from ALP_tblArTransDetail_view inner join tblArTransHeader       
 on tblArTransHeader.TransId = ALP_tblArTransDetail_view.TransId       
 where tblArTransHeader.CustID = @CustId       
  and tblArTransHeader.InvcNum = @InvcNum      
  --MAH 06/16/11 - following line added:      
  and tblArTransHeader.TransID <> @TransID        
  and tblArTransHeader.TransType < 0       
 GROUP BY      
  tblArTransHeader.TaxSubtotalFgn, tblArTransHeader.NonTaxSubtotalFgn,    
  --  --mah 04/15/15 - sales tax added adj to make correct total    
  case when @CboBase=1 Then tblArTransHeader.SalesTax + tblArTransHeader.TaxAmtAdj     
  else tblArTransHeader.SalesTaxFgn  + tblArTransHeader.TaxAmtAdjFgn end,       
 --tblArTransHeader.SalesTaxFgn,    
  ----mah 01/27/15: need to revert back tax calc      
  --case when @CboBase=1 Then tblArTransHeader.SalesTax else tblArTransHeader.SalesTaxFgn end,      
  tblArTransHeader.FreightFgn, tblArTransHeader.MiscFgn,      
  CustId,ALP_tblArTransDetail_view.AlpSiteId, InvcNum,      
  'Credit - ' + case when isnull([Desc],'') != ''       
      then isnull([Desc],'') + ' - '       
      else isnull(PartID,'') + ' - ' end +      
     cast(isnull(AddnlDesc,'') as varchar(255)),      
  InvcDate      
UNION ALL      
--============================================================================================      
--EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits for Source = 3      
--============================================================================================      
Select     
--mah 01/26/15 TEST    
'S-FOURTH-H' as Step,        
  'S' AS TableType,      
  null as UseLogo,      
  null as Logo,      
  null as PrintStatus, null as CustId, null as Attn, null as CustName, null as Contact, null as Addr1, null as Addr2, null as City, null as Region,       
  null as Country, null as PostalCode, null as ShipToID, null as ShipToName, null as ShipToAddr1, null as ShipToAddr2, null as ShipToCity,       
  null as ShipToCountry, null as ShipToRegion, null as ShipToPostalCode, null as ShipVia, null as TermsCode, null as TermDesc,       
  null as DiscDayOfMonth, null as DiscDays, null as DiscMinDays, null as NetDueDays, null as TransType, null as OrderDate, null as ShipDate,       
  null as ShipNum, null as InvcDate, null as Rep1Id, null as Rep2Id,      
  null as DiscDueDate,      
  null as NetDueDate,      
  null as  TaxSubtotal , null as NonTaxSubtotal,      
  null as SalesTax, null as Freight, null as Misc, null as TotCost,       
  null as TotPmtAmt, null as TaxAmtAdj,      
  null as TaxAdj, null as CustPONum, null as CurrencyID,       
  null as InvcNum, null as CurrMask ,      
  null as PostalCodeMask, null as ShipToPostalCodeMask, min(InvcTransId) as  TransId,       
  null as ExchRate, null as [Name],       
  null as SiteFirstName, null as SiteName, null as SiteAttn, null as SiteAddr1,       
  null as SiteAddr2, null as SiteCity, null as SiteRegion, null as SiteCountry,       
  null as SitePostalCode, null as AlpMailSiteYN, null as CustFirstName, null as SiteId,      
      
  --EFI 1918 12/14/2010 - Added By Sudharson to calculate SubApplied Credits Record Count      
  (select isnull(sum(reccount),0) from       
(      
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
  Select count(HP.CustId) as reccount      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end      
  Select count(AOI.CustId) as reccount      
   from tblArOpenInvoice AOI      
   where AOI.CustID = @CustId and InvcNum = @InvcNum    
 --mah 10/19/15:     
   and (AOI.TransID IS NULL  OR AOI.TransID <> @TransID)      
   and RecType < 0 and amt<>0 --and amtfgn<>0       
  union all      
   Select count(CustId) as reccount      
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = @CustId       
    and tblArTransHeader.InvcNum = @InvcNum       
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  union all      
   Select  count(CRH.CustId) as reccount      
  from tblArCashRcptDetail CRD inner join tblArCashRcptHeader CRH      
  on CRH.RcptHeaderID = CRD.RcptHeaderID      
  INNER JOIN tblArPmtMethod PM ON CRH.PmtMethodID = PM.PmtMethodID      
  where CRH.CustID = @CustId and CRD.InvcNum = @InvcNum      
   and CRD.PmtAmt > 0) as SubRecCount      
   )  as SubRecCount,      
      
  (select isnull(SUM(Paymentamt),0) from      
  (       
  --MAH 08/06/11 - added HistPmt as source, if not in OpenInvoice file:      
   Select case when @CboBase=1 Then sum(PmtAmt) else sum(PmtAmtFgn) end as PaymentAmt      
   from tblArHistPmt HP      
   where HP.CustID = @CustId and HP.InvcNum = @InvcNum       
    and PmtAmt<>0 --and PmtAmtfgn<>0      
    and NOT EXISTS       
    (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)      
  union all      
  --MAH 08/06/11 end       
  Select  case when @CboBase=1 Then sum(Amt) else sum(AmtFgn) end as PaymentAmt      
   from tblArOpenInvoice where       
   CustID = @CustId and       
   InvcNum = @InvcNum     
   --mah 10/19/15:  
   and (TransID IS NULL OR TransID <> @TransID )     
   and RecType < 0      
   GROUP BY CustId, InvcNum      
   having sum(Amt)<>0 --and sum(amtfgn)<>0      
  UNION all      
  Select case when @CboBase=1 Then SUM(QtyOrdSell  *  UnitPriceSell) else SUM(QtyOrdSell  *  UnitPriceSellFgn) end as PaymentAmt       
   from tblArTransDetail inner join tblArTransHeader       
   on tblArTransHeader.TransId = tblArTransDetail.TransId       
   where tblArTransHeader.CustID = @CustId       
    and tblArTransHeader.InvcNum = @InvcNum       
    and tblArTransHeader.TransID <> @TransID       
    and tblArTransHeader.TransType < 0       
   GROUP BY CustId, InvcNum      
   having SUM(QtyOrdSell  *  UnitPriceSell) <>0 --and SUM(QtyOrdSell  *  UnitPriceSellFgn)<>0      
  UNION all      
  SELECT case when @CboBase=1 Then SUM(tblArCashRcptDetail.PmtAmt) else SUM(tblArCashRcptDetail.PmtAmtFgn) end as PaymentAmt      
   from tblArCashRcptDetail inner join tblArCashRcptHeader       
   on tblArCashRcptHeader.RcptHeaderID = tblArCashRcptDetail.RcptHeaderID      
   where       
   tblArCashRcptDetail.PmtAmt > 0 and       
   tblArCashRcptHeader.CustID = @CustId and       
   tblArCashRcptDetail.InvcNum = @InvcNum      
  ) as AppliedCredits      
  ) as PaymentAmtTotal,      
      
  'PartID3' as PartId, null as EntryNum,       
  'PartDesc3'  as PartDesc,       
  'PartAddnlDesc3' as AddnlDesc, null as TaxClass,       
  0 as QtyOrdSell, null as UnitsSell, null as UnitsBase, 0 as QtyShipBase, 0 as QtyShipSell, 0 as QtyBackordSell, 0 as PriceCode,       
  0 as UnitPriceSell1,       
  0 as UnitCostSell1,       
  null as PartType, null as LottedYn,      
  CRH.CustID,CRD.AlpSiteId as SiteID,InvcNum as InvoiceNum,      
  min(InvcTransId) as TransId,3 as Source,cast(0 as bit)  as PostedYn,      
  CRH.PmtMethodId as PaymentMethodID, CheckNum,      
  case when CheckNum is null then PM.[Desc] else      
  case when note is null then PM.[Desc] + ' - #'       
  + CheckNum else PM.[Desc] + ' - #' + CheckNum + ' - ' + note end end as [Description],      
  CRH.PmtDate as PaymentDate,       
  SUM(case @CboBase       
   when 0 then CRD.PmtAmtFgn       
   when 1 then CRD.PmtAmt      
  End      
  )  as PaymentAmt      
 from ALP_tblArCashRcptDetail_view  CRD inner join tblArCashRcptHeader CRH      
 on CRH.RcptHeaderID = CRD.RcptHeaderID      
 INNER JOIN tblArPmtMethod PM ON CRH.PmtMethodID = PM.PmtMethodID      
 where CRH.CustID = @CustId and CRD.InvcNum = @InvcNum      
  and CRD.PmtAmt > 0       
 GROUP BY      
  CRH.CustID,CRD.AlpSiteId, InvcNum,      
  CRH.PmtMethodId, CheckNum,      
  case when CheckNum is null then PM.[Desc] else      
  case when note is null then PM.[Desc] + ' - #'       
  + CheckNum else PM.[Desc] + ' - #' + CheckNum + ' - ' + note end end ,      
  CRH.PmtDate      
      
END      
End