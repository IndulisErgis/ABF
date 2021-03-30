CREATE TABLE [dbo].[tblSmTaxClass] (
    [TaxClassCode] TINYINT      NOT NULL,
    [Desc]         VARCHAR (35) NULL,
    [ts]           ROWVERSION   NULL,
    [CF]           XML          NULL,
    PRIMARY KEY CLUSTERED ([TaxClassCode] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblSmTaxClass] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTaxClass';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTaxClass';

