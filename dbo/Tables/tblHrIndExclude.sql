CREATE TABLE [dbo].[tblHrIndExclude] (
    [IndId]        [dbo].[pEmpID] NOT NULL,
    [WithholdId]   BIGINT         NOT NULL,
    [Code]         [dbo].[pCode]  NOT NULL,
    [EmployerPaid] BIT            CONSTRAINT [DF_tblHrIndExclude_EmployerPaid] DEFAULT ((0)) NOT NULL,
    [CF]           XML            NULL,
    [ts]           ROWVERSION     NULL,
    CONSTRAINT [PK_tblHrIndExclude] PRIMARY KEY CLUSTERED ([IndId] ASC, [WithholdId] ASC, [Code] ASC, [EmployerPaid] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndExclude';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndExclude';

