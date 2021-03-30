CREATE TABLE [dbo].[tblPaEmpPayDistribution] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [EmployeeId]    [dbo].[pEmpID] NOT NULL,
    [AccountType]   TINYINT        CONSTRAINT [DF_tblPaEmpPayDistribution_AccountType] DEFAULT ((0)) NOT NULL,
    [PrenoteOut]    BIT            CONSTRAINT [DF_tblPaEmpPayDistribution_PrenoteOut] DEFAULT ((0)) NOT NULL,
    [PrenoteIn]     BIT            CONSTRAINT [DF_tblPaEmpPayDistribution_PrenoteIn] DEFAULT ((0)) NOT NULL,
    [AccountNumber] NVARCHAR (255) NULL,
    [RoutingCode]   NVARCHAR (50)  NULL,
    [AmountPercent] [dbo].[pDec]   NOT NULL,
    [TraceNumber]   INT            CONSTRAINT [DF_tblPaEmpPayDistribution_TraceNumber] DEFAULT ((0)) NULL,
    [CF]            XML            NULL,
    [ts]            ROWVERSION     NULL,
    CONSTRAINT [PK_tblPaEmpPayDistribution] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaEmpPayDistribution_EmployeeId]
    ON [dbo].[tblPaEmpPayDistribution]([EmployeeId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpPayDistribution';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpPayDistribution';

