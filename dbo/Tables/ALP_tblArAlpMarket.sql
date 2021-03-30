CREATE TABLE [dbo].[ALP_tblArAlpMarket] (
    [MarketId]   INT           IDENTITY (1, 1) NOT NULL,
    [Market]     VARCHAR (10)  NULL,
    [Desc]       VARCHAR (255) NULL,
    [MarketType] TINYINT       NULL,
    [InactiveYN] BIT           CONSTRAINT [DF_tblArAlpMarket_InactiveYN] DEFAULT (0) NULL,
    [DivisionId] INT           NULL,
    [ts]         ROWVERSION    NULL,
    CONSTRAINT [PK_tblArAlpMarket] PRIMARY KEY CLUSTERED ([MarketId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgArAlpMarketU] ON [dbo].[ALP_tblArAlpMarket] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(MarketID))
BEGIN
	/* BEGIN tblArAlpSite */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSite WHERE (deleted.MarketID = ALP_tblArAlpSite.MarketId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.MarketID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpMarketU', @FldVal, 'ALP_tblArAlpSite.MarketId')
		Set @Undo = 1
	END
	/* END tblArAlpSite */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgArAlpMarketD] ON [dbo].[ALP_tblArAlpMarket] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblArAlpSite */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSite WHERE (deleted.MarketId = ALP_tblArAlpSite.MarketId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.MarketId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpMarketD', @FldVal, 'ALP_tblArAlpSite.MarketId')
    Set @Undo = 1
END
/* END tblArAlpSite */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpMarket] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpMarket] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpMarket] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpMarket] TO PUBLIC
    AS [dbo];

