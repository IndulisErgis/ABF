CREATE TABLE [dbo].[ALP_tblJmTimeCode] (
    [TimeCodeID]  INT          IDENTITY (1, 1) NOT NULL,
    [TimeCode]    VARCHAR (10) NULL,
    [Desc]        VARCHAR (20) NULL,
    [TimeType]    TINYINT      NULL,
    [ToggleOrder] SMALLINT     NULL,
    [BarColor]    INT          NULL,
    [TextColor]   INT          NULL,
    [InactiveYN]  BIT          CONSTRAINT [DF_tblJmTimeCode_InactiveYN] DEFAULT (0) NULL,
    [ts]          ROWVERSION   NULL,
    CONSTRAINT [PK_tblJmTimeCode] PRIMARY KEY CLUSTERED ([TimeCodeID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgJmTimeCodetD] ON [dbo].[ALP_tblJmTimeCode] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmTimeCard */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmTimeCard WHERE (deleted.TimecodeId = ALP_tblJmTimeCard.TimeCodeId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.TimecodeId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgJmTimeCodeD', @FldVal, 'ALP_tblJmTimeCard.TimecodeId')
    Set @Undo = 1
END
/* END tblJmTimeCard */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmTimeCode] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmTimeCode] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmTimeCode] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmTimeCode] TO PUBLIC
    AS [dbo];

