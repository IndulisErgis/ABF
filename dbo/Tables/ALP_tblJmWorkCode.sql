CREATE TABLE [dbo].[ALP_tblJmWorkCode] (
    [WorkCodeId]    INT           IDENTITY (1, 1) NOT NULL,
    [WorkCode]      VARCHAR (10)  NULL,
    [Desc]          VARCHAR (255) NULL,
    [CSYn]          BIT           CONSTRAINT [DF_tblJmWorkCode_CSYn] DEFAULT (0) NULL,
    [PullSystemYn]  BIT           CONSTRAINT [DF_tblJmWorkCode_PullSystemYn] DEFAULT (0) NULL,
    [NewWorkYN]     BIT           CONSTRAINT [DF_tblJmWorkCode_NewWorkYN] DEFAULT (0) NULL,
    [SvcYN]         BIT           CONSTRAINT [DF_tblJmWorkCode_NewWorkYN1] DEFAULT (0) NULL,
    [DfltSkillId]   INT           NULL,
    [GlAcctSaleRev] VARCHAR (40)  NULL,
    [GlAcctSaleCOS] VARCHAR (40)  NULL,
    [GlAcctLseRev]  VARCHAR (40)  NULL,
    [GlAcctLseCOS]  VARCHAR (40)  NULL,
    [InactiveYN]    BIT           CONSTRAINT [DF_tblJmWorkCode_InactiveYN] DEFAULT (0) NULL,
    [ts]            ROWVERSION    NULL,
    CONSTRAINT [PK_tblJmWorkCode] PRIMARY KEY CLUSTERED ([WorkCodeId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgJmWorkCodeU] ON [dbo].[ALP_tblJmWorkCode] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(WorkCodeID))
BEGIN
	/* BEGIN tblJmSvcTkt */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTkt WHERE (deleted.WorkCodeID = ALP_tblJmSvcTkt.WorkCodeId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.WorkCodeID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgJmWorkCodeU', @FldVal, 'ALP_tblJmSvcTkt.WorkCodeId')
		Set @Undo = 1
	END
	/* END tblJmSvcTkt */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgJmWorkCodeD] ON [dbo].[ALP_tblJmWorkCode] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmSvcTkt */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTkt WHERE (deleted.WorkCodeId = ALP_tblJmSvcTkt.WorkCodeId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.WorkCodeId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgJmWorkCodeD', @FldVal, 'ALP_tblJmSvcTkt.WorkCodeId')
    Set @Undo = 1
END
/* END tblJmSvcTkt */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmWorkCode] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmWorkCode] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmWorkCode] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmWorkCode] TO PUBLIC
    AS [dbo];

