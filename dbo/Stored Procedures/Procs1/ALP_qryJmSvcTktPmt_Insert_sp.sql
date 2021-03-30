CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktPmt_Insert_sp]	
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
insert into ALP_tblJmSvcTktPmt(TicketId,BankID,PmtAmt,CheckNum,PmtMethodId,CcHolder,CcNum,CcExpire,CcAuth,Note,CurrencyID,ModifiedBy,ModifiedDate)
Values(@TicketId,@BankID,@PmtAmt,@CheckNum,@PmtMethodId,@CcHolder,@CcNum,@CcExpire,@CcAuth,@Note,@CurrencyId,@ModifiedBy,GETDATE())