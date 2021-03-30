CREATE TABLE [dbo].[tblFaRetire] (
    [RetirementID]      INT                  CONSTRAINT [DF__tblFaReti__Retir__1D121728] DEFAULT (0) NOT NULL,
    [AssetId]           [dbo].[pAssetID]     NULL,
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
    [AssetStatus]       TINYINT              CONSTRAINT [DF__tblFaReti__Asset__1E063B61] DEFAULT (0) NOT NULL,
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
    [AcquisitionCost]   [dbo].[pDec]         CONSTRAINT [DF__tblFaReti__Acqui__1EFA5F9A] DEFAULT (0) NOT NULL,
    [AcquisitionDate]   DATETIME             NULL,
    [RetirementDate]    DATETIME             NULL,
    [Qty]               INT                  CONSTRAINT [DF__tblFaRetire__Qty__1FEE83D3] DEFAULT (0) NOT NULL,
    [InsuredValue]      [dbo].[pDec]         CONSTRAINT [DF__tblFaReti__Insur__20E2A80C] DEFAULT (0) NOT NULL,
    [InsuredValueDate]  DATETIME             NULL,
    [AssessedValue]     [dbo].[pDec]         CONSTRAINT [DF__tblFaReti__Asses__21D6CC45] DEFAULT (0) NOT NULL,
    [AssessedValueDate] DATETIME             NULL,
    [ReplaceCost]       [dbo].[pDec]         CONSTRAINT [DF__tblFaReti__Repla__22CAF07E] DEFAULT (0) NOT NULL,
    [ReplaceCostDate]   DATETIME             NULL,
    [PlacedInServDate]  DATETIME             NULL,
    [TaxPaid]           [dbo].[pDec]         CONSTRAINT [DF__tblFaReti__TaxPa__23BF14B7] DEFAULT (0) NOT NULL,
    [AccumNonDeprcCost] [dbo].[pDec]         CONSTRAINT [DF__tblFaReti__Accum__24B338F0] DEFAULT (0) NOT NULL,
    [AdjustedCost]      [dbo].[pDec]         CONSTRAINT [DF__tblFaReti__Adjus__25A75D29] DEFAULT (0) NOT NULL,
    [AdjustedDate]      DATETIME             NULL,
    [TotalCredits]      [dbo].[pDec]         CONSTRAINT [DF__tblFaReti__Total__269B8162] DEFAULT (0) NOT NULL,
    [NoteField]         VARCHAR (MAX)        NULL,
    [Resv1]             [dbo].[pDec]         CONSTRAINT [DF__tblFaReti__Resv1__278FA59B] DEFAULT (0) NULL,
    [Resv2]             VARCHAR (10)         NULL,
    [RetireReason]      [dbo].[pDescription] NULL,
    [RetireCode]        VARCHAR (1)          NULL,
    [RetireDate]        DATETIME             NULL,
    [RetireQty]         INT                  CONSTRAINT [DF__tblFaReti__Retir__2883C9D4] DEFAULT (0) NOT NULL,
    [RetireAmt]         [dbo].[pDec]         CONSTRAINT [DF__tblFaReti__Retir__2977EE0D] DEFAULT (0) NOT NULL,
    [RetireProceeds]    [dbo].[pDec]         CONSTRAINT [DF__tblFaReti__Retir__2A6C1246] DEFAULT (0) NOT NULL,
    [RetireExpense]     [dbo].[pDec]         CONSTRAINT [DF__tblFaReti__Retir__2B60367F] DEFAULT (0) NOT NULL,
    [RetireCredits]     [dbo].[pDec]         CONSTRAINT [DF__tblFaReti__Retir__2C545AB8] DEFAULT (0) NOT NULL,
    [RetireAcqCosts]    [dbo].[pDec]         CONSTRAINT [DF__tblFaReti__Retir__2D487EF1] DEFAULT (0) NOT NULL,
    [ts]                ROWVERSION           NULL,
    [UseJCWAAYn]        BIT                  DEFAULT ((0)) NULL,
    [CF]                XML                  NULL,
    [BonusDeprPct]      [dbo].[pDec]         CONSTRAINT [DF_tblFaRetire_BonusDeprPct] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__tblFaRetire__6C6E1476] PRIMARY KEY CLUSTERED ([RetirementID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblFaRetire_AssetId]
    ON [dbo].[tblFaRetire]([AssetId] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblFaRetire] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblFaRetire] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblFaRetire] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblFaRetire] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFaRetire';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFaRetire';

