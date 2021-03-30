CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktRemoveItem]	
	@TicketItemId	 	int  ,	
	@ResDesc		text,
	@CauseDesc		text,	
	@UnitPts	 	float,
	@Comments	 	text,
	--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
	@ModifiedBy varchar(50)

AS
Update ALP_tblJmSvcTktItem set ResDesc=@ResDesc, CauseDesc=@CauseDesc,
UnitPts=@UnitPts,Comments=@Comments,
ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
 where TicketItemId=@TicketItemId