CREATE TABLE [dbo].[tblApVendorHistDetail] (
    [VendorID]     [dbo].[pVendorID] NOT NULL,
    [FiscalYear]   SMALLINT          CONSTRAINT [DF__tblApVend__Fisca__07D00EDB] DEFAULT (0) NOT NULL,
    [GLPeriod]     SMALLINT          CONSTRAINT [DF__tblApVend__GLPer__08C43314] DEFAULT (0) NOT NULL,
    [Purch]        [dbo].[pDec]      CONSTRAINT [DF__tblApVend__Purch__09B8574D] DEFAULT (0) NULL,
    [Pmt]          [dbo].[pDec]      CONSTRAINT [DF__tblApVendor__Pmt__0AAC7B86] DEFAULT (0) NULL,
    [DiscTaken]    [dbo].[pDec]      CONSTRAINT [DF__tblApVend__DiscT__0BA09FBF] DEFAULT (0) NULL,
    [DiscLost]     [dbo].[pDec]      CONSTRAINT [DF__tblApVend__DiscL__0C94C3F8] DEFAULT (0) NULL,
    [Ten99Pmt]     [dbo].[pDec]      CONSTRAINT [DF__tblApVend__Ten99__0D88E831] DEFAULT (0) NULL,
    [PurchFgn]     [dbo].[pDec]      CONSTRAINT [DF__tblApVend__Purch__0E7D0C6A] DEFAULT (0) NULL,
    [PmtFgn]       [dbo].[pDec]      CONSTRAINT [DF__tblApVend__PmtFg__0F7130A3] DEFAULT (0) NULL,
    [DiscTakenFgn] [dbo].[pDec]      CONSTRAINT [DF__tblApVend__DiscT__106554DC] DEFAULT (0) NULL,
    [DiscLostFgn]  [dbo].[pDec]      CONSTRAINT [DF__tblApVend__DiscL__11597915] DEFAULT (0) NULL,
    [Ten99PmtFgn]  [dbo].[pDec]      CONSTRAINT [DF__tblApVend__Ten99__124D9D4E] DEFAULT (0) NULL,
    [ts]           ROWVERSION        NULL,
    [CF]           XML               NULL,
    CONSTRAINT [PK__tblApVendorHistD__1D4655FB] PRIMARY KEY CLUSTERED ([VendorID] ASC, [FiscalYear] ASC, [GLPeriod] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApVendorHistDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApVendorHistDetail';

