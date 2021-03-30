CREATE TABLE [dbo].[tblPcActivity] (
    [Id]                    INT                  IDENTITY (1, 1) NOT NULL,
    [ProjectDetailId]       INT                  NOT NULL,
    [RcptId]                INT                  NULL,
    [Source]                TINYINT              NOT NULL,
    [Type]                  TINYINT              NOT NULL,
    [Qty]                   [dbo].[pDec]         CONSTRAINT [DF_tblPcActivity_Qty] DEFAULT ((0)) NOT NULL,
    [QtyInvoiced]           [dbo].[pDec]         CONSTRAINT [DF_tblPcActivity_QtyInvoiced] DEFAULT ((0)) NOT NULL,
    [ExtCost]               [dbo].[pDec]         CONSTRAINT [DF_tblPcActivity_ExtCost] DEFAULT ((0)) NOT NULL,
    [ExtIncome]             [dbo].[pDec]         CONSTRAINT [DF_tblPcActivity_ExtIncome] DEFAULT ((0)) NOT NULL,
    [QtyBilled]             [dbo].[pDec]         CONSTRAINT [DF_tblPcActivity_QtyBilled] DEFAULT ((0)) NOT NULL,
    [ExtIncomeBilled]       [dbo].[pDec]         CONSTRAINT [DF_tblPcActivity_ExtIncomeBilled] DEFAULT ((0)) NOT NULL,
    [Description]           [dbo].[pDescription] NULL,
    [AddnlDesc]             NVARCHAR (MAX)       NULL,
    [ActivityDate]          DATETIME             NOT NULL,
    [SourceReference]       NVARCHAR (MAX)       NULL,
    [BillingReference]      NVARCHAR (MAX)       NULL,
    [ResourceId]            NVARCHAR (24)        NULL,
    [LocId]                 [dbo].[pLocID]       NULL,
    [Reference]             NVARCHAR (24)        NULL,
    [DistCode]              [dbo].[pDistCode]    NULL,
    [GLAcctWIP]             [dbo].[pGlAcct]      NULL,
    [GLAcctPayrollClearing] [dbo].[pGlAcct]      NULL,
    [GLAcctIncome]          [dbo].[pGlAcct]      NULL,
    [GLAcctCost]            [dbo].[pGlAcct]      NULL,
    [GLAcctAdjustments]     [dbo].[pGlAcct]      NULL,
    [GLAcctFixedFeeBilling] [dbo].[pGlAcct]      NULL,
    [GLAcctOverheadContra]  [dbo].[pGlAcct]      NULL,
    [GLAcctAccruedIncome]   [dbo].[pGlAcct]      NULL,
    [GLAcct]                [dbo].[pGlAcct]      NULL,
    [TaxClass]              TINYINT              NULL,
    [FiscalPeriod]          SMALLINT             NOT NULL,
    [FiscalYear]            SMALLINT             NOT NULL,
    [OverheadPosted]        [dbo].[pDec]         CONSTRAINT [DF_tblPcActivity_OverheadPosted] DEFAULT ((0)) NOT NULL,
    [RateId]                NVARCHAR (10)        NULL,
    [Uom]                   [dbo].[pUom]         NULL,
    [Status]                TINYINT              NOT NULL,
    [BillOnHold]            BIT                  CONSTRAINT [DF_tblPcActivity_BillOnHold] DEFAULT ((0)) NOT NULL,
    [SourceId]              UNIQUEIDENTIFIER     NULL,
    [LinkSeqNum]            INT                  NULL,
    [CF]                    XML                  NULL,
    [ts]                    ROWVERSION           NULL,
    [LinkId]                INT                  NULL,
    CONSTRAINT [PK_tblPcActivity] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPcActivity_LinkId]
    ON [dbo].[tblPcActivity]([LinkId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPcActivity_Type]
    ON [dbo].[tblPcActivity]([Type] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlProjectDetailId]
    ON [dbo].[tblPcActivity]([ProjectDetailId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcActivity';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcActivity';

