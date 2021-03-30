CREATE TABLE [dbo].[tblPcProjectDetail] (
    [Id]             INT               IDENTITY (1, 1) NOT NULL,
    [ProjectId]      INT               NOT NULL,
    [PhaseId]        NVARCHAR (10)     NULL,
    [TaskId]         NVARCHAR (10)     NULL,
    [Description]    NVARCHAR (30)     NULL,
    [Status]         TINYINT           CONSTRAINT [DF_tblPcProjectDetail_Status] DEFAULT ((0)) NOT NULL,
    [BillOnHold]     BIT               CONSTRAINT [DF_tblPcProjectDetail_BillOnHold] DEFAULT ((0)) NOT NULL,
    [Speculative]    BIT               CONSTRAINT [DF_tblPcProjectDetail_Speculative] DEFAULT ((0)) NOT NULL,
    [Billable]       BIT               CONSTRAINT [DF_tblPcProjectDetail_Billable] DEFAULT ((1)) NOT NULL,
    [FixedFee]       BIT               CONSTRAINT [DF_tblPcProjectDetail_FixedFee] DEFAULT ((0)) NOT NULL,
    [FixedFeeAmt]    [dbo].[pDec]      CONSTRAINT [DF_tblPcProjectDetail_FixedFeeAmt] DEFAULT ((0)) NOT NULL,
    [EstStartDate]   DATETIME          NULL,
    [EstEndDate]     DATETIME          NULL,
    [ActStartDate]   DATETIME          NULL,
    [ActEndDate]     DATETIME          NULL,
    [DistCode]       NVARCHAR (6)      NOT NULL,
    [OhAllCode]      NVARCHAR (6)      NOT NULL,
    [TaxClass]       TINYINT           CONSTRAINT [DF_tblPcProjectDetail_TaxClass] DEFAULT ((0)) NOT NULL,
    [MaterialMarkup] [dbo].[pDec]      CONSTRAINT [DF_tblPcProjectDetail_MaterialMarkup] DEFAULT ((0)) NOT NULL,
    [ExpenseMarkup]  [dbo].[pDec]      CONSTRAINT [DF_tblPcProjectDetail_ExpenseMarkup] DEFAULT ((0)) NOT NULL,
    [OtherMarkup]    [dbo].[pDec]      CONSTRAINT [DF_tblPcProjectDetail_OtherMarkup] DEFAULT ((0)) NOT NULL,
    [OverrideRate]   [dbo].[pDec]      CONSTRAINT [DF_tblPcProjectDetail_OverrideRate] DEFAULT ((0)) NOT NULL,
    [AddnlDesc]      NVARCHAR (MAX)    NULL,
    [LastDateBilled] DATETIME          NULL,
    [RateId]         NVARCHAR (10)     NULL,
    [ProjectManager] [dbo].[pEmpID]    NULL,
    [Rep1Id]         [dbo].[pSalesRep] NULL,
    [Rep2Id]         [dbo].[pSalesRep] NULL,
    [Rep1Pct]        [dbo].[pDec]      CONSTRAINT [DF_tblPcProjectDetail_Rep1Pct] DEFAULT ((0)) NOT NULL,
    [Rep2Pct]        [dbo].[pDec]      CONSTRAINT [DF_tblPcProjectDetail_Rep2Pct] DEFAULT ((0)) NOT NULL,
    [Rep1CommRate]   [dbo].[pDec]      CONSTRAINT [DF_tblPcProjectDetail_Rep1CommRate] DEFAULT ((0)) NOT NULL,
    [Rep2CommRate]   [dbo].[pDec]      CONSTRAINT [DF_tblPcProjectDetail_Rep2CommRate] DEFAULT ((0)) NOT NULL,
    [CustPONum]      NVARCHAR (25)     NULL,
    [OrderDate]      DATETIME          NULL,
    [CF]             XML               NULL,
    [ts]             ROWVERSION        NULL,
    CONSTRAINT [PK_tblPcProjectDetail] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [uiProjectDetail]
    ON [dbo].[tblPcProjectDetail]([ProjectId] ASC, [TaskId] ASC, [PhaseId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcProjectDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcProjectDetail';

