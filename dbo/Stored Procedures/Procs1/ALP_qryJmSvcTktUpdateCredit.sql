CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateCredit]	
@CreditOverrideDate datetime,
@CreditOverrideBy varchar(20),
@Ticketid int,
--Below @RevisedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@RevisedBy varchar(50)=null,
--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@ModifiedBy varchar(50)


AS
update dbo.ALP_tblJmSvcTkt set CreditOverrideDate =@CreditOverrideDate,CreditOverrideBy=@CreditOverrideBy,RevisedBy=@RevisedBy,RevisedDate=CONVERT(VARCHAR(10),GETDATE(),101) 
,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
where TicketId=@Ticketid