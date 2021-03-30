
CREATE Procedure [dbo].[ALP_qryAddComments_Delete_sp]
	(
		@Id int		
	)
AS
Delete from dbo.tblSmAttachment
where Id=@Id