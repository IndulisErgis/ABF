CREATE TABLE [dbo].[tblHrHealthInsurance] (
    [ID]                   BIGINT           NOT NULL,
    [Description]          NVARCHAR (50)    NOT NULL,
    [FrequencyTypeCodeID]  BIGINT           NULL,
    [CarrierTypeCodeID]    BIGINT           NULL,
    [GroupNumber]          NVARCHAR (20)    NULL,
    [EmployeeContribution] [dbo].[pDecimal] CONSTRAINT [DF_tblHrHealthInsurance_EmployeeContribution] DEFAULT ((0)) NOT NULL,
    [EmployerContribution] [dbo].[pDecimal] CONSTRAINT [DF_tblHrHealthInsurance_EmployerContribution] DEFAULT ((0)) NOT NULL,
    [MaximumAgeEmployee]   INT              CONSTRAINT [DF_tblHrHealthInsurance_MaximumAgeEmployee] DEFAULT ((0)) NOT NULL,
    [MaximumAgeDependent]  INT              CONSTRAINT [DF_tblHrHealthInsurance_MaximumAgeDependent] DEFAULT ((0)) NOT NULL,
    [WaitingPeriod]        INT              CONSTRAINT [DF_tblHrHealthInsurance_WaitingPeriod] DEFAULT ((0)) NOT NULL,
    [MaxOutOfPocket]       [dbo].[pDecimal] CONSTRAINT [DF_tblHrHealthInsurance_MaxOutOfPocket] DEFAULT ((0)) NOT NULL,
    [Deductible]           [dbo].[pDecimal] CONSTRAINT [DF_tblHrHealthInsurance_Deductible] DEFAULT ((0)) NOT NULL,
    [MaxBenefit]           [dbo].[pDecimal] CONSTRAINT [DF_tblHrHealthInsurance_MaxBenefit] DEFAULT ((0)) NOT NULL,
    [MajorMedicalCoverage] DECIMAL (18)     CONSTRAINT [DF_tblHrHealthInsurance_MajorMedicalCoverage] DEFAULT ((0)) NOT NULL,
    [COBRAPremium]         DECIMAL (18)     CONSTRAINT [DF_tblHrHealthInsurance_COBRAPremium] DEFAULT ((0)) NOT NULL,
    [CF]                   XML              NULL,
    [ts]                   ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrHealthInsurance] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblHrHealthInsurance_Description]
    ON [dbo].[tblHrHealthInsurance]([Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrHealthInsurance';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrHealthInsurance';

