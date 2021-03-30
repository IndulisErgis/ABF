
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktSysItemId]	
@SysItemId int,
@TicketItemid int,
--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@ModifiedBy varchar(50)

AS
update ALP_tblJmSvcTktItem set SysItemId=@SysItemId,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE() where TicketItemId=@TicketItemid