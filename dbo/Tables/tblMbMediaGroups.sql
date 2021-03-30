CREATE TABLE [dbo].[tblMbMediaGroups] (
    [MGID]        VARCHAR (10)         NOT NULL,
    [Descr]       [dbo].[pDescription] NULL,
    [PrimaryLink] NVARCHAR (MAX)       NULL,
    [ts]          ROWVERSION           NULL,
    [CF]          XML                  NULL,
    CONSTRAINT [PK__tblMbMediaGroups__23218CE7] PRIMARY KEY CLUSTERED ([MGID] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMbMediaGroups] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMbMediaGroups] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMbMediaGroups] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMbMediaGroups] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMbMediaGroups';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMbMediaGroups';

