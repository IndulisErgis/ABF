CREATE TABLE [dbo].[tblPcEstimate] (
    [Id]              INT           IDENTITY (1, 1) NOT NULL,
    [ProjectDetailId] INT           NOT NULL,
    [Type]            TINYINT       NOT NULL,
    [ResourceId]      NVARCHAR (24) NULL,
    [LocId]           NVARCHAR (10) NULL,
    [RateId]          NVARCHAR (10) NULL,
    [Description]     NVARCHAR (35) NULL,
    [Qty]             [dbo].[pDec]  CONSTRAINT [DF_tblPcEstimate_Qty] DEFAULT ((0)) NOT NULL,
    [Uom]             [dbo].[pUom]  NULL,
    [UnitCost]        [dbo].[pDec]  CONSTRAINT [DF_tblPcEstimate_UnitCost] DEFAULT ((0)) NOT NULL,
    [UnitPrice]       [dbo].[pDec]  CONSTRAINT [DF_tblPcEstimate_UnitPrice] DEFAULT ((0)) NOT NULL,
    [CF]              XML           NULL,
    [ts]              ROWVERSION    NULL,
    CONSTRAINT [PK_tblPcEstimate] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlProjectDetailId]
    ON [dbo].[tblPcEstimate]([ProjectDetailId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcEstimate';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcEstimate';

