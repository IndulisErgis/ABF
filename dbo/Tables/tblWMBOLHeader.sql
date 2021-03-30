CREATE TABLE [dbo].[tblWMBOLHeader] (
    [BOLRef]             INT                 IDENTITY (1, 1) NOT NULL,
    [BOLNum]             VARCHAR (17)        NOT NULL,
    [ShipDate]           DATETIME            DEFAULT (getdate()) NULL,
    [ShipFromId]         [dbo].[pLocID]      NULL,
    [ShipFromName]       VARCHAR (35)        NULL,
    [ShipFromAddr1]      VARCHAR (30)        NULL,
    [ShipFromAddr2]      VARCHAR (60)        NULL,
    [ShipFromCity]       VARCHAR (30)        NULL,
    [ShipFromRegion]     VARCHAR (10)        NULL,
    [ShipFromCountry]    [dbo].[pCountry]    NULL,
    [ShipFromPostalCode] VARCHAR (10)        NULL,
    [ShipFromFOBYn]      BIT                 DEFAULT ((0)) NOT NULL,
    [SIDNumber]          [dbo].[pInvoiceNum] NULL,
    [ShipToId]           [dbo].[pCustID]     NULL,
    [ShipToName]         VARCHAR (30)        NULL,
    [ShipToAddr1]        VARCHAR (30)        NULL,
    [ShipToAddr2]        VARCHAR (60)        NULL,
    [ShipToCity]         VARCHAR (30)        NULL,
    [ShipToRegion]       VARCHAR (10)        NULL,
    [ShipToCountry]      [dbo].[pCountry]    NULL,
    [ShipToPostalCode]   VARCHAR (10)        NULL,
    [ShipToFOBYn]        BIT                 DEFAULT ((0)) NOT NULL,
    [ShipToLocNo]        VARCHAR (10)        NULL,
    [CIDNumber]          [dbo].[pInvoiceNum] NULL,
    [BillToId]           [dbo].[pCustID]     NULL,
    [BillToName]         VARCHAR (30)        NULL,
    [BillToAddr1]        VARCHAR (30)        NULL,
    [BillToAddr2]        VARCHAR (60)        NULL,
    [BillToCity]         VARCHAR (30)        NULL,
    [BillToRegion]       VARCHAR (10)        NULL,
    [BillToCountry]      [dbo].[pCountry]    NULL,
    [BillToPostalCode]   VARCHAR (10)        NULL,
    [CarrierName]        VARCHAR (30)        NULL,
    [CarrierSCAC]        VARCHAR (4)         NULL,
    [CarrierPRO]         VARCHAR (20)        NULL,
    [VehicleNumber]      VARCHAR (16)        NULL,
    [SealNumber]         VARCHAR (16)        NULL,
    [CODFeeType]         TINYINT             DEFAULT ((0)) NOT NULL,
    [CODAmount]          [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [FreightFeeType]     TINYINT             DEFAULT ((0)) NOT NULL,
    [EmergencyPhone]     VARCHAR (20)        NULL,
    [EmergencyEXT]       VARCHAR (6)         NULL,
    [DeclaredValue]      [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [DeclaredValueUnit]  VARCHAR (8)         NULL,
    [CustId]             [dbo].[pCustID]     NULL,
    [SpecialInst]        TEXT                NULL,
    [CF]                 XML                 NULL,
    CONSTRAINT [PK_tblWMBOLHeader] PRIMARY KEY CLUSTERED ([BOLRef] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblWMBOLHeader]
    ON [dbo].[tblWMBOLHeader]([BOLNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWMBOLHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWMBOLHeader';

