
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktPmt_Update_sp]	
@TicketId int ,
@BankID varchar(10)= null,
@PmtAmt  pDec=0,
@CheckNum varchar(10)= null,
@PmtMethodId varchar(10)= null,
@CcHolder varchar(30)= null,
@CcNum varchar(20)= null,
@CcExpire datetime= null,
@CcAuth varchar(10)= null,
@Note varchar(25)= null,
@CurrencyId varchar(6)= null,
--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@ModifiedBy varchar(50)=null
AS
update ALP_tblJmSvcTktPmt set BankID=@BankID,PmtAmt=@PmtAmt,CheckNum=@CheckNum,PmtMethodId=@PmtMethodId,CcHolder=@CcHolder,CcNum=@CcNum,
CcExpire=@CcExpire,CcAuth=@CcAuth,Note=@Note,CurrencyID=@CurrencyId,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE() where ticketid=@TicketId