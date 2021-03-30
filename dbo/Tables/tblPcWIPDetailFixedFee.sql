CREATE TABLE [dbo].[tblPcWIPDetailFixedFee] (
    [Id]               INT                  IDENTITY (1, 1) NOT NULL,
    [HeaderId]         INT                  NOT NULL,
    [BatchId]          [dbo].[pBatchID]     NOT NULL,
    [Description]      [dbo].[pDescription] NULL,
    [FixedFeeAmtApply] [dbo].[pDec]         CONSTRAINT [DF_tblPcWIPDetailFixedFee_FixedFeeAmtApply] DEFAULT ((0)) NOT NULL,
    [CF]               XML                  NULL,
    [ts]               ROWVERSION           NULL,
    CONSTRAINT [PK_tblPcWIPDetailFixedFee] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcWIPDetailFixedFee';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcWIPDetailFixedFee';

