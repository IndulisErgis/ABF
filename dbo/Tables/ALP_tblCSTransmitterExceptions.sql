CREATE TABLE [dbo].[ALP_tblCSTransmitterExceptions] (
    [Transmitter] NVARCHAR (36) NOT NULL,
    CONSTRAINT [PK_tblCSTransmitterExceptions] PRIMARY KEY NONCLUSTERED ([Transmitter] ASC) WITH (FILLFACTOR = 80)
);


GO

----------------------------------------------------------------
CREATE TRIGGER [dbo].[trgCSTransmitterExceptionsU] ON [dbo].[ALP_tblCSTransmitterExceptions] FOR UPDATE AS
SET NOCOUNT ON
IF (UPDATE(Transmitter))
BEGIN
    UPDATE dbo.ALP_tblCSTransmitterErrorsToBlock
    SET dbo.ALP_tblCSTransmitterErrorsToBlock.Transmitter = inserted.Transmitter
    FROM dbo.ALP_tblCSTransmitterErrorsToBlock, deleted, inserted
    WHERE deleted.Transmitter = dbo.ALP_tblCSTransmitterErrorsToBlock.Transmitter
END
GO
CREATE TRIGGER [dbo].[trgCSTransmitterExceptionsD] ON [dbo].[ALP_tblCSTransmitterExceptions] 
FOR DELETE 
AS
SET NOCOUNT ON
Begin
	DELETE ALP_tblCSTransmitterErrorsToBlock 
	FROM deleted,  ALP_tblCSTransmitterErrorsToBlock
	WHERE deleted.Transmitter =  ALP_tblCSTransmitterErrorsToBlock.Transmitter
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblCSTransmitterExceptions] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblCSTransmitterExceptions] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblCSTransmitterExceptions] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblCSTransmitterExceptions] TO PUBLIC
    AS [dbo];

