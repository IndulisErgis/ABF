CREATE TABLE [dbo].[ALP_tblArAlpSysType] (
    [SysTypeId]     INT           IDENTITY (1, 1) NOT NULL,
    [SysType]       VARCHAR (10)  NULL,
    [Desc]          VARCHAR (255) NULL,
    [InactiveYN]    BIT           CONSTRAINT [DF_tblArAlpSysType_InactiveYN] DEFAULT (0) NULL,
    [InstPriceId]   VARCHAR (15)  NULL,
    [ServPriceId]   VARCHAR (15)  NULL,
    [InstLaborRate] FLOAT (53)    NULL,
    [ts]            ROWVERSION    NULL,
    CONSTRAINT [PK_tblArAlpSysType] PRIMARY KEY CLUSTERED ([SysTypeId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgArAlpSysTypeU] ON [dbo].[ALP_tblArAlpSysType] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(SysTypeID))
BEGIN
	/* BEGIN tblArAlpSiteSys */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteSys WHERE (deleted.SysTypeID = ALP_tblArAlpSiteSys.SysTypeId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.SysTypeID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpSysTypeU', @FldVal, 'ALP_tblArAlpSiteSys.SysTypeId')
		Set @Undo = 1
	END
	/* END tblArAlpSiteSys */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgArAlpSysTypeD] ON [dbo].[ALP_tblArAlpSysType] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblArAlpSiteSys */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteSys WHERE (deleted.SysTypeId = ALP_tblArAlpSiteSys.SysTypeId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.SysTypeId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpSysTypeD', @FldVal, 'ALP_tblArAlpSiteSys.SysTypeId')
    Set @Undo = 1
END
/* END tblArAlpSiteSys */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpSysType] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpSysType] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpSysType] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpSysType] TO PUBLIC
    AS [dbo];

