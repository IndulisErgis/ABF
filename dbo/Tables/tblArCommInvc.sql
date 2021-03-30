CREATE TABLE [dbo].[tblArCommInvc] (
    [Counter]       INT                 IDENTITY (1, 1) NOT NULL,
    [SalesRepID]    [dbo].[pSalesRep]   NULL,
    [CustId]        [dbo].[pCustID]     NULL,
    [InvcNum]       [dbo].[pInvoiceNum] NULL,
    [InvcDate]      DATETIME            NULL,
    [PctInvc]       [dbo].[pDec]        CONSTRAINT [DF_tblArCommInvc_PctInvc] DEFAULT (0) NULL,
    [AmtLines]      [dbo].[pDec]        CONSTRAINT [DF_tblArCommInvc_AmtLines] DEFAULT (0) NULL,
    [AmtTax]        [dbo].[pDec]        CONSTRAINT [DF_tblArCommInvc_AmtTax] DEFAULT (0) NULL,
    [AmtFreight]    [dbo].[pDec]        CONSTRAINT [DF_tblArCommInvc_AmtFreight] DEFAULT (0) NULL,
    [AmtMisc]       [dbo].[pDec]        CONSTRAINT [DF_tblArCommInvc_AmtMisc] DEFAULT (0) NULL,
    [AmtPmt]        [dbo].[pDec]        CONSTRAINT [DF_tblArCommInvc_AmtPmt] DEFAULT (0) NULL,
    [AmtCogs]       [dbo].[pDec]        CONSTRAINT [DF_tblArCommInvc_AmtCogs] DEFAULT (0) NULL,
    [AmtAdjust]     [dbo].[pDec]        CONSTRAINT [DF_tblArCommInvc_AmtAdjust] DEFAULT (0) NULL,
    [AmtPrepared]   [dbo].[pDec]        CONSTRAINT [DF_tblArCommInvc_AmtPrepared] DEFAULT (0) NULL,
    [CommPaid]      [dbo].[pDec]        CONSTRAINT [DF_tblArCommInvc_CommPaid] DEFAULT (0) NULL,
    [CompletedDate] DATETIME            NULL,
    [HoldYn]        BIT                 CONSTRAINT [DF__tblArComm__HoldY__550F84E4] DEFAULT (0) NULL,
    [CommRateDtl]   [dbo].[pDec]        CONSTRAINT [DF_tblArCommInvc_CommRateDtl] DEFAULT (0) NULL,
    [PctOfDtl]      TINYINT             CONSTRAINT [DF__tblArComm__PctOf__56F7CD56] DEFAULT (0) NULL,
    [BasedOnDtl]    TINYINT             CONSTRAINT [DF__tblArComm__Based__57EBF18F] DEFAULT (0) NULL,
    [PayLines]      BIT                 CONSTRAINT [DF__tblArComm__PayLi__58E015C8] DEFAULT (1) NULL,
    [PayTax]        BIT                 CONSTRAINT [DF__tblArComm__PayTa__59D43A01] DEFAULT (0) NULL,
    [PayFreight]    BIT                 CONSTRAINT [DF__tblArComm__PayFr__5AC85E3A] DEFAULT (0) NULL,
    [PayMisc]       BIT                 CONSTRAINT [DF__tblArComm__PayMi__5BBC8273] DEFAULT (0) NULL,
    [ts]            ROWVERSION          NULL,
    [AmtInvc]       [dbo].[pDec]        DEFAULT ((0)) NULL,
    [CF]            XML                 NULL,
    CONSTRAINT [PK__tblArCommInvc__4A91F671] PRIMARY KEY CLUSTERED ([Counter] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlSalesRepID]
    ON [dbo].[tblArCommInvc]([SalesRepID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlInvcNum]
    ON [dbo].[tblArCommInvc]([InvcNum] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlCustId]
    ON [dbo].[tblArCommInvc]([CustId] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArCommInvc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArCommInvc';

