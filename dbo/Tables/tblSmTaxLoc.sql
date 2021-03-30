CREATE TABLE [dbo].[tblSmTaxLoc] (
    [TaxLocId]        [dbo].[pTaxLoc] NOT NULL,
    [Name]            VARCHAR (30)    NULL,
    [TaxLevel]        TINYINT         CONSTRAINT [DF__tblSmTaxL__TaxLe__6431CCE3] DEFAULT (1) NULL,
    [TaxAuthority]    VARCHAR (2)     NULL,
    [TaxId]           VARCHAR (20)    NULL,
    [TaxOnFreight]    BIT             CONSTRAINT [DF__tblSmTaxL__TaxOn__6525F11C] DEFAULT (0) NULL,
    [TaxOnMisc]       BIT             CONSTRAINT [DF__tblSmTaxL__TaxOn__661A1555] DEFAULT (0) NULL,
    [GLAcct]          [dbo].[pGlAcct] NULL,
    [TaxRefAcct]      [dbo].[pGlAcct] NULL,
    [IgnoreExpAcctYn] BIT             CONSTRAINT [DF__tblSmTaxL__Ignor__670E398E] DEFAULT (0) NULL,
    [ts]              ROWVERSION      NULL,
    [CF]              XML             NULL,
    CONSTRAINT [PK__tblSmTaxLoc__18178C8A] PRIMARY KEY CLUSTERED ([TaxLocId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTaxLoc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTaxLoc';

