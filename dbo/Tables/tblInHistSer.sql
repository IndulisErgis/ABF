CREATE TABLE [dbo].[tblInHistSer] (
    [SeqNum]     INT                 IDENTITY (1, 1) NOT NULL,
    [HistSeqNum] INT                 NOT NULL,
    [LotNum]     [dbo].[pLotNum]     NULL,
    [SerNum]     [dbo].[pSerNum]     NULL,
    [SumYear]    SMALLINT            CONSTRAINT [DF__tblInHist__SumYe__251658FF] DEFAULT (0) NULL,
    [SumPeriod]  SMALLINT            CONSTRAINT [DF__tblInHist__SumPe__260A7D38] DEFAULT (0) NULL,
    [GLPeriod]   SMALLINT            CONSTRAINT [DF__tblInHist__GLPer__26FEA171] DEFAULT (0) NULL,
    [InvcNum]    [dbo].[pInvoiceNum] NULL,
    [DateOrder]  DATETIME            NULL,
    [DateInvc]   DATETIME            NULL,
    [DateRcpt]   DATETIME            NULL,
    [DateShip]   DATETIME            NULL,
    [CostUnit]   [dbo].[pDec]        CONSTRAINT [DF__tblInHist__CostU__29DB0E1C] DEFAULT (0) NOT NULL,
    [PriceUnit]  [dbo].[pDec]        CONSTRAINT [DF__tblInHist__Price__2ACF3255] DEFAULT (0) NOT NULL,
    [Cmnt]       VARCHAR (35)        NULL,
    [CF]         XML                 NULL,
    CONSTRAINT [PK__tblInHistSer__232E108D] PRIMARY KEY CLUSTERED ([SeqNum] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblInHistSer] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInHistSer] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblInHistSer] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblInHistSer] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInHistSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInHistSer';

