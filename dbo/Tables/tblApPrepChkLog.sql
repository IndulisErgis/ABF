CREATE TABLE [dbo].[tblApPrepChkLog] (
    [Counter]     INT              IDENTITY (1, 1) NOT NULL,
    [ErrorLogMsg] VARCHAR (150)    NULL,
    [CheckDate]   DATETIME         NULL,
    [ts]          ROWVERSION       NULL,
    [BatchID]     [dbo].[pBatchID] DEFAULT ('######') NOT NULL,
    PRIMARY KEY CLUSTERED ([Counter] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblApPrepChkLog] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblApPrepChkLog] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblApPrepChkLog] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblApPrepChkLog] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApPrepChkLog';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApPrepChkLog';

