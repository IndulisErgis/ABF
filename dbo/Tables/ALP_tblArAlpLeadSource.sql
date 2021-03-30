CREATE TABLE [dbo].[ALP_tblArAlpLeadSource] (
    [LeadSourceId]     INT           IDENTITY (1, 1) NOT NULL,
    [LeadSource]       VARCHAR (10)  NULL,
    [Desc]             VARCHAR (255) NULL,
    [LeadSourceTypeID] INT           NULL,
    [InactiveYN]       BIT           CONSTRAINT [DF_tblArAlpLeadSource_InactiveYN] DEFAULT (0) NULL,
    [ts]               ROWVERSION    NULL,
    CONSTRAINT [PK_tblArAlpLeadSource] PRIMARY KEY CLUSTERED ([LeadSourceId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgArAlpLeadSourceU] ON [dbo].[ALP_tblArAlpLeadSource] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(LeadSourceID))
BEGIN
	/* BEGIN tblArAlpSite */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSite WHERE (deleted.LeadSourceID =ALP_tblArAlpSite.LeadSourceId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.LeadSourceID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpLeadSourceU', @FldVal, 'ALP_tblArAlpSite.LeadSourceId')
		Set @Undo = 1
	END
	/* END tblArAlpSite */
	/* BEGIN tblJmSvcTktProject */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTktProject WHERE (deleted.LeadSourceID = ALP_tblJmSvcTktProject.LeadSourceId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.LeadSourceID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpLeadSourceU', @FldVal, 'ALP_tblJmSvcTktProject.LeadSourceId')
		Set @Undo = 1
	END
	/* END tblJmSvcTktProject */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgArAlpLeadSourceD] ON [dbo].[ALP_tblArAlpLeadSource] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblArAlpSite */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSite WHERE (deleted.LeadSourceId = ALP_tblArAlpSite.LeadSourceId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.LeadSourceId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpLeadSourceD', @FldVal, 'ALP_tblArAlpSite.LeadSourceId')
    Set @Undo = 1
END
/* END tblArAlpSite */
/* BEGIN tblJmSvcTktProject */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTktProject WHERE (deleted.LeadSourceId = ALP_tblJmSvcTktProject.LeadSourceId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.LeadSourceId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpLeadSourceD', @FldVal, 'ALP_tblJmSvcTktProject.LeadSourceId')
    Set @Undo = 1
END
/* END tblArAlpSite */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpLeadSource] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpLeadSource] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpLeadSource] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpLeadSource] TO PUBLIC
    AS [dbo];

