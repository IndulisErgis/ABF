CREATE TABLE [dbo].[tblPaCheckDeduct] (
    [Id]               INT           IDENTITY (1, 1) NOT NULL,
    [CheckId]          INT           NOT NULL,
    [DeductionCode]    [dbo].[pCode] NULL,
    [DeductionHours]   [dbo].[pDec]  CONSTRAINT [DF_tblPaCheckDeduct_DeductionHours] DEFAULT ((0)) NOT NULL,
    [DeductionAmount]  [dbo].[pDec]  CONSTRAINT [DF_tblPaCheckDeduct_DeductionAmount] DEFAULT ((0)) NOT NULL,
    [DeductionBalance] [dbo].[pDec]  CONSTRAINT [DF_tblPaCheckDeduct_DeductionBalance] DEFAULT ((0)) NOT NULL,
    [CF]               XML           NULL,
    [ts]               ROWVERSION    NULL,
    CONSTRAINT [PK_tblPaCheckDeduct] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaCheckDeduct_CheckId]
    ON [dbo].[tblPaCheckDeduct]([CheckId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckDeduct';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckDeduct';

