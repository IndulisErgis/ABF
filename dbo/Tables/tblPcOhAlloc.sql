CREATE TABLE [dbo].[tblPcOhAlloc] (
    [OhAllCode]   NVARCHAR (6)  NOT NULL,
    [Description] NVARCHAR (50) NULL,
    [Hours]       [dbo].[pDec]  CONSTRAINT [DF_tblPcOhAlloc_Hours] DEFAULT ((0)) NOT NULL,
    [Time]        [dbo].[pDec]  CONSTRAINT [DF_tblPcOhAlloc_Time] DEFAULT ((0)) NOT NULL,
    [Material]    [dbo].[pDec]  CONSTRAINT [DF_tblPcOhAlloc_Material] DEFAULT ((0)) NOT NULL,
    [Expense]     [dbo].[pDec]  CONSTRAINT [DF_tblPcOhAlloc_Expense] DEFAULT ((0)) NOT NULL,
    [Other]       [dbo].[pDec]  CONSTRAINT [DF_tblPcOhAlloc_Other] DEFAULT ((0)) NOT NULL,
    [CF]          XML           NULL,
    [ts]          ROWVERSION    NULL,
    CONSTRAINT [PK_tblPcOhAlloc] PRIMARY KEY CLUSTERED ([OhAllCode] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcOhAlloc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcOhAlloc';

