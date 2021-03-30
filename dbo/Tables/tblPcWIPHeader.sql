CREATE TABLE [dbo].[tblPcWIPHeader] (
    [Id]                       INT              IDENTITY (1, 1) NOT NULL,
    [BatchId]                  [dbo].[pBatchID] NOT NULL,
    [ProjectDetailId]          INT              NOT NULL,
    [FixedFeeAmtAvail]         [dbo].[pDec]     CONSTRAINT [DF_tblPcWIPHeader_FixedFeeAmtAvail] DEFAULT ((0)) NOT NULL,
    [FixedFeeAmtApply]         [dbo].[pDec]     CONSTRAINT [DF_tblPcWIPHeader_FixedFeeAmtApply] DEFAULT ((0)) NOT NULL,
    [DepositAmt]               [dbo].[pDec]     CONSTRAINT [DF_tblPcWIPHeader_DepositAmt] DEFAULT ((0)) NOT NULL,
    [DepositAmtAvail]          [dbo].[pDec]     CONSTRAINT [DF_tblPcWIPHeader_DepositAmtAvail] DEFAULT ((0)) NOT NULL,
    [DepositAmtApply]          [dbo].[pDec]     CONSTRAINT [DF_tblPcWIPHeader_DepositAmtApply] DEFAULT ((0)) NOT NULL,
    [CF]                       XML              NULL,
    [ts]                       ROWVERSION       NULL,
    [CustId]                   [dbo].[pCustID]  NULL,
    [ProjectName]              NVARCHAR (10)    NULL,
    [PhaseId]                  NVARCHAR (10)    NULL,
    [TaskId]                   NVARCHAR (10)    NULL,
    [FixedFee]                 BIT              CONSTRAINT [DF_tblPcWIPHeader_FixedFee] DEFAULT ((0)) NOT NULL,
    [FixedFeeAmt]              [dbo].[pDec]     CONSTRAINT [DF_tblPcWIPHeader_FixedFeeAmt] DEFAULT ((0)) NOT NULL,
    [ProjectDetailDescription] NVARCHAR (30)    NULL,
    [SiteID]                   [dbo].[pLocID]   NULL,
    CONSTRAINT [PK_tblPcWIPHeader] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlProjectDetailId]
    ON [dbo].[tblPcWIPHeader]([ProjectDetailId] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlBatchId]
    ON [dbo].[tblPcWIPHeader]([BatchId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcWIPHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcWIPHeader';

