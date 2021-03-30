CREATE TABLE [dbo].[ALP_tblArAlpSubdivision] (
    [SubdivId]   INT          IDENTITY (1, 1) NOT NULL,
    [Subdiv]     VARCHAR (10) NULL,
    [Desc]       VARCHAR (50) NULL,
    [InactiveYN] BIT          CONSTRAINT [DF_tblArAlpSubdivision_InactiveYN] DEFAULT (0) NULL,
    [ts]         ROWVERSION   NULL,
    CONSTRAINT [PK_tblArAlpSubdivision] PRIMARY KEY CLUSTERED ([SubdivId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgArAlpSubdivisionD] ON [dbo].[ALP_tblArAlpSubdivision] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblArAlpSite */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSite WHERE (deleted.SubdivId = ALP_tblArAlpSite.SubdivId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.SubdivId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpSubdivisionD', @FldVal, 'ALP_tblArAlpSite.SubdivId')
    Set @Undo = 1
END
/* END tblArAlpSite */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgArAlpSubdivisionU] ON [dbo].[ALP_tblArAlpSubdivision] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(SubdivID))
BEGIN
	/* BEGIN tblArAlpSite */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSite WHERE (deleted.SubdivID = ALP_tblArAlpSite.SubdivId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.SubdivID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpSubdivisionU', @FldVal, 'ALP_tblArAlpSite.SubdivId')
		Set @Undo = 1
	END
	/* END tblArAlpSite */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpSubdivision] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpSubdivision] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpSubdivision] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpSubdivision] TO PUBLIC
    AS [dbo];

