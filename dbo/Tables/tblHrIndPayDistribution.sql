CREATE TABLE [dbo].[tblHrIndPayDistribution] (
    [ID]            BIGINT           NOT NULL,
    [IndId]         [dbo].[pEmpID]   NOT NULL,
    [AccountType]   TINYINT          CONSTRAINT [DF_tblHrIndPayDistribution_AccountType] DEFAULT ((0)) NOT NULL,
    [AccountNumber] NVARCHAR (255)   NULL,
    [RoutingCode]   NVARCHAR (50)    NULL,
    [AmountPercent] [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndPayDistribution_AmountPercent] DEFAULT ((0)) NOT NULL,
    [CF]            XML              NULL,
    [ts]            ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrIndPayDistribution] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndPayDistribution_IndId]
    ON [dbo].[tblHrIndPayDistribution]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndPayDistribution';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndPayDistribution';

