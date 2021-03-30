CREATE TABLE [dbo].[ALP_tblCSTransmitterErrorsToBlock] (
    [ID]           INT            IDENTITY (1, 1) NOT NULL,
    [Transmitter]  NVARCHAR (36)  NOT NULL,
    [ErrorCode]    NVARCHAR (4)   NOT NULL,
    [DisabledDate] DATETIME       CONSTRAINT [DF_tblCSTransmitterErrorsToBlock_DisabledDate] DEFAULT (getdate()) NULL,
    [DisabledBy]   NVARCHAR (255) CONSTRAINT [DF_tblCSTransmitterErrorsToBlock_DisabledBy] DEFAULT (suser_sname()) NULL,
    CONSTRAINT [PK_tblCSTransmitterErrorsToBlock] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblCSTransmitterErrorsToBlock_TransErrorCode]
    ON [dbo].[ALP_tblCSTransmitterErrorsToBlock]([Transmitter] ASC, [ErrorCode] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblCSTransmitterErrorsToBlock] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblCSTransmitterErrorsToBlock] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblCSTransmitterErrorsToBlock] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblCSTransmitterErrorsToBlock] TO PUBLIC
    AS [dbo];

