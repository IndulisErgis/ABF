CREATE TABLE [dbo].[tblWmBOLDetailCustomerOrder] (
    [BOLDtlOrderRef]   INT          IDENTITY (1, 1) NOT NULL,
    [BOLRef]           INT          NOT NULL,
    [Source]           TINYINT      DEFAULT ((0)) NOT NULL,
    [CustomerPoNo]     VARCHAR (25) NULL,
    [PackQty]          [dbo].[pDec] DEFAULT ((0)) NOT NULL,
    [ExtWeight]        [dbo].[pDec] DEFAULT ((0)) NOT NULL,
    [PalletSlipYn]     BIT          DEFAULT ((0)) NOT NULL,
    [AddiShipperInfo]  VARCHAR (60) NULL,
    [CF]               XML          NULL,
    [AddnlShipperInfo] VARCHAR (60) NULL,
    CONSTRAINT [PK_tblWmBOLDetailCustomerOrder] PRIMARY KEY CLUSTERED ([BOLDtlOrderRef] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmBOLDetailCustomerOrder';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmBOLDetailCustomerOrder';

