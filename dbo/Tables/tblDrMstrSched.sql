CREATE TABLE [dbo].[tblDrMstrSched] (
    [AssemblyID] [dbo].[pItemID] NOT NULL,
    [LocID]      [dbo].[pLocID]  NOT NULL,
    [UOM]        [dbo].[pUom]    NULL,
    [PdDefID]    VARCHAR (10)    NULL,
    [ts]         ROWVERSION      NULL,
    [CF]         XML             NULL,
    [Id]         INT             NOT NULL,
    CONSTRAINT [PK_tblDrMstrSched] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblDrMstrSched_AssemblyIdLocId]
    ON [dbo].[tblDrMstrSched]([AssemblyID] ASC, [LocID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDrMstrSched';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDrMstrSched';

