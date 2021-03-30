CREATE TABLE [dbo].[ALP_tblArAlpUDF] (
    [UDFId]      INT           IDENTITY (1, 1) NOT NULL,
    [UDF]        VARCHAR (10)  NULL,
    [Desc]       VARCHAR (255) NULL,
    [RequiredYN] BIT           CONSTRAINT [DF_tblArAlpUDF_RequiredYN] DEFAULT (0) NULL,
    [InactiveYN] BIT           CONSTRAINT [DF_tblArAlpUDF_InactiveYN] DEFAULT (0) NULL,
    [ts]         ROWVERSION    NULL,
    CONSTRAINT [PK_tblArAlpUDF] PRIMARY KEY CLUSTERED ([UDFId] ASC) WITH (FILLFACTOR = 80)
);


GO
 
CREATE TRIGGER [dbo].[trgArAlpUDFD] ON [dbo].[ALP_tblArAlpUDF] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblArAlpUDFSites */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpUDFSites WHERE (deleted.UDFId = ALP_tblArAlpUDFSites.UDFId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.UDFId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpUDFD', @FldVal, 'ALP_tblArAlpUDFSites.UDFId')
    Set @Undo = 1
END
/* END tblArAlpUDFSites */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgArAlpUDFU] ON [dbo].[ALP_tblArAlpUDF] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(UDFID))
BEGIN
	/* BEGIN tblArAlpUDFSites */
	IF (SELECT COUNT(*) FROM deleted, tblUDFSites WHERE (deleted.UDFID = ALP_tblArAlpUDFSites.UDFId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.UDFID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpUDFU', @FldVal, 'ALP_tblArAlpUDFSites.UDFId')
		Set @Undo = 1
	END
	/* END tblArAlpUDFSites */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpUDF] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpUDF] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpUDF] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpUDF] TO PUBLIC
    AS [dbo];

