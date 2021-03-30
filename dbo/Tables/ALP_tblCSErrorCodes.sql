CREATE TABLE [dbo].[ALP_tblCSErrorCodes] (
    [ErrorCode]     NVARCHAR (4)   NOT NULL,
    [ErrorMessage]  NVARCHAR (50)  NOT NULL,
    [ErrorCategory] NVARCHAR (1)   NULL,
    [SvcCode]       NVARCHAR (15)  NULL,
    [Notes]         NVARCHAR (255) NULL,
    CONSTRAINT [PK_tblCSErrorCodes] PRIMARY KEY NONCLUSTERED ([ErrorCode] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCSErrorCodes_ErrorCategory]
    ON [dbo].[ALP_tblCSErrorCodes]([ErrorCategory] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_tblCSErrorCodes_SvcCode]
    ON [dbo].[ALP_tblCSErrorCodes]([SvcCode] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblCSErrorCodes] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblCSErrorCodes] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblCSErrorCodes] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblCSErrorCodes] TO PUBLIC
    AS [dbo];

