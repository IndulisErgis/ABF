CREATE TABLE [dbo].[ALP_tblJmPricePlanGenHeader] (
    [PriceId]     VARCHAR (15) NOT NULL,
    [Desc]        VARCHAR (50) NULL,
    [DfltAdjBase] INT          NULL,
    [DfltAdjType] INT          NULL,
    [DfltAdjAmt]  [dbo].[pDec] NULL,
    [InactiveYN]  BIT          CONSTRAINT [DF_tblJmPricePlanGenHeader_InactiveYN] DEFAULT (0) NULL,
    [ts]          ROWVERSION   NULL,
    CONSTRAINT [PK_tblJmPricePlanGenHeader] PRIMARY KEY CLUSTERED ([PriceId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgJmPricePlanGenHeaderD] ON [dbo].[ALP_tblJmPricePlanGenHeader] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmSvcTkt */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTkt WHERE (deleted.PriceId = ALP_tblJmSvcTkt.PriceId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.PriceId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgJmPricePlanGenHeaderD', @FldVal, 'ALP_tblJmSvcTkt.PriceId')
    Set @Undo = 1
END
/* END tblJmSvcTkt */
If @Undo = 0
Begin
	/* BEGIN tblJmPricePlanGenDetail */
	DELETE ALP_tblJmPricePlanGenDetail FROM deleted, ALP_tblJmPricePlanGenDetail
	WHERE deleted.PriceId = ALP_tblJmPricePlanGenDetail.PriceId
	/* END tbJmPricePlanGenDetail*/
	
End
Else
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgJmPricePlanGenHeaderU] ON [dbo].[ALP_tblJmPricePlanGenHeader] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmPricePlanGenDetail */
IF (UPDATE(PriceId))
BEGIN
    UPDATE ALP_tblJmPricePlanGenDetail
    SET ALP_tblJmPricePlanGenDetail.PriceId = inserted.PriceId
    FROM ALP_tblJmPricePlanGenDetail, deleted, inserted
    WHERE deleted.PriceId = ALP_tblJmPricePlanGenDetail.PriceId
END
/* END tblJmPricePlanGenDetail */
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmPricePlanGenHeader] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmPricePlanGenHeader] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmPricePlanGenHeader] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmPricePlanGenHeader] TO PUBLIC
    AS [dbo];

