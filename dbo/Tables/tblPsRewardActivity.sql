CREATE TABLE [dbo].[tblPsRewardActivity] (
    [ID]               BIGINT           NOT NULL,
    [ProgramID]        BIGINT           NOT NULL,
    [AccountID]        BIGINT           NOT NULL,
    [Type]             TINYINT          NOT NULL,
    [TransDate]        DATETIME         NOT NULL,
    [EntryDate]        DATETIME         NOT NULL,
    [PointQty]         [dbo].[pDecimal] NOT NULL,
    [PointValue]       [dbo].[pDecimal] NOT NULL,
    [ActivityGroup]    [dbo].[pPostRun] NULL,
    [PostRun]          [dbo].[pPostRun] NULL,
    [PostDate]         DATETIME         NULL,
    [FiscalYear]       SMALLINT         NOT NULL,
    [FiscalPeriod]     SMALLINT         NOT NULL,
    [LiabilityAccount] [dbo].[pGlAcct]  NULL,
    [GLAccount]        [dbo].[pGlAcct]  NULL,
    [Synched]          BIT              NOT NULL,
    [CF]               XML              NULL,
    [ts]               ROWVERSION       NULL,
    CONSTRAINT [PK_tblPsRewardActivity] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsRewardActivity_ActivityGroup]
    ON [dbo].[tblPsRewardActivity]([ActivityGroup] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsRewardActivity_AccountID]
    ON [dbo].[tblPsRewardActivity]([AccountID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsRewardActivity_ProgramID]
    ON [dbo].[tblPsRewardActivity]([ProgramID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsRewardActivity';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsRewardActivity';

