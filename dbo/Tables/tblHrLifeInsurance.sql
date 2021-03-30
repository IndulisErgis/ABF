CREATE TABLE [dbo].[tblHrLifeInsurance] (
    [ID]                  BIGINT           NOT NULL,
    [Description]         NVARCHAR (50)    NOT NULL,
    [FrequencyTypeCodeID] BIGINT           NULL,
    [CarrierTypeCodeID]   BIGINT           NULL,
    [GroupNumber]         NVARCHAR (20)    NULL,
    [CoverageMaxAmount]   [dbo].[pDecimal] CONSTRAINT [DF_tblHrLifeInsurance_CoverageMaxAmount] DEFAULT ((0)) NOT NULL,
    [PremiumMethod]       TINYINT          CONSTRAINT [DF_tblHrLifeInsurance_PremiumMethod] DEFAULT ((0)) NOT NULL,
    [WaitingPeriod]       INT              CONSTRAINT [DF_tblHrLifeInsurance_WaitingPeriod] DEFAULT ((0)) NOT NULL,
    [CF]                  XML              NULL,
    [ts]                  ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrLifeInsurance] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblHrLifeInsurance_Description]
    ON [dbo].[tblHrLifeInsurance]([Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrLifeInsurance';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrLifeInsurance';

