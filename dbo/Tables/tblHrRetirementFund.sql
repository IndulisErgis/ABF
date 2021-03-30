CREATE TABLE [dbo].[tblHrRetirementFund] (
    [ID]          BIGINT        NOT NULL,
    [RetPlanID]   BIGINT        NOT NULL,
    [Description] NVARCHAR (50) NULL,
    [Active]      BIT           CONSTRAINT [DF_tblHrRetirementFund_Active] DEFAULT ((0)) NOT NULL,
    [CF]          XML           NULL,
    [ts]          ROWVERSION    NULL,
    CONSTRAINT [PK_tblHrRetirementFund] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblHrRetirementFund_RetPlanIDDescription]
    ON [dbo].[tblHrRetirementFund]([RetPlanID] ASC, [Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrRetirementFund';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrRetirementFund';

