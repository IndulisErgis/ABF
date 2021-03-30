CREATE TABLE [dbo].[tblSmBankAcct] (
    [BankId]                [dbo].[pBankID]   NOT NULL,
    [Desc]                  VARCHAR (35)      NULL,
    [Name]                  VARCHAR (40)      NULL,
    [Contact]               VARCHAR (30)      NULL,
    [Addr1]                 VARCHAR (30)      NULL,
    [Addr2]                 VARCHAR (60)      NULL,
    [City]                  VARCHAR (30)      NULL,
    [Region]                VARCHAR (10)      NULL,
    [Country]               [dbo].[pCountry]  NULL,
    [PostalCode]            VARCHAR (10)      NULL,
    [IntlPrefix]            VARCHAR (6)       NULL,
    [Phone]                 VARCHAR (15)      NULL,
    [FAX]                   VARCHAR (15)      NULL,
    [OurAcctNum]            [dbo].[pGlAcct]   NULL,
    [CurrencyId]            [dbo].[pCurrency] NOT NULL,
    [GlCashAcct]            [dbo].[pGlAcct]   NULL,
    [Email]                 [dbo].[pEmail]    NULL,
    [Internet]              [dbo].[pWeb]      NULL,
    [ts]                    ROWVERSION        NULL,
    [AcctType]              TINYINT           DEFAULT ((0)) NOT NULL,
    [APPosPay]              VARCHAR (24)      NULL,
    [CcExpire]              DATETIME          NULL,
    [CheckFormat]           TINYINT           DEFAULT ((0)) NOT NULL,
    [CheckLayout]           TINYINT           DEFAULT ((0)) NOT NULL,
    [GLAcctBal]             [dbo].[pDec]      DEFAULT ((0)) NOT NULL,
    [LastStmtBal]           [dbo].[pDec]      DEFAULT ((0)) NOT NULL,
    [LastStmtDate]          DATETIME          NULL,
    [MICR]                  BIT               DEFAULT ((0)) NOT NULL,
    [NextCheckNo]           [dbo].[pCheckNum] NULL,
    [PAPosPay]              VARCHAR (24)      NULL,
    [ReconsImpId]           [dbo].[pItemID]   NULL,
    [RoutingCode]           VARCHAR (9)       NULL,
    [VendorId]              [dbo].[pVendorID] NULL,
    [RoutingFraction]       VARCHAR (13)      NULL,
    [NextVoucherNo]         [dbo].[pCheckNum] NULL,
    [FilingCode]            VARCHAR (1)       NULL,
    [FRBRoutingCode]        VARCHAR (9)       NULL,
    [SecurityCode]          VARCHAR (94)      NULL,
    [SecurityCodePadLength] TINYINT           NULL,
    [ACHExcludeOffset]      BIT               NULL,
    [ACHNextBatchNumber]    INT               NULL,
    [ACHLastPayDate]        DATETIME          NULL,
    [ACHFilePath]           VARCHAR (255)     NULL,
    [ACHFileName]           VARCHAR (255)     NULL,
    [ACHExecute]            VARCHAR (255)     NULL,
    [CF]                    XML               NULL,
    [APFileFormat]          NVARCHAR (10)     NULL,
    [PAFileFormat]          NVARCHAR (10)     NULL,
    [ARFileFormat]          NVARCHAR (10)     NULL,
    CONSTRAINT [PK__tblSmBankAcct__0F824689] PRIMARY KEY CLUSTERED ([BankId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmBankAcct';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmBankAcct';

