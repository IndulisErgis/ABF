CREATE TABLE [dbo].[tblHrIndHealth] (
    [ID]               BIGINT         NOT NULL,
    [IndId]            [dbo].[pEmpID] NOT NULL,
    [HealthInsID]      BIGINT         NOT NULL,
    [BenefitStartDate] DATETIME       NOT NULL,
    [BenefitEndDate]   DATETIME       NULL,
    [PolicyNumber]     NVARCHAR (20)  NULL,
    [CF]               XML            NULL,
    [ts]               ROWVERSION     NULL,
    CONSTRAINT [PK_tblHrIndHealth] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndHealth_IndId]
    ON [dbo].[tblHrIndHealth]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndHealth';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndHealth';

