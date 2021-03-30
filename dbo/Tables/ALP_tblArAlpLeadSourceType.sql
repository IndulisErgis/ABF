CREATE TABLE [dbo].[ALP_tblArAlpLeadSourceType] (
    [LeadSourceTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [LeadSourceType]   VARCHAR (10)  NULL,
    [Desc]             VARCHAR (255) NULL,
    [InactiveYN]       BIT           CONSTRAINT [DF_tblArAlpLeadSourceType_InactiveYN] DEFAULT (0) NULL,
    [ts]               ROWVERSION    NULL,
    CONSTRAINT [PK_tblArAlpLeadSourceType] PRIMARY KEY CLUSTERED ([LeadSourceTypeId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgArAlpLeadSourceTypeU] ON [dbo].[ALP_tblArAlpLeadSourceType] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(LeadSourceTypeID))
BEGIN
	/* BEGIN tblArAlpLeadSource */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpLeadSource WHERE (deleted.LeadSourceTypeID = ALP_tblArAlpLeadSource.LeadSourceTypeId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.LeadSourceTypeID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpLeadSourceTypeU', @FldVal, 'ALP_tblArAlpLeadSource.LeadSourceTypeId')
		Set @Undo = 1
	END
	/* END tblArAlpLeadSource */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgArAlpLeadSourceTypeD] ON [dbo].[ALP_tblArAlpLeadSourceType] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblArAlpLeadSource */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpLeadSource WHERE (deleted.LeadSourceTypeId = ALP_tblArAlpLeadSource.LeadSourceTypeId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.LeadSourceTypeId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpLeadSourceTypeD', @FldVal, 'ALP_tblArAlpLeadSource.LeadSourceTypeId')
    Set @Undo = 1
END
/* END tblArAlpLeadSource */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpLeadSourceType] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpLeadSourceType] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpLeadSourceType] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpLeadSourceType] TO PUBLIC
    AS [dbo];

