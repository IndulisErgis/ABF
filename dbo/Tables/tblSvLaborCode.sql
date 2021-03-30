CREATE TABLE [dbo].[tblSvLaborCode] (
    [LaborCode]             NVARCHAR (10)   NOT NULL,
    [Description]           NVARCHAR (35)   NULL,
    [AdditionalDescription] NVARCHAR (MAX)  NULL,
    [Unit]                  NVARCHAR (5)    NULL,
    [BillingRate]           [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [UnitCost]              [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [GLAcctSales]           [dbo].[pGlAcct] NOT NULL,
    [GLAcctCost]            [dbo].[pGlAcct] NOT NULL,
    [GLAcctPayroll]         [dbo].[pGlAcct] NOT NULL,
    [TaxClass]              TINYINT         NOT NULL,
    [CalendarColor]         INT             NULL,
    [CF]                    XML             NULL,
    [ts]                    ROWVERSION      NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvLaborCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvLaborCode';

