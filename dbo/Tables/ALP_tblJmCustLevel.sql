CREATE TABLE [dbo].[ALP_tblJmCustLevel] (
    [CustLevel]  VARCHAR (10) NOT NULL,
    [Desc]       VARCHAR (35) NULL,
    [InactiveYN] BIT          CONSTRAINT [DF_tblJmCustLevel_InactiveYN] DEFAULT (0) NULL,
    [ts]         ROWVERSION   NULL,
    CONSTRAINT [PK_tblJmCustLevel] PRIMARY KEY CLUSTERED ([CustLevel] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgJmCustLevelU] ON [dbo].[ALP_tblJmCustLevel] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(CustLevel))
BEGIN
	/* BEGIN tblJmPricePlanGenDetail */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblJmPricePlanGenDetail WHERE (deleted.CustLevel = ALP_tblJmPricePlanGenDetail.CustLevel)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.CustLevel As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgJmCustLevelU', @FldVal, 'ALP_tblJmPricePlanGenDetail.CustLevel')
		Set @Undo = 1
	END
	/* END tblJmPricePlanGenDetail */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgJmCustLevelD] ON [dbo].[ALP_tblJmCustLevel] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmPricePlanGenDetail */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmPricePlanGenDetail WHERE (deleted.CustLevel = ALP_tblJmPricePlanGenDetail.CustLevel)) > 0
BEGIN
    Select @FldVal = Cast(deleted.CustLevel As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgJmCustLevelD', @FldVal, 'ALP_tblJmPricePlanGenDetail.CustLevel')
    Set @Undo = 1
END
/* END tblJmPricePlanGenDetail */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmCustLevel] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmCustLevel] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmCustLevel] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmCustLevel] TO PUBLIC
    AS [dbo];

