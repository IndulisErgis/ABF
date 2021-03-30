CREATE TABLE [dbo].[tblEpHCEmployee] (
    [ID]             BIGINT         NOT NULL,
    [PaYear]         SMALLINT       NOT NULL,
    [EmployeeId]     [dbo].[pEmpID] NOT NULL,
    [ElectronicOnly] BIT            NOT NULL,
    [PolicyOrigin]   NVARCHAR (10)  NULL,
    [SelfInsured]    BIT            NOT NULL,
    [CF]             XML            NULL,
    [ts]             ROWVERSION     NULL,
    CONSTRAINT [PK_tblEpHCEmployee] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblEpHCEmployee_PaYearEmployeeId]
    ON [dbo].[tblEpHCEmployee]([PaYear] ASC, [EmployeeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblEpHCEmployee';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblEpHCEmployee';

