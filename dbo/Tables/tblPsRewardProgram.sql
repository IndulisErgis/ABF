CREATE TABLE [dbo].[tblPsRewardProgram] (
    [ID]               BIGINT               NOT NULL,
    [Description]      [dbo].[pDescription] NOT NULL,
    [Status]           TINYINT              NOT NULL,
    [Type]             TINYINT              NOT NULL,
    [Prompt]           TINYINT              NOT NULL,
    [StartDate]        DATETIME             NULL,
    [EndDate]          DATETIME             NULL,
    [PointAccrualRate] [dbo].[pDecimal]     NOT NULL,
    [PointValue]       [dbo].[pDecimal]     NOT NULL,
    [LiabilityAccount] [dbo].[pGlAcct]      NULL,
    [ExpenseAccount]   [dbo].[pGlAcct]      NULL,
    [RedemptionRate]   [dbo].[pDecimal]     NOT NULL,
    [Synched]          BIT                  NOT NULL,
    [CF]               XML                  NULL,
    [ts]               ROWVERSION           NULL,
    CONSTRAINT [PK_tblPsRewardProgram] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPsRewardProgram_Description]
    ON [dbo].[tblPsRewardProgram]([Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsRewardProgram';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsRewardProgram';

