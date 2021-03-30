CREATE TABLE [dbo].[tblPaCheckDistribution] (
    [CheckId]         INT          NOT NULL,
    [DistributionId]  INT          NOT NULL,
    [CurrentAmount]   [dbo].[pDec] CONSTRAINT [DF_tblPaCheckDistribution_CurrentAmount] DEFAULT ((0)) NOT NULL,
    [DirectDepositYN] BIT          CONSTRAINT [DF_tblPaCheckDistribution_DirectDepositYN] DEFAULT ((0)) NOT NULL,
    [TraceNumber]     INT          CONSTRAINT [DF_tblPaCheckDistribution_TraceNumber] DEFAULT ((0)) NULL,
    [CF]              XML          NULL,
    [ts]              ROWVERSION   NULL,
    CONSTRAINT [PK_tblPaCheckDistribution] PRIMARY KEY CLUSTERED ([CheckId] ASC, [DistributionId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckDistribution';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckDistribution';

