CREATE TABLE [dbo].[tblFaAsset] (
    [AssetId]           [dbo].[pAssetID]     NOT NULL,
    [AssetPrefix]       VARCHAR (9)          NULL,
    [AssetDescr]        [dbo].[pDescription] NULL,
    [Manufacturer]      [dbo].[pDescription] NULL,
    [ModelNo]           [dbo].[pDescription] NULL,
    [SerialNo]          [dbo].[pDescription] NULL,
    [TagNo]             [dbo].[pDescription] NULL,
    [TaxDist1]          VARCHAR (15)         NULL,
    [TaxDist2]          VARCHAR (15)         NULL,
    [TaxDist3]          VARCHAR (15)         NULL,
    [Locat1]            VARCHAR (15)         NULL,
    [Locat2]            VARCHAR (15)         NULL,
    [Locat3]            VARCHAR (15)         NULL,
    [AssetStatus]       TINYINT              CONSTRAINT [DF__tblFaAsse__Asset__6C6EDFCD] DEFAULT (0) NOT NULL,
    [OwnedAsset]        BIT                  NOT NULL,
    [NewAsset]          BIT                  NOT NULL,
    [PersonalProperty]  BIT                  NOT NULL,
    [ListedProperty]    BIT                  NOT NULL,
    [InsurableProperty] BIT                  NOT NULL,
    [AssetClass]        VARCHAR (6)          NULL,
    [TaxClass]          VARCHAR (4)          NULL,
    [GLAsset]           [dbo].[pGlAcct]      NULL,
    [GLAccum]           [dbo].[pGlAcct]      NULL,
    [GLExpense]         [dbo].[pGlAcct]      NULL,
    [CreditDescr]       [dbo].[pDescription] NULL,
    [AcquisitionCost]   [dbo].[pDec]         CONSTRAINT [DF__tblFaAsse__Acqui__6D630406] DEFAULT (0) NOT NULL,
    [AcquisitionDate]   DATETIME             NULL,
    [RetirementDate]    DATETIME             NULL,
    [Qty]               INT                  CONSTRAINT [DF__tblFaAsset__Qty__6E57283F] DEFAULT (0) NOT NULL,
    [InsuredValue]      [dbo].[pDec]         CONSTRAINT [DF__tblFaAsse__Insur__6F4B4C78] DEFAULT (0) NOT NULL,
    [InsuredValueDate]  DATETIME             NULL,
    [AssessedValue]     [dbo].[pDec]         CONSTRAINT [DF__tblFaAsse__Asses__703F70B1] DEFAULT (0) NOT NULL,
    [AssessedValueDate] DATETIME             NULL,
    [ReplaceCost]       [dbo].[pDec]         CONSTRAINT [DF__tblFaAsse__Repla__713394EA] DEFAULT (0) NOT NULL,
    [ReplaceCostDate]   DATETIME             NULL,
    [PlacedInServDate]  DATETIME             NULL,
    [TaxPaid]           [dbo].[pDec]         CONSTRAINT [DF__tblFaAsse__TaxPa__7227B923] DEFAULT (0) NOT NULL,
    [AccumNonDeprcCost] [dbo].[pDec]         CONSTRAINT [DF__tblFaAsse__Accum__731BDD5C] DEFAULT (0) NOT NULL,
    [AdjustedCost]      [dbo].[pDec]         CONSTRAINT [DF__tblFaAsse__Adjus__74100195] DEFAULT (0) NOT NULL,
    [AdjustedDate]      DATETIME             NULL,
    [TotalCredits]      [dbo].[pDec]         CONSTRAINT [DF__tblFaAsse__Total__750425CE] DEFAULT (0) NOT NULL,
    [NoteField]         VARCHAR (MAX)        NULL,
    [Resv1]             [dbo].[pDec]         CONSTRAINT [DF__tblFaAsse__Resv1__75F84A07] DEFAULT (0) NULL,
    [Resv2]             VARCHAR (10)         NULL,
    [ts]                ROWVERSION           NULL,
    [UseJCWAAYn]        BIT                  DEFAULT ((0)) NULL,
    [CF]                XML                  NULL,
    [BonusDeprPct]      [dbo].[pDec]         CONSTRAINT [DF_tblFaAsset_BonusDeprPct] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__tblFaAsset__67A95F59] PRIMARY KEY CLUSTERED ([AssetId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblFaAsset] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblFaAsset] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblFaAsset] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblFaAsset] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFaAsset';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFaAsset';

