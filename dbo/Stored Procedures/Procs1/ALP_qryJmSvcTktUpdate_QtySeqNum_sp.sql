
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdate_QtySeqNum_sp]
	(
	@SvcTktItemID int,
	@QtySeqNum int, 
	@Category tinyint,
	--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
	@ModifiedBy varchar(50)
	)
As
SET NOCOUNT ON
-- committed
If @Category = 0	
BEGIN
	UPDATE ALP_tblJmSvcTktItem
	SET ALP_tblJmSvcTktItem.QtySeqNum_Cmtd = @QtySeqNum,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
	FROM  ALP_tblJmSvcTktItem 
	WHERE ALP_tblJmSvcTktItem.TicketItemId = @SvcTktItemID
END
-- in use
If @Category = 1
BEGIN
	UPDATE ALP_tblJmSvcTktItem
	--SET ALP_tblJmSvcTktItem.QtySeqNum_InUse = @QtySeqNum
	SET ALP_tblJmSvcTktItem.QtySeqNum_Cmtd = @QtySeqNum,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
	FROM  ALP_tblJmSvcTktItem 
	WHERE ALP_tblJmSvcTktItem.TicketItemId = @SvcTktItemID
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_qryJmSvcTktUpdate_QtySeqNum_sp] TO [JMCommissions]
    AS [dbo];

