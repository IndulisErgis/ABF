CREATE TABLE [dbo].[ALP_tblArAlpPromotion] (
    [PromoId]    INT           IDENTITY (1, 1) NOT NULL,
    [Promo]      VARCHAR (10)  NULL,
    [Desc]       VARCHAR (255) NULL,
    [InactiveYN] BIT           NULL,
    [ts]         ROWVERSION    NULL,
    CONSTRAINT [PK_tblArAlpPromotion] PRIMARY KEY CLUSTERED ([PromoId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgArAlpPromotionU] ON [dbo].[ALP_tblArAlpPromotion] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(PromoID))
BEGIN
	/* BEGIN tblArAlpSite */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSite WHERE (deleted.PromoID = ALP_tblArAlpSite.PromoId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.PromoID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpPromotionU', @FldVal, 'ALP_tblArAlpSite.PromoId')
		Set @Undo = 1
	END
	/* END tblArAlpSite */
	/* BEGIN tblJmSvcTktProject */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTktProject WHERE (deleted.PromoID = ALP_tblJmSVcTktProject.PromoId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.PromoID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpPromotionU', @FldVal, 'ALP_tblJmSvcTktProject.PromoId')
		Set @Undo = 1
	END
	/* END tblJmSvcTktProject */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgArAlpPromotionD] ON [dbo].[ALP_tblArAlpPromotion] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblArAlpSite */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSite WHERE (deleted.PromoId = ALP_tblArAlpSite.PromoId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.PromoId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpPromotionD', @FldVal, 'ALP_tblArAlpSite.PromoId')
    Set @Undo = 1
END
/* END tblArAlpSite */
/* BEGIN tblJmSvcTktProject */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTktProject WHERE (deleted.PromoId = ALP_tblJmSvcTktProject.PromoId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.PromoId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpPromotionD', @FldVal, 'ALP_tblJmSvcTktProject.PromoId')
    Set @Undo = 1
END
/* END tblJmSvcTktProject */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpPromotion] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpPromotion] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpPromotion] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpPromotion] TO PUBLIC
    AS [dbo];

