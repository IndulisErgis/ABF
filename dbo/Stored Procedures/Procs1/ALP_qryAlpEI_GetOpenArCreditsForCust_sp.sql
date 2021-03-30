CREATE   procedure [dbo].[ALP_qryAlpEI_GetOpenArCreditsForCust_sp]     
 @CustId varchar(30),    
 @OnAcctInvc pInvoiceNum,    
 @TransId pTransID --EFI# 1890 SUDHARSON 06/17/2011 - To Exclude the records for same Transaction    
/*        
 Created by Nidheesh for EFI#1869 04/20/10          
 Modified by Nidheesh for EFI#1869 05/18/10  
 --@OnAcctInvc varchar(30) Added by sudharson for EFI#1869 07/21/2010    
 --MAH 04/12/11 - corrected to add CheckNum grouping in posted trans selection    
 --MAH 06/18/11 - clean up on credit descriptions    
 -- Alpine version of this sp is  created by Ravi on 10/03/2013 for EFI#1962  
*/          
As          
BEGIN    
    
Create table #tmpGetOpenArCreditsForCust    
(    
 CustId pCustID,     
 EntryNum int,     
 SiteID int,     
 InvoiceNum pInvoiceNum,     
 RecType int,     
 TransID pTransId null,     
 Source int,     
 SourceID varchar(50),     
 PostedYn bit,    
 PaymentMethodID varchar(10),    
 CheckNum pCheckNum,    
 [Description] varchar(255),    
 PaymentDate datetime,    
 PaymentAmt pDec,    
 AmountAvailable pDec    
)    
 --========================================================================    
 --Posted transactions    
 --========================================================================    
 INSERT INTO #tmpGetOpenArCreditsForCust      
 SELECT           
  tblArOpenInvoice1.CustId,cast(1 as smallint) as EntryNum,
  --mah 04/22/14 - assign default of 0 if no matching ALP_OPenInvoice record found
  --AlpSiteId as SiteID,   
  CASE WHEN AlpSiteId IS NULL THEN 0 ELSE AlpSiteId END as SiteID,  
  tblArOpenInvoice1.InvcNum as InvoiceNum,    
  RecType,AlpTransId as TransID,1 as Source,          
  Counter as SourceID,cast(1 as bit) as PostedYn,    
  PmtMethodId as PaymentMethodID,CheckNum ,          
  case when CheckNum is null then PmtMethodId     
   else PmtMethodId + ' - #' + CheckNum     
  end as [Description],    
  tblArOpenInvoice1.TransDate as PaymentDate,    
  Amt as PaymentAmt, tblArOpenInvoice3.AmountAvailable as  AmountAvailable          
 FROM  ALP_tblArOpenInvoice_view  tblArOpenInvoice1          
 INNER JOIN (SELECT Min(alp_tblArOpenInvoice_view.counter) as Counter1, CustID,     
   min(TransDate) as TransDate,isnull(sum(amt),0) as AmountAvailable     
   FROM alp_tblArOpenInvoice_view  
   WHERE Status <> 4 and custid = @CustId and RecType <0          
   GROUP BY CustID, AlpSiteId, InvcNum --,RecType    
   ,CheckNum --MAH 04/12/11    
   ) as tblArOpenInvoice2     
  ON tblArOpenInvoice2.TransDate = tblArOpenInvoice1.TransDate     
   and tblArOpenInvoice2.counter1 = tblArOpenInvoice1.counter      
 --MAH 08/17/11: added inner join below to bypass fully applied records:    
 INNER JOIN (SELECT CustID, Invcnum,    
    isnull(sum(    
     case when RecType < 0 then amt    
     else amt * -1 end    
      ),0) as AmountAvailable     
   FROM tblArOpenInvoice          
   WHERE Status <> 4 and custid = @CustId         
   GROUP BY CustID,InvcNum     
   ) as tblArOpenInvoice3       
  ON  tblArOpenInvoice3.custid = tblArOpenInvoice1.custid       
   and tblArOpenInvoice3.invcnum = tblArOpenInvoice1.invcnum     
    --MAH 08/17/11 end    
 WHERE  tblArOpenInvoice1.custid = @CustId and tblArOpenInvoice3.AmountAvailable >0     
  and ((AlpTransID is null)     
   or (AlpTransID in ( select AlpTransID from Alp_tblArOpenInvoice_view  
       where custid = @CustId and RecType <0  and amt<>0    
       group by AlpTransID having count(AlpTransID)=1)))    
    
 --========================================================================    
 --Unposted (new) transactions    
 --========================================================================    
 INSERT INTO #tmpGetOpenArCreditsForCust      
 SELECT     
  ATH.CustId, ATD.EntryNum, ATH.AlpSiteId as SiteID,    
  ATH.InvcNum as InvoiceNum,     
  ATH.TransType as RecType,    
  min(ATD.TransId) as TransID, 2 as Source,          
  min(ATD.TransId) as SourceID, cast(0 as bit) as PostedYn,    
  'Credit' as PaymentMethodID,' ' as CheckNum ,          
--  'Credit-' +     
--   case when isnull(PartID,'') != '' then isnull(PartID,'') + ' - '     
--   else ''     
--   end +    
--   case when isnull([Desc],'') != '' then isnull([Desc],'') + ' - '     
--   else ''     
--   end +    
--   cast(isnull(AddnlDesc,'') as varchar(255)) as [Description],    
  'Credit - ' + case when isnull([Desc],'') != ''     
      then isnull([Desc],'') + ' - '     
      else isnull(PartID,'') + ' - ' end +    
     cast(isnull(AddnlDesc,'') as varchar(255)) as [Description],    
  ATH.InvcDate as PaymentDate,    
  max(ATD.QtyOrdSell * ATD.UnitPriceSell) as PaymentAmt,isnull(SUM(ATD.QtyOrdSell * ATD.UnitPriceSell),0) as AmountAvailable    
 from Alp_tblArTransHeader_View ATH INNER JOIN tblArTransDetail ATD    
 ON ATH.TransID = ATD.TransID   
 --mah 03/06/14 - corrected location of the 'and ATH.TransID <> @TransID' clause      
 where ATH.CustID = @CustId AND ATH.TransID <> @TransID  and ATH.InvcNum    
  in (    
   Select InvcNum from alp_tblArTransHeader_view  
   where CustID = @CustId and ATH.TransType<0     
   group by InvcNum,AlpJobNum     
   having count(isnull(AlpJobNum,'')) =1)   
 GROUP BY     
  ATH.CustId, ATD.EntryNum,     
  ATH.AlpSiteId,     
  ATH.InvcNum, ATH.TransType,    
  'Credit - ' + case when isnull([Desc],'') != ''     
      then isnull([Desc],'') + ' - '     
      else isnull(PartID,'') + ' - ' end +    
     cast(isnull(AddnlDesc,'') as varchar(255)),    
  ATH.InvcDate     
 having isnull(SUM(ATD.QtyOrdSell * ATD.UnitPriceSell),0)>0    
    
    
 --========================================================================    
 --Unposted (new) payments    
 --========================================================================    
 INSERT INTO #tmpGetOpenArCreditsForCust      
 SELECT CRH.CustId,cast(1 as smallint) as EntryNum,CRD.AlpSiteId as SiteID,    
  CRD.InvcNum as InvoiceNum,    
  -2 as RecType,    
  min(InvcTransId)  as TransID,    
  3 as Source,    
  min(RcptDetailID) as SourceID,    
  cast(0 as bit) as PostedYn,     
  PmtMethodId as PaymentMethodID,CheckNum ,          
  --case when CheckNum is null then PmtMethodId     
  case when CheckNum is null then     
    case when note is null then PmtMethodId      
    else PmtMethodId + ' - ' + note     
    end      
  else case when note is null then PmtMethodId + ' - #' + CheckNum     
    else PmtMethodId + ' - #' + CheckNum + ' - ' + note     
    end     
  end as [Description],    
  PmtDate as PaymentDate, max(CRD.PmtAmt) as PaymentAmt, isnull(SUM(CRD.PmtAmt),0) as AmountAvailable    
 FROM tblArCashRcptHeader CRH INNER JOIN ALP_tblArCashRcptDetail_view  CRD     
  ON CRH.RcptHeaderID = CRD.RcptHeaderID       
 WHERE CRH.CustID =  @CustId and CRD.InvcNum = @OnAcctInvc     
 GROUP BY      
  CRH.CustId,CRD.AlpSiteId,CRD.InvcNum,    
  PmtMethodId, CheckNum ,     
  case when CheckNum is null then     
    case when note is null then PmtMethodId      
    else PmtMethodId + ' - ' + note     
    end      
  else case when note is null then PmtMethodId + ' - #' + CheckNum     
    else PmtMethodId + ' - #' + CheckNum + ' - ' + note     
    end     
  end ,         
--  case when CheckNum is null then PmtMethodId else     
--  case when note is null then PmtMethodId + '-' + CheckNum else PmtMethodId + '-' + CheckNum + '-' + note end end,    
  PmtDate      
 having isnull(SUM(CRD.PmtAmt),0)>0    
    
 --Returning the values to the front end    
 select * from #tmpGetOpenArCreditsForCust    
    
     
    
END