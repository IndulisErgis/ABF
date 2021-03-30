CREATE TABLE [dbo].[tblHrPositionEarnCode] (
    [ID]         BIGINT           NOT NULL,
    [PositionID] BIGINT           NOT NULL,
    [EarnCodeID] [dbo].[pCode]    NOT NULL,
    [RateType]   TINYINT          CONSTRAINT [DF_tblHrPositionEarnCode_RateType] DEFAULT ((0)) NOT NULL,
    [Rate]       [dbo].[pDecimal] CONSTRAINT [DF_tblHrPositionEarnCode_Rate] DEFAULT ((0)) NOT NULL,
    [CF]         XML              NULL,
    [ts]         ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrPositionEarnCode] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblHrPositionEarnCode_PositionIDEarnCodeID]
    ON [dbo].[tblHrPositionEarnCode]([PositionID] ASC, [EarnCodeID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrPositionEarnCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrPositionEarnCode';

