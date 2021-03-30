
CREATE Procedure [dbo].[ALP_qryAddComments_Insert_sp]
	(
		@Id int OUTPUT,
		@LinkType varchar(10),
		@LinkKey varchar(10),
		@Status tinyint,
		@Priority tinyint,
		@Description varchar(50),
		@ExpireDate datetime,
		@EntryDate datetime,
		@EnteredBy varchar(20),
		@Keywords varchar(255),
		@Comment ntext,
		@FileName ntext
	)
AS
INSERT INTO dbo.tblSmAttachment
(LinkType,LinkKey,Status,Priority,Description,ExpireDate,EntryDate,EnteredBy,Keywords,
Comment,FileName)
VALUES
(@LinkType,@LinkKey,@Status,@Priority,@Description,@ExpireDate,@EntryDate,@EnteredBy,@Keywords,@Comment,@FileName)

set @Id =@@Identity