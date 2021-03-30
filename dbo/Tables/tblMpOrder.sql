CREATE TABLE [dbo].[tblMpOrder] (
    [OrderNo]    [dbo].[pTransID] NOT NULL,
    [AssemblyId] [dbo].[pItemID]  NULL,
    [RevisionNo] VARCHAR (3)      NULL,
    [LocID]      [dbo].[pLocID]   NULL,
    [Planner]    VARCHAR (20)     NULL,
    [BuildYn]    INT              CONSTRAINT [DF_tblMpOrder_BuildYn] DEFAULT (1) NULL,
    [GLAcctWIP]  [dbo].[pGlAcct]  NULL,
    [ts]         ROWVERSION       NULL,
    [CF]         XML              NULL,
    CONSTRAINT [PK__tblMpOrder__7C46EB91] PRIMARY KEY CLUSTERED ([OrderNo] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblMpOrder] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblMpOrder] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblMpOrder] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblMpOrder] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpOrder';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpOrder';

