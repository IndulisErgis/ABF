CREATE TABLE [dbo].[tblMrOperationsTooling] (
    [OperationID] VARCHAR (10) NOT NULL,
    [ToolingId]   VARCHAR (10) NOT NULL,
    [ts]          ROWVERSION   NULL,
    [CF]          XML          NULL,
    PRIMARY KEY CLUSTERED ([OperationID] ASC, [ToolingId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqltblMrOperationsToolingToolingId]
    ON [dbo].[tblMrOperationsTooling]([ToolingId] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMrOperationsTooling] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMrOperationsTooling] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMrOperationsTooling] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMrOperationsTooling] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrOperationsTooling';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrOperationsTooling';

