CREATE TABLE [dbo].[tblHrRetirementPlan] (
    [ID]                   BIGINT           NOT NULL,
    [Description]          NVARCHAR (50)    NOT NULL,
    [FrequencyTypeCodeID]  BIGINT           NULL,
    [TrusteeTypeCodeID]    BIGINT           NULL,
    [AccountNumber]        NVARCHAR (20)    NULL,
    [EmployerMatchPercent] [dbo].[pDecimal] CONSTRAINT [DF_tblHrRetirementPlan_EmployerMatchPercent] DEFAULT ((0)) NOT NULL,
    [EmployerMaxMatch]     [dbo].[pDecimal] CONSTRAINT [DF_tblHrRetirementPlan_EmployerMaxMatch] DEFAULT ((0)) NOT NULL,
    [MinimumAge]           INT              CONSTRAINT [DF_tblHrRetirementPlan_MinimumAge] DEFAULT ((0)) NOT NULL,
    [WaitingPeriod]        INT              CONSTRAINT [DF_tblHrRetirementPlan_WaitingPeriod] DEFAULT ((0)) NOT NULL,
    [MaxContribution]      [dbo].[pDecimal] CONSTRAINT [DF_tblHrRetirementPlan_MaxContribution] DEFAULT ((0)) NOT NULL,
    [LoansAllowed]         BIT              CONSTRAINT [DF_tblHrRetirementPlan_LoansAllowed] DEFAULT ((0)) NOT NULL,
    [CF]                   XML              NULL,
    [ts]                   ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrRetirementPlan] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblHrRetirementPlan_Description]
    ON [dbo].[tblHrRetirementPlan]([Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrRetirementPlan';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrRetirementPlan';

