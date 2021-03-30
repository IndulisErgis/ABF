
   
CREATE   Procedure [dbo].[ALP_qryAlpEI_JmSvcTktDeleteTrans_sp]    
-- The below query modified by ravi and mah on 10/08/2014  
--		New query added for while delete the invoice from ticket needs to delete the pre payment infor in following tables  
--		tblartranspmt,tblarcashrcptdetail,alp_tblarcashrcptdetail,tblArCashRcptHeader  
  
--Update Query Added by ravi on 10.10.2014, while delete the invoice payment needs to revert status of   
--		CashRcptCreated and ArCashRcptHeaderID column value in alp_tbljmsvctktpmt table  
--mah 12/4/15 - explicitly delete the TRansDetail records
  
@ID int    
AS    
Declare @transId pTransID  
  
SET NOCOUNT ON    
  
Create table #tempTransIds   
(  
TransId pTransID  
)  
Insert into #tempTransIds   
 Select  TransId  from tblArTransHeader     
left outer join ALP_tblArTransHeader on tblArTransHeader.TransId=ALP_tblArTransHeader.AlpTransId    
 WHERE ALP_tblArTransHeader.AlpJobNum = @ID     
       AND ALP_tblArTransHeader.AlpFROMJobYN = 1   
    
DELETE  FROM tblArTransHeader   where tblArTransHeader.TransId in(select TransId FROM #tempTransIds)   
--(Select  TransId from tblArTransHeader     
--left outer join ALP_tblArTransHeader on tblArTransHeader.TransId=ALP_tblArTransHeader.AlpTransId    
-- WHERE ALP_tblArTransHeader.AlpJobNum = @ID     
--       AND ALP_tblArTransHeader.AlpFROMJobYN = 1)    
    
DELETE  FROM ALP_tblArTransHeader WHERE ALP_tblArTransHeader.AlpTransId in  (select TransId FROM #tempTransIds)   
       AND ALP_tblArTransHeader.AlpFROMJobYN = 1    
--added by mah 10/13/14:  
DELETE  FROM tblArTransTax WHERE tblArTransTax.TransId in  (select TransId FROM #tempTransIds)   
 --end of 10/13/14 change  
 --mah 12/04/15 - explicitly delete the Detail records.  Not deleted automatically
DELETE  FROM tblArTransDetail WHERE tblArTransDetail.TransId in  (select TransId FROM #tempTransIds)   
DELETE  FROM ALP_tblArTransDetail WHERE ALP_tblArTransDetail.AlpTransId in  (select TransId FROM #tempTransIds)  
 --end of 12/4/15 change   
       
  Create table #tempCashRcptIds(RcptHeaderID int)  
    
  Insert into #tempCashRcptIds  
  Select LinkId as RcptHeaderID   from tblArTransPmt  where TransId in (select TransId FROM #tempTransIds)   
    
  DELETE  FROM tblArTransPmt where TransId in (select TransId FROM #tempTransIds)   
  DELETE  FROM tblArCashRcptHeader  where RcptHeaderID  in (select RcptHeaderID FROM #tempCashRcptIds)  
    
  Create table #tempCashRcptDtlIds(RcptDetailId int)  
  Select RcptDetailID   FROM tblArCashRcptDetail where RcptHeaderID  in (select RcptHeaderID FROM #tempCashRcptIds)   
    
  DELETE  FROM ALP_tblArCashRcptDetail  where AlpRcptDetailID   in (select RcptDetailId  FROM #tempCashRcptDtlIds)  
  DELETE  FROM tblArCashRcptDetail where RcptHeaderID  in (select RcptHeaderID FROM #tempCashRcptIds)   
  
  UPDATE ALP_tblJmSvcTktPmt SET CashRcptCreated=0 , ArCashRcptHeaderID=NULL WHERE TicketId =@ID