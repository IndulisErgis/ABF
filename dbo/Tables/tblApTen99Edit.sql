CREATE TABLE [dbo].[tblApTen99Edit] (
    [VendorID]            [dbo].[pVendorID] NOT NULL,
    [AcctNo]              NVARCHAR (10)     NULL,
    [Name]                NVARCHAR (30)     NULL,
    [Addr1]               NVARCHAR (30)     NULL,
    [Addr2]               NVARCHAR (60)     NULL,
    [City]                NVARCHAR (30)     NULL,
    [Region]              NVARCHAR (10)     NULL,
    [PostalCode]          NVARCHAR (10)     NULL,
    [Ten99FormCode]       NVARCHAR (1)      NULL,
    [Ten99RecipientID]    NVARCHAR (16)     NULL,
    [Ten99FieldIndicator] NVARCHAR (1)      NULL,
    [Ten99ForeignAddrYN]  BIT               NULL,
    [SecondTINNotYN]      BIT               NULL,
    [Amount]              [dbo].[pDecimal]  NULL,
    [NameControl]         NVARCHAR (4)      NULL,
    [PayToName]           NVARCHAR (30)     NULL,
    [FATCAFilingYN]       BIT               NULL,
    CONSTRAINT [PK_tblApTen99Edit] PRIMARY KEY CLUSTERED ([VendorID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTen99Edit';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTen99Edit';

