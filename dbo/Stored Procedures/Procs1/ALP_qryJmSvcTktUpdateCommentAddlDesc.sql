
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateCommentAddlDesc]	
@CommentAddlDesc text,
@Ticketid int

AS
update dbo.ALP_tblJmSvcTkt set CommentAddlDesc =@CommentAddlDesc
where TicketId=@Ticketid