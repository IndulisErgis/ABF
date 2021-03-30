CREATE TABLE [dbo].[tblHrIndSalary] (
    [ID]                 BIGINT           NOT NULL,
    [IndId]              [dbo].[pEmpID]   NOT NULL,
    [EffectiveDate]      DATETIME         NOT NULL,
    [Reason]             NVARCHAR (255)   NULL,
    [Salary]             [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndSalary_Salary] DEFAULT ((0)) NOT NULL,
    [HourlyRate]         [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndSalary_HourlyRate] DEFAULT ((0)) NOT NULL,
    [PayType]            TINYINT          CONSTRAINT [DF_tblHrIndSalary_PayType] DEFAULT ((0)) NOT NULL,
    [ExemptFromOvertime] BIT              CONSTRAINT [DF_tblHrIndSalary_ExemptFromOvertime] DEFAULT ((0)) NOT NULL,
    [CF]                 XML              NULL,
    [ts]                 ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrIndSalary] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndSalary_IndId]
    ON [dbo].[tblHrIndSalary]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndSalary';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndSalary';

