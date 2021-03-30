CREATE TABLE [dbo].[tblFaAssetDepr] (
    [AssetID]         [dbo].[pAssetID] NOT NULL,
    [DeprcType]       VARCHAR (6)      NOT NULL,
    [Method]          VARCHAR (6)      CONSTRAINT [DF__tblFaAsse__Metho__78D4B6B2] DEFAULT ('NONE') NOT NULL,
    [AppyBusinessUse] TINYINT          CONSTRAINT [DF__tblFaAsse__AppyB__79C8DAEB] DEFAULT (100) NOT NULL,
    [SwitchMethod]    VARCHAR (6)      CONSTRAINT [DF__tblFaAsse__Switc__7ABCFF24] DEFAULT ('NONE') NOT NULL,
    [BeginYr]         INT              CONSTRAINT [DF__tblFaAsse__Begin__7BB1235D] DEFAULT (0) NOT NULL,
    [BeginPd]         SMALLINT         CONSTRAINT [DF__tblFaAsse__Begin__7CA54796] DEFAULT (0) NOT NULL,
    [EndYr]           INT              CONSTRAINT [DF__tblFaAsse__EndYr__7D996BCF] DEFAULT (0) NOT NULL,
    [EndPd]           SMALLINT         CONSTRAINT [DF__tblFaAsse__EndPd__7E8D9008] DEFAULT (0) NOT NULL,
    [Life]            [dbo].[pDec]     CONSTRAINT [DF__tblFaAsset__Life__7F81B441] DEFAULT (0) NOT NULL,
    [Recovery]        INT              CONSTRAINT [DF__tblFaAsse__Recov__0075D87A] DEFAULT (0) NOT NULL,
    [BaseCost]        [dbo].[pDec]     CONSTRAINT [DF__tblFaAsse__BaseC__0169FCB3] DEFAULT (0) NOT NULL,
    [SalvageValue]    [dbo].[pDec]     CONSTRAINT [DF__tblFaAsse__Salva__025E20EC] DEFAULT (0) NOT NULL,
    [BonusDepr]       [dbo].[pDec]     CONSTRAINT [DF__tblFaAsse__Bonus__03524525] DEFAULT (0) NOT NULL,
    [Expense179]      [dbo].[pDec]     CONSTRAINT [DF__tblFaAsse__179Ex__0446695E] DEFAULT (0) NOT NULL,
    [Credits]         [dbo].[pDec]     CONSTRAINT [DF__tblFaAsse__Credi__053A8D97] DEFAULT (0) NOT NULL,
    [TotDeprTaken]    [dbo].[pDec]     CONSTRAINT [DF__tblFaAsse__TotDe__062EB1D0] DEFAULT (0) NULL,
    [TotDeprElig]     [dbo].[pDec]     CONSTRAINT [DF__tblFaAsse__TotDe__0722D609] DEFAULT (0) NOT NULL,
    [YTDDepr]         [dbo].[pDec]     CONSTRAINT [DF__tblFaAsse__YTDDe__0816FA42] DEFAULT (0) NULL,
    [AnnualDepr]      [dbo].[pDec]     CONSTRAINT [DF__tblFaAsse__Annua__090B1E7B] DEFAULT (0) NOT NULL,
    [CurrDepr]        [dbo].[pDec]     CONSTRAINT [DF__tblFaAsse__CurrD__09FF42B4] DEFAULT (0) NOT NULL,
    [Resv1]           [dbo].[pDec]     CONSTRAINT [DF__tblFaAsse__Resv1__0AF366ED] DEFAULT (0) NULL,
    [ts]              ROWVERSION       NULL,
    [CF]              XML              NULL,
    [ID]              INT              NOT NULL,
    CONSTRAINT [PK_tblFaAssetDepr] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblFaAssetDepr_Method]
    ON [dbo].[tblFaAssetDepr]([Method] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblFaAssetDepr_AssetIDDeprcType]
    ON [dbo].[tblFaAssetDepr]([AssetID] ASC, [DeprcType] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblFaAssetDepr] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblFaAssetDepr] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblFaAssetDepr] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblFaAssetDepr] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFaAssetDepr';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFaAssetDepr';

