CREATE TABLE [dbo].[ALP_tblArAlpFinSource] (
    [FinSourceId] INT           IDENTITY (1, 1) NOT NULL,
    [FinSource]   VARCHAR (10)  NULL,
    [Desc]        VARCHAR (255) NULL,
    [InactiveYN]  BIT           CONSTRAINT [DF_tblArAlpFinSource_InactiveYN] DEFAULT (0) NULL,
    [ts]          ROWVERSION    NULL,
    CONSTRAINT [PK_tblArAlpFinSource] PRIMARY KEY CLUSTERED ([FinSourceId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER trgArAlpFinSourceU ON [dbo].[ALP_tblArAlpFinSource] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(FinSourceID))
BEGIN
	/* BEGIN tblArAlpCustContract */
	IF (SELECT COUNT(*) FROM deleted, tblArAlpCustContract WHERE (deleted.FinSourceID = tblArAlpCustContract.FinSourceId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.FinSourceID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpFinSourceU', @FldVal, 'tblArAlpCustContract.FinSourceId')
		Set @Undo = 1
	END
	/* END tblArAlpCustContract */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER trgArAlpFinSourceD ON [dbo].[ALP_tblArAlpFinSource] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblArAlpCustContract */
IF (SELECT COUNT(*) FROM deleted, tblArAlpCustContract WHERE (deleted.FinSourceId = tblArAlpCustContract.FinSourceId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.FinSourceId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpFinSourceD', @FldVal, 'tblArAlpCustContract.FinSourceId')
    Set @Undo = 1
END
/* END tblArAlpCustContract */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpFinSource] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpFinSource] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpFinSource] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpFinSource] TO PUBLIC
    AS [dbo];

