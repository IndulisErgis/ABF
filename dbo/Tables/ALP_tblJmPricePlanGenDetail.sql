CREATE TABLE [dbo].[ALP_tblJmPricePlanGenDetail] (
    [DetailID]     INT           IDENTITY (1, 1) NOT NULL,
    [PriceId]      VARCHAR (15)  NULL,
    [CustLevel]    VARCHAR (10)  NULL,
    [Desc]         VARCHAR (255) NULL,
    [PriceAdjBase] INT           NULL,
    [PriceAdjType] INT           NULL,
    [PriceAdjAmt]  [dbo].[pDec]  NULL,
    [ts]           ROWVERSION    NULL,
    CONSTRAINT [PK_tblJmPricePlanGenDetail] PRIMARY KEY CLUSTERED ([DetailID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgJmPricePlanGenDetailU] ON [dbo].[ALP_tblJmPricePlanGenDetail] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(PriceId))
BEGIN
	/* BEGIN tblJmPricePlanGenHeader */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblJmPricePlanGenHeader WHERE (deleted.PriceId = ALP_tblJmPricePlanGenHeader.PriceId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.PriceId As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgJmPricePlanGenDetailU', @FldVal, 'ALP_tblJmPricePlanGenHeader.PriceId')
		Set @Undo = 1
	END
	/* END tblJmPricePlanGenHeader */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgJmPricePlanGenDetaillD] ON [dbo].[ALP_tblJmPricePlanGenDetail] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmPricePlanGenHeader */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmPricePlanGenHeader WHERE (deleted.PriceId = ALP_tblJmPricePlanGenHeader.PriceId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.PriceId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgJmPricePlanGenDetailD', @FldVal, 'ALP_tblJmPricePlanGenHeader.PriceId')
    Set @Undo = 1
END
/* END tblJmPricePlanGenHeader */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmPricePlanGenDetail] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmPricePlanGenDetail] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmPricePlanGenDetail] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmPricePlanGenDetail] TO PUBLIC
    AS [dbo];

