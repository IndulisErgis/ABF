CREATE TABLE [dbo].[ALP_tblJmCauseCode] (
    [CauseId]    INT           IDENTITY (1, 1) NOT NULL,
    [CauseCode]  VARCHAR (15)  NULL,
    [Desc]       VARCHAR (255) NULL,
    [InactiveYN] BIT           CONSTRAINT [DF_tblJmCauseCode_InactiveYN] DEFAULT (0) NULL,
    [ts]         ROWVERSION    NULL,
    CONSTRAINT [PK_tblJmCauseCode] PRIMARY KEY CLUSTERED ([CauseId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgJmCauseCodeU] ON [dbo].[ALP_tblJmCauseCode] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(CauseID))
BEGIN
	/* BEGIN tblJmSvcTktItem */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTktItem WHERE (deleted.CauseID = ALP_tblJmSvcTktItem.CauseId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.CauseID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgJmCauseCodeU', @FldVal, 'ALP_tblJmSvcTktItem.CauseId')
		Set @Undo = 1
	END
	/* END tblJmSvcTktItem */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgJmCauseCodeD] ON [dbo].[ALP_tblJmCauseCode] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmSvcTktItem */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTktItem WHERE (deleted.CauseId = ALP_tblJmSvcTktItem.CauseId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.CauseId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgJmCauseCodeD', @FldVal, 'ALP_tblJmSvcTktItem.CauseId')
    Set @Undo = 1
END
/* END tblJmSvcTktItem */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmCauseCode] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmCauseCode] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmCauseCode] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmCauseCode] TO PUBLIC
    AS [dbo];

