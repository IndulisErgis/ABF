CREATE TABLE [dbo].[ALP_tblJmMarketCode] (
    [MarketCodeId] INT          IDENTITY (1, 1) NOT NULL,
    [MarketCode]   VARCHAR (15) NULL,
    [Desc]         VARCHAR (50) NULL,
    [NewSysYn]     BIT          CONSTRAINT [DF_tblJmMarketCode_NewSysYn] DEFAULT ((-1)) NOT NULL,
    [InactiveYn]   BIT          CONSTRAINT [DF_tblJmMarketCode_InactiveYn] DEFAULT ((-1)) NOT NULL,
    CONSTRAINT [PK_tblJmMarketCode] PRIMARY KEY CLUSTERED ([MarketCodeId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgJmMarketCodeU] ON [dbo].[ALP_tblJmMarketCode] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(MarketCodeID))
BEGIN
	/* BEGIN tblJmSvcTktProject */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTktProject WHERE (deleted.MarketCodeID = ALP_tblJmSvcTktProject.MarketCodeId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.MarketCodeID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgJmMarketCodeU', @FldVal, 'ALP_tblJmSvcTktProject.MarketCodeId')
		Set @Undo = 1
	END
	/* END tblJmSvcTktProject */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgJmMarketCodeD] ON [dbo].[ALP_tblJmMarketCode] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmSvcTktProject */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTktProject WHERE (deleted.MarketCodeId = ALP_tblJmSvcTktProject.MarketCodeId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.MarketCodeId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgJmMarketCodeD', @FldVal, 'ALP_tblJmSvcTktProject.MarketCodeId')
    Set @Undo = 1
END
/* END tblJmSvcTktProject */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmMarketCode] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmMarketCode] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmMarketCode] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmMarketCode] TO PUBLIC
    AS [dbo];

