CREATE TABLE [dbo].[tblPcAdjustment] (
    [Id]              INT                  IDENTITY (1, 1) NOT NULL,
    [ProjectDetailId] INT                  NOT NULL,
    [FiscalPeriod]    SMALLINT             NOT NULL,
    [FiscalYear]      SMALLINT             NOT NULL,
    [TransDate]       DATETIME             NOT NULL,
    [Type]            TINYINT              NOT NULL,
    [Description]     [dbo].[pDescription] NULL,
    [AddnlDesc]       NVARCHAR (MAX)       NULL,
    [Qty]             [dbo].[pDec]         CONSTRAINT [DF_tblPcAdjustment_Qty] DEFAULT ((0)) NOT NULL,
    [ExtCost]         [dbo].[pDec]         CONSTRAINT [DF_tblPcAdjustment_ExtCost] DEFAULT ((0)) NOT NULL,
    [ExtIncome]       [dbo].[pDec]         CONSTRAINT [DF_tblPcAdjustment_ExtIncome] DEFAULT ((0)) NOT NULL,
    [Status]          TINYINT              NOT NULL,
    [IncDec]          TINYINT              NOT NULL,
    [CF]              XML                  NULL,
    [ts]              ROWVERSION           NULL,
    CONSTRAINT [PK_tblPcAdjustment] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlProjectDetailId]
    ON [dbo].[tblPcAdjustment]([ProjectDetailId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcAdjustment';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcAdjustment';

