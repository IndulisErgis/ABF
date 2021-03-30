CREATE  procedure [dbo].[ALP_qryAlpEI_GetArPaymentsForInvoice_sp]     
-- @Source int,    
 @CustId varchar(30),    
 @InvcNum varchar(30),    
 @InvoiceReportYN bit,    
 @TransId pTransID --EFI# 1890 SUDHARSON 06/17/2011 - To Exclude the records for same Transaction    
/*    
   
 The Alpine version of this Procedure newly created By M Ravi on 01/03/2013 EFI# 1962  
   
 Created by Nidheesh for 1869 on 04/09/10    
 @Source can be 1 for Posted Or 2 for New Or 3 for Unposted    
--EFI# 1890 SUDHARSON 06/17/2011 - To Exclude the records for same Transaction    
--MAH 06/18/11 - changed logic to force it to ignore multi-currency for now.    
--MAH 06/18/11 - corrected logic to select only non-zero credits/payments, and to improve description displayed
--mah 01/27/15 - Open Invoice - prevent from displaying itself    
*/    
As    
Begin    
--MAH 06/18/11 - changed logic to force it to ignore multi-currency for now.    
--   ( i.e. always use base amounts, rather than foreign amounts)    
--   This is a temporary change until the insertion of foreign amounts     
--   in all transactions is verified.  Did this by adding following statement,     
--   which forces @cboBase to be 1.     
--MAH 08/06/11 - added HistPmt source, rather than OpenInvoice for Pmts    
--MAH 08/29/11 - corrected selection of payments from OpenInvoice file    
SET @InvoiceReportYN = 0 --To be removed once fgn fields in all transactions are corrected.    
    
-- if @Source = 1    
 Select  HP.CustId,0 as SiteID,InvcNum as InvoiceNum,    
  min(TransId) as TransId,0 as Source,cast(1 as bit) as PostedYn,    
  HP.PmtMethodId as PaymentMethodID, CheckNum,    
  case when CheckNum is null then PM.[Desc] else PM.[Desc] + ' - #' + CheckNum end as [Description],    
  PmtDate as PaymentDate,     
  case @InvoiceReportYN     
   when 1 then sum(PmtAmtFgn)      
   when  0 then sum(PmtAmt)    
  End    
  as PaymentAmt     
 from tblArHistPmt HP    
 left outer JOIN tblArPmtMethod PM ON HP.PmtMethodID = PM.PmtMethodID    
 where HP.CustID = @CustId and HP.InvcNum = @InvcNum    
 and PmtAmt<>0     
 and NOT EXISTS (Select InvcNum from tblArOpenInvoice where CustID = @CustID and InvcNum = @InvcNum)    
 GROUP BY    
  HP.CustId,InvcNum,    
  HP.PmtMethodId, CheckNum,    
  case when CheckNum is null then PM.[Desc] else PM.[Desc] + ' - #' + CheckNum end,    
  PmtDate    
union all    
-- if @Source = 1    
 Select  AOI.CustId,AlpSiteId as SiteID,InvcNum as InvoiceNum,    
  min(AlpTransId) as TransId,1 as Source,cast(1 as bit) as PostedYn,    
  AOI.PmtMethodId as PaymentMethodID, CheckNum,    
  case when CheckNum is null then PM.[Desc] else PM.[Desc] + ' - #' + CheckNum end as [Description],    
  TransDate as PaymentDate,
  --mah 01/27/15: corrected 
  --case @InvoiceReportYN     
  -- when 1 then sum(AmtFgn)      
  -- when  0 then sum(Amt)    
  --End      
  SUM(case @InvoiceReportYN     
   when 1 then AmtFgn      
   when  0 then Amt    
  End)    
  as PaymentAmt     
 from ALP_tblArOpenInvoice_view AOI    
	left outer JOIN tblArPmtMethod PM ON AOI.PmtMethodID = PM.PmtMethodID   
 where AOI.CustID = @CustId and InvcNum = @InvcNum    
 --MAH 08/29/11:     
 -- --select credit memos only    
 -- and RecType = -1 and amt<>0 -- and Status <> 4  (Removed By Sudharson 10/28/2010 - As per TestResults_102610_SOLUTION_MAHComments.docx    
 and RecType < 0 and amt<>0 -- and Status <> 4 
 --mah 01/27/15:
 and AOI.AlpTransID <> @TransId     
GROUP BY    
  AOI.CustId,AlpSiteId, InvcNum,    
  AOI.PmtMethodId, CheckNum,    
  case when CheckNum is null then PM.[Desc] else PM.[Desc] + ' - #' + CheckNum end,    
  TransDate    
-- if @Source = 2    
union all    
 Select  CustId,ALP_tblArTransDetail_view.AlpSiteId as SiteID,InvcNum as InvoiceNum,    
  min(ALP_tblArTransDetail_view.TransId) as TransId,2 as Source,cast(0 as bit) as PostedYn,    
  'Credit' as PaymentMethodID, '' as CheckNum,    
  --COMMENTED BY SUDHARSON AND ADDED    
  --PartID + ' ' + [Desc] + ' ' + cast(AddnlDesc as varchar) as [Description],    
  --InvcDate as PaymentDate, QtySeqNum  *  UnitPriceSell  as PaymentAmt     
--  'Credit-' + case when isnull(PartID,'') != '' then isnull(PartID,'') + ' - ' else '' end +    
--  case when isnull([Desc],'') != '' then isnull([Desc],'') + ' - ' else '' end +    
--  cast(isnull(AddnlDesc,'') as varchar(255)) as [Description],    
  'Credit - ' + case when isnull([Desc],'') != ''     
      then isnull([Desc],'') + ' - '     
      else isnull(PartID,'') + ' - ' end +    
     cast(isnull(AddnlDesc,'') as varchar(255)) as [Description],    
  InvcDate as PaymentDate,     
  SUM(QtyOrdSell  *      
   case @InvoiceReportYN     
    when 1 then UnitPriceSellFgn     
    when  0 then UnitPriceSell    
  End)  as PaymentAmt     
 from ALP_tblArTransDetail_view  inner join tblArTransHeader     
 on tblArTransHeader.TransId = ALP_tblArTransDetail_view.TransId     
 where tblArTransHeader.CustID = @CustId and tblArTransHeader.InvcNum = @InvcNum     
  and tblArTransHeader.TransID <> @TransID    
  --mah 06/18/11- added non-zero criteria:    
  and (QtyOrdSell  *  UnitPriceSell) <> 0    
  and tblArTransHeader.TransType < 0     
 GROUP BY    
  CustId,ALP_tblArTransDetail_view.AlpSiteID, InvcNum,    
  'Credit - ' + case when isnull([Desc],'') != ''     
      then isnull([Desc],'') + ' - '     
      else isnull(PartID,'') + ' - ' end +    
     cast(isnull(AddnlDesc,'') as varchar(255)),    
  InvcDate    
 having SUM(QtyOrdSell  *  UnitPriceSell) <>0    
-- if @Source = 3    
union all    
 Select  CRH.CustID,CRD.AlpSiteId as SiteID,InvcNum as InvoiceNum,    
  min(InvcTransId) as TransId,3 as Source,cast(0 as bit)  as PostedYn,    
  CRH.PmtMethodId as PaymentMethodID, CheckNum,    
  case when CheckNum is null then    
   case when note is null then PM.[Desc]     
     else PM.[Desc] + ' - ' + note     
   end     
  --PM.[Desc] + ' - ' + note      
  else case when note is null then PM.[Desc] + ' - #' + CheckNum     
     else PM.[Desc] + ' - #' + CheckNum + ' - ' + note     
    end     
  end as [Description],    
  CRH.PmtDate as PaymentDate,     
  SUM(case @InvoiceReportYN     
   when 1 then CRD.PmtAmtFgn     
   when  0 then CRD.PmtAmt    
  End    
  )  as PaymentAmt    
 from ALP_tblArCashRcptDetail_view  CRD inner join tblArCashRcptHeader CRH    
 on CRH.RcptHeaderID = CRD.RcptHeaderID    
 INNER JOIN tblArPmtMethod PM ON CRH.PmtMethodID = PM.PmtMethodID    
 where CRH.CustID = @CustId and CRD.InvcNum = @InvcNum    
  and CRD.PmtAmt > 0 --Added by sudharson 07/15/2010     
 GROUP BY    
  CRH.CustID,CRD.AlpSiteId, InvcNum,    
  --InvcTransId,     
  CRH.PmtMethodId, CheckNum,    
  case when CheckNum is null then    
   case when note is null then PM.[Desc]     
     else PM.[Desc] + ' - ' + note      
   end    
  else case when note is null then PM.[Desc] + ' - #' + CheckNum     
     else PM.[Desc] + ' - #' + CheckNum + ' - ' + note     
    end     
  end,    
--  case when CheckNum is null then PM.[Desc] else    
--  case when note is null then PM.[Desc] + '-' + CheckNum else PM.[Desc] + '-' + CheckNum + '-' + note end end ,    
  CRH.PmtDate    
    
End