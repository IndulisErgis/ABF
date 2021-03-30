CREATE TABLE [dbo].[tblEpHCEmployerMember] (
    [ID]                BIGINT         NOT NULL,
    [HeaderId]          BIGINT         NOT NULL,
    [Name]              NVARCHAR (30)  NULL,
    [EIN]               NVARCHAR (255) NULL,
    [FullTimeEmployees] INT            NOT NULL,
    [CF]                XML            NULL,
    [ts]                ROWVERSION     NULL,
    CONSTRAINT [PK_tblEpHCEmployerMember] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblEpHCEmployerMember';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblEpHCEmployerMember';

