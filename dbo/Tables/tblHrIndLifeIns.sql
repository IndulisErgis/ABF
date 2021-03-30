CREATE TABLE [dbo].[tblHrIndLifeIns] (
    [ID]                   BIGINT           NOT NULL,
    [IndId]                [dbo].[pEmpID]   NOT NULL,
    [LifeInsID]            BIGINT           NOT NULL,
    [PolicyNumber]         NVARCHAR (20)    NULL,
    [BenefitStartDate]     DATETIME         NOT NULL,
    [BenefitEndDate]       DATETIME         NULL,
    [CoverageSelf]         INT              CONSTRAINT [DF_tblHrIndLifeIns_CoverageSelf] DEFAULT ((0)) NOT NULL,
    [CoverageSpouse]       INT              CONSTRAINT [DF_tblHrIndLifeIns_CoverageSpouse] DEFAULT ((0)) NOT NULL,
    [CoverageChild]        INT              CONSTRAINT [DF_tblHrIndLifeIns_CoverageChild] DEFAULT ((0)) NOT NULL,
    [Smoker]               BIT              CONSTRAINT [DF_tblHrIndLifeIns_Smoker] DEFAULT ((0)) NOT NULL,
    [Beneficiary1]         NVARCHAR (35)    NULL,
    [Beneficiary2]         NVARCHAR (35)    NULL,
    [BeneficiaryRelation1] NVARCHAR (35)    NULL,
    [BeneficiaryRelation2] NVARCHAR (35)    NULL,
    [BeneficiaryPct1]      [dbo].[pDecimal] NULL,
    [BeneficiaryPct2]      [dbo].[pDecimal] NULL,
    [Contingency1]         NVARCHAR (35)    NULL,
    [Contingency2]         NVARCHAR (35)    NULL,
    [ContingencyRelation1] NVARCHAR (35)    NULL,
    [ContingencyRelation2] NVARCHAR (35)    NULL,
    [ContingencyPct1]      [dbo].[pDecimal] NULL,
    [ContingencyPct2]      [dbo].[pDecimal] NULL,
    [CF]                   XML              NULL,
    [ts]                   ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrIndLifeIns] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndLifeIns_IndId]
    ON [dbo].[tblHrIndLifeIns]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndLifeIns';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndLifeIns';

