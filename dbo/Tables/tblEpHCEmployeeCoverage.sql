CREATE TABLE [dbo].[tblEpHCEmployeeCoverage] (
    [ID]         BIGINT         NOT NULL,
    [HeaderId]   BIGINT         NOT NULL,
    [LastName]   NVARCHAR (20)  NULL,
    [FirstName]  NVARCHAR (15)  NULL,
    [MiddleInit] NVARCHAR (1)   NULL,
    [BirthDate]  DATETIME       NULL,
    [SSN]        NVARCHAR (255) NULL,
    [MonthFlag]  NVARCHAR (12)  NULL,
    [CF]         XML            NULL,
    [ts]         ROWVERSION     NULL,
    CONSTRAINT [PK_tblEpHCEmployeeCoverage] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblEpHCEmployeeCoverage';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblEpHCEmployeeCoverage';

