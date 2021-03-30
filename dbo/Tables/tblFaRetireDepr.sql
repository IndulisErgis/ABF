CREATE TABLE [dbo].[tblFaRetireDepr] (
    [RetirementID]    INT              CONSTRAINT [DF__tblFaReti__Retir__3024EB9C] DEFAULT (0) NOT NULL,
    [AssetID]         [dbo].[pAssetID] NOT NULL,
    [DeprcType]       VARCHAR (6)      NOT NULL,
    [Method]          VARCHAR (6)      CONSTRAINT [DF__tblFaReti__Metho__31190FD5] DEFAULT ('NONE') NOT NULL,
    [AppyBusinessUse] TINYINT          CONSTRAINT [DF__tblFaReti__AppyB__320D340E] DEFAULT (100) NOT NULL,
    [SwitchMethod]    VARCHAR (6)      CONSTRAINT [DF__tblFaReti__Switc__33015847] DEFAULT ('NONE') NOT NULL,
    [BeginYr]         INT              CONSTRAINT [DF__tblFaReti__Begin__33F57C80] DEFAULT (0) NOT NULL,
    [BeginPd]         SMALLINT         CONSTRAINT [DF__tblFaReti__Begin__34E9A0B9] DEFAULT (0) NOT NULL,
    [EndYr]           INT              CONSTRAINT [DF__tblFaReti__EndYr__35DDC4F2] DEFAULT (0) NOT NULL,
    [EndPd]           SMALLINT         CONSTRAINT [DF__tblFaReti__EndPd__36D1E92B] DEFAULT (0) NOT NULL,
    [Life]            [dbo].[pDec]     CONSTRAINT [DF__tblFaRetir__Life__37C60D64] DEFAULT (0) NOT NULL,
    [Recovery]        INT              CONSTRAINT [DF__tblFaReti__Recov__38BA319D] DEFAULT (0) NOT NULL,
    [ActLife]         INT              CONSTRAINT [DF__tblFaReti__ActLi__39AE55D6] DEFAULT (0) NOT NULL,
    [BaseCost]        [dbo].[pDec]     CONSTRAINT [DF__tblFaReti__BaseC__3AA27A0F] DEFAULT (0) NOT NULL,
    [SalvageValue]    [dbo].[pDec]     CONSTRAINT [DF__tblFaReti__Salva__3B969E48] DEFAULT (0) NOT NULL,
    [BonusDepr]       [dbo].[pDec]     CONSTRAINT [DF__tblFaReti__Bonus__3C8AC281] DEFAULT (0) NOT NULL,
    [Expense179]      [dbo].[pDec]     CONSTRAINT [DF__tblFaReti__179Ex__3D7EE6BA] DEFAULT (0) NOT NULL,
    [Credits]         [dbo].[pDec]     CONSTRAINT [DF__tblFaReti__Credi__3E730AF3] DEFAULT (0) NOT NULL,
    [TotDeprTaken]    [dbo].[pDec]     CONSTRAINT [DF__tblFaReti__TotDe__3F672F2C] DEFAULT (0) NOT NULL,
    [TotDeprElig]     [dbo].[pDec]     CONSTRAINT [DF__tblFaReti__TotDe__405B5365] DEFAULT (0) NOT NULL,
    [YTDDepr]         [dbo].[pDec]     CONSTRAINT [DF__tblFaReti__YTDDe__414F779E] DEFAULT (0) NOT NULL,
    [AnnualDepr]      [dbo].[pDec]     CONSTRAINT [DF__tblFaReti__Annua__42439BD7] DEFAULT (0) NOT NULL,
    [Resv1]           [dbo].[pDec]     CONSTRAINT [DF__tblFaReti__Resv1__4337C010] DEFAULT (0) NULL,
    [ts]              ROWVERSION       NULL,
    [CF]              XML              NULL,
    [ID]              INT              NOT NULL,
    CONSTRAINT [PK_tblFaRetireDepr] PRIMARY KEY CLUSTERED ([RetirementID] ASC, [ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblFaRetireDepr_Method]
    ON [dbo].[tblFaRetireDepr]([Method] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblFaRetireDepr_RetirementIDAssetIDDeprcType]
    ON [dbo].[tblFaRetireDepr]([RetirementID] ASC, [AssetID] ASC, [DeprcType] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblFaRetireDepr] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblFaRetireDepr] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblFaRetireDepr] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblFaRetireDepr] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFaRetireDepr';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblFaRetireDepr';

