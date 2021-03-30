CREATE Procedure [dbo].[ALP_qryAddComments_Update_sp]
	(
		@Id int ,
		@Status tinyint,
		@Priority tinyint,
		@Comment ntext,
		@ExpireDate datetime,
		--@EntryDate datetime,
		@EnteredBy varchar(20),
		@Keywords varchar(255)
		
	)
AS
Update dbo.tblSmAttachment
set Status=@Status,Priority=@Priority,Comment=@Comment,ExpireDate=@ExpireDate,
--EntryDate=@EntryDate,
EnteredBy=@EnteredBy,Keywords=@Keywords 
where Id=@Id