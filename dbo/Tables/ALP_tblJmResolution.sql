CREATE TABLE [dbo].[ALP_tblJmResolution] (
    [ResolutionId]   INT           IDENTITY (1, 1) NOT NULL,
    [ResolutionCode] VARCHAR (15)  NULL,
    [Desc]           VARCHAR (255) NULL,
    [Action]         VARCHAR (10)  NULL,
    [InactiveYN]     BIT           CONSTRAINT [DF_tblJmResolution_InactiveYN] DEFAULT (0) NULL,
    [PointFactor]    FLOAT (53)    NULL,
    [ts]             ROWVERSION    NULL,
    [PrivateYN]      BIT           CONSTRAINT [DF_ALP_tblJmResolution_PrivateYN] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblJmResolution] PRIMARY KEY CLUSTERED ([ResolutionId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgJmResolutionU] ON [dbo].[ALP_tblJmResolution] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(ResolutionID))
BEGIN
	/* BEGIN tblJmSvcTktItem */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTktItem WHERE (deleted.ResolutionID = ALP_tblJmSvcTktItem.ResolutionId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.ResolutionID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgJmResolutionU', @FldVal, 'ALP_tblJmSvcTktItem.ResolutionId')
		Set @Undo = 1
	END
	/* END tblJmSvcTktItem */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgJmResolutionD] ON [dbo].[ALP_tblJmResolution] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmSvcTktItem */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTktItem WHERE (deleted.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.ResolutionId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgJmResolutionD', @FldVal, 'ALP_tblJmSvcTktItem.ResolutionId')
    Set @Undo = 1
END
/* END tblJmSvcTktItem */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmResolution] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmResolution] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmResolution] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmResolution] TO PUBLIC
    AS [dbo];

