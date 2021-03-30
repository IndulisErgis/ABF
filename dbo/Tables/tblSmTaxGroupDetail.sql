CREATE TABLE [dbo].[tblSmTaxGroupDetail] (
    [LevelNo]  TINYINT         CONSTRAINT [DF__tblSmTaxG__Level__5C90AB1B] DEFAULT (0) NOT NULL,
    [TaxGrpID] [dbo].[pTaxLoc] NOT NULL,
    [TaxLocID] [dbo].[pTaxLoc] NOT NULL,
    [Tax1]     BIT             CONSTRAINT [DF__tblSmTaxGr__Tax1__5D84CF54] DEFAULT (0) NULL,
    [Tax2]     BIT             CONSTRAINT [DF__tblSmTaxGr__Tax2__5E78F38D] DEFAULT (0) NULL,
    [Tax3]     BIT             CONSTRAINT [DF__tblSmTaxGr__Tax3__5F6D17C6] DEFAULT (0) NULL,
    [Tax4]     BIT             CONSTRAINT [DF__tblSmTaxGr__Tax4__60613BFF] DEFAULT (0) NULL,
    [Tax5]     BIT             CONSTRAINT [DF__tblSmTaxGr__Tax5__61556038] DEFAULT (0) NULL,
    [ts]       ROWVERSION      NULL,
    [CF]       XML             NULL,
    CONSTRAINT [PK__tblSmTaxGroupDet__17236851] PRIMARY KEY CLUSTERED ([LevelNo] ASC, [TaxGrpID] ASC, [TaxLocID] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTaxGroupDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTaxGroupDetail';

