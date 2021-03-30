CREATE TABLE [dbo].[tblPaCheckHistDistribution] (
    [PostRun]         [dbo].[pPostRun] NOT NULL,
    [CheckId]         INT              NOT NULL,
    [DistributionId]  INT              NOT NULL,
    [CurrentAmount]   [dbo].[pDec]     NOT NULL,
    [DirectDepositYN] BIT              NOT NULL,
    [TraceNumber]     INT              NULL,
    [CF]              XML              NULL,
    [ts]              ROWVERSION       NULL,
    CONSTRAINT [PK_tblPaCheckHistDistribution] PRIMARY KEY CLUSTERED ([PostRun] ASC, [CheckId] ASC, [DistributionId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckHistDistribution';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckHistDistribution';

