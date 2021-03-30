CREATE TABLE [dbo].[tblHrIndRetirement] (
    [ID]                    BIGINT           NOT NULL,
    [IndId]                 [dbo].[pEmpID]   NOT NULL,
    [RetPlanID]             BIGINT           NOT NULL,
    [StartDate]             DATETIME         NOT NULL,
    [EndDate]               DATETIME         NULL,
    [AllocMethodTypeCodeID] BIGINT           NOT NULL,
    [PreTaxNumber]          [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndRetirement_PreTaxNumber] DEFAULT ((0)) NOT NULL,
    [AfterTaxNumber]        [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndRetirement_AfterTaxNumber] DEFAULT ((0)) NOT NULL,
    [BonusNumber]           [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndRetirement_BonusNumber] DEFAULT ((0)) NOT NULL,
    [LoanAmount]            DECIMAL (18)     CONSTRAINT [DF_tblHrIndRetirement_LoanAmount] DEFAULT ((0)) NOT NULL,
    [CF]                    XML              NULL,
    [ts]                    ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrIndRetirement] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndRetirement_IndId]
    ON [dbo].[tblHrIndRetirement]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndRetirement';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndRetirement';

