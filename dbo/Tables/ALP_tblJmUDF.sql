CREATE TABLE [dbo].[ALP_tblJmUDF] (
    [UDFId]      INT           IDENTITY (1, 1) NOT NULL,
    [UDF]        VARCHAR (10)  NULL,
    [Desc]       VARCHAR (255) NULL,
    [RequiredYN] BIT           CONSTRAINT [DF_tblJmUDF_RequiredYN] DEFAULT (0) NULL,
    [InactiveYN] BIT           CONSTRAINT [DF_tblJmUDF_InactiveYN] DEFAULT (0) NULL,
    [ts]         ROWVERSION    NULL,
    CONSTRAINT [PK_tblJmUDF] PRIMARY KEY CLUSTERED ([UDFId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgJmUDFD] ON [dbo].[ALP_tblJmUDF] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmSvcTktUDF */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTktUDF WHERE (deleted.UDFId = ALP_tblJmSvcTktUDF.UDFId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.UDFId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgJmUDFD', @FldVal, 'ALP_tblJmSvcTktUDF.UDFId')
    Set @Undo = 1
END
/* END tblJmSvcTktUDF */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmUDF] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmUDF] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmUDF] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmUDF] TO PUBLIC
    AS [dbo];

