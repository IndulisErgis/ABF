CREATE TABLE [dbo].[ALP_tblJmOption] (
    [OptionKey]                   TINYINT        CONSTRAINT [DF_tblJmOption_OptionKey] DEFAULT (1) NOT NULL,
    [GlYn]                        BIT            CONSTRAINT [DF_tblJmOption_GlYn] DEFAULT (0) NULL,
    [ArYn]                        BIT            CONSTRAINT [DF_tblJmOption_ArYn] DEFAULT (0) NULL,
    [InYn]                        BIT            CONSTRAINT [DF_tblJmOption_InYn] DEFAULT (0) NULL,
    [ProductKey]                  NVARCHAR (8)   NULL,
    [ImYn]                        BIT            CONSTRAINT [DF_tblJmOption_ImYn] DEFAULT (0) NULL,
    [SchedYn]                     BIT            CONSTRAINT [DF_tblJmOption_SchedYn] DEFAULT (0) NULL,
    [EditPricePartsYN]            BIT            CONSTRAINT [DF_tblJmOption_EditPricePartsYN] DEFAULT (0) NULL,
    [EditPriceOtherYN]            BIT            CONSTRAINT [DF_tblJmOption_EditPriceOtherYN] DEFAULT (0) NULL,
    [EditCostPartsYN]             BIT            CONSTRAINT [DF_tblJmOption_EditCostPartsYN] DEFAULT (0) NULL,
    [EditCostOtherYN]             BIT            CONSTRAINT [DF_tblJmOption_EditCostOtherYN] DEFAULT (0) NULL,
    [PrintCompInfoYN]             BIT            CONSTRAINT [DF_tblJmOption_PrintCompInfoYN] DEFAULT (0) NULL,
    [PlainPaperInstTktsYN]        BIT            CONSTRAINT [DF_tblJmOption_PlainPaperInstTktsYN] DEFAULT (0) NULL,
    [PlainPaperServTktsYN]        BIT            CONSTRAINT [DF_tblJmOption_PlainPaperServTktsYN] DEFAULT (0) NULL,
    [OnlineInvcYn]                BIT            CONSTRAINT [DF_tblJmOption_OnlineInvcYn] DEFAULT (0) NULL,
    [ProjJobInvcCommentYn]        BIT            CONSTRAINT [DF_tblJmOption_ProjJobInvcCommentYn] DEFAULT (0) NULL,
    [DfltDeptServ]                INT            NULL,
    [DfltDeptInst]                INT            NULL,
    [DfltWorkCodeServ]            INT            NULL,
    [DfltWorkCodeInst]            INT            NULL,
    [DfltBatchCodeServ]           VARCHAR (6)    NULL,
    [DfltBatchCodeInst]           VARCHAR (6)    NULL,
    [DfltItemIdParts]             VARCHAR (50)   NULL,
    [DfltItemIdLabor]             VARCHAR (50)   NULL,
    [DfltItemIdComment]           VARCHAR (50)   NULL,
    [PwordMaster]                 VARCHAR (8)    NULL,
    [PwordEditPrice]              VARCHAR (50)   NULL,
    [PwordDelBill]                VARCHAR (8)    NULL,
    [PwordCompTkt]                VARCHAR (8)    NULL,
    [PwordDeleteTkt]              VARCHAR (8)    NULL,
    [PwordOverride]               VARCHAR (8)    NULL,
    [DfltCosOffsetPartsOh]        VARCHAR (40)   NULL,
    [LockTimeBarsDate]            DATETIME       NULL,
    [PworkLabMarkupPct]           FLOAT (53)     NULL,
    [DfltRecJobProcDate]          DATETIME       NULL,
    [DfltRecJobCycleId]           INT            NULL,
    [ValidateBillingYN]           BIT            CONSTRAINT [DF_tblJmOption_ValidateBillingYN] DEFAULT (0) NULL,
    [GlAcctWIP]                   VARCHAR (40)   NULL,
    [CosOffsetParts]              VARCHAR (40)   NULL,
    [CosOffsetOtherItems]         VARCHAR (40)   NULL,
    [CosOffsetPartsOh]            VARCHAR (40)   NULL,
    [RmrExpense]                  [dbo].[pDec]   NULL,
    [DiscRatePct]                 FLOAT (53)     NULL,
    [CommPaidThruDate]            DATETIME       NULL,
    [JmWDBUtilitiesYN]            BIT            CONSTRAINT [DF_tblJmOption_JmWDBUtilitiesYN] DEFAULT (0) NULL,
    [ItemIdInJobInvcCommentYn]    BIT            CONSTRAINT [DF_tblJmOption_ItemIdInJobInvcCommentYn_1] DEFAULT (0) NULL,
    [ts]                          ROWVERSION     NULL,
    [JmEnhancedInvoicingYN]       BIT            NULL,
    [DfltItemIdPartsInst]         VARCHAR (50)   NULL,
    [DfltItemIdLaborInst]         VARCHAR (50)   NULL,
    [UseItemGLInBillingYn]        BIT            CONSTRAINT [DF_ALP_tblJmOption_UseItemGLInBillingYn] DEFAULT ((0)) NULL,
    [AlpEncrypt]                  SMALLINT       CONSTRAINT [DF_ALP_tblJmOption_AlpEncrypt] DEFAULT ((0)) NULL,
    [JMLockJobsWhenCompletedYN]   BIT            CONSTRAINT [DF_ALP_tblJmOption_JMLockJobsWhenCompletedYN] DEFAULT ((0)) NULL,
    [UseDerivedItemGLInBillingYN] BIT            NULL,
    [JMImportYN]                  BIT            CONSTRAINT [DF_ALP_tblJmOption_JMImportYN] DEFAULT ((0)) NULL,
    [AuditTicketsYN]              BIT            NULL,
    [AuditSitesYN]                BIT            NULL,
    [QM_DfltLocId]                [dbo].[pLocID] NULL,
    CONSTRAINT [PK_tblJmOption] PRIMARY KEY CLUSTERED ([OptionKey] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmOption] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmOption] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmOption] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmOption] TO PUBLIC
    AS [dbo];

