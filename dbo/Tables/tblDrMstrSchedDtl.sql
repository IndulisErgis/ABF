CREATE TABLE [dbo].[tblDrMstrSchedDtl] (
    [AssemblyID]  [dbo].[pItemID]      NULL,
    [LocID]       [dbo].[pLocID]       NULL,
    [ProdDate]    DATETIME             NOT NULL,
    [DaysInPd]    INT                  DEFAULT ((0)) NOT NULL,
    [Qty]         [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [Notes]       [dbo].[pDescription] NULL,
    [ts]          ROWVERSION           NULL,
    [CF]          XML                  NULL,
    [MstrSchedId] INT                  NOT NULL,
    CONSTRAINT [PK_tblDrMstrSchedDtl] PRIMARY KEY CLUSTERED ([MstrSchedId] ASC, [ProdDate] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDrMstrSchedDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDrMstrSchedDtl';

