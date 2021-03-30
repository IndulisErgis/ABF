CREATE TABLE [dbo].[tblSmTaxGroup] (
    [TaxGrpID]     [dbo].[pTaxLoc] NOT NULL,
    [Desc]         VARCHAR (30)    NULL,
    [ReportMethod] TINYINT         CONSTRAINT [DF__tblSmTaxG__Repor__59B43E70] DEFAULT (0) NULL,
    [LevelOne]     [dbo].[pTaxLoc] NULL,
    [LevelTwo]     [dbo].[pTaxLoc] NULL,
    [LevelThree]   [dbo].[pTaxLoc] NULL,
    [LevelFour]    [dbo].[pTaxLoc] NULL,
    [LevelFive]    [dbo].[pTaxLoc] NULL,
    [ts]           ROWVERSION      NULL,
    [CF]           XML             NULL,
    CONSTRAINT [PK__tblSmTaxGroup__162F4418] PRIMARY KEY CLUSTERED ([TaxGrpID] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblSmTaxGroup] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTaxGroup';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTaxGroup';

