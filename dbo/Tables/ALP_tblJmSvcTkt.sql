CREATE TABLE [dbo].[ALP_tblJmSvcTkt] (
    [TicketId]             INT              IDENTITY (1, 1) NOT NULL,
    [CreateDate]           DATETIME         NULL,
    [SiteId]               INT              NOT NULL,
    [Status]               VARCHAR (10)     NULL,
    [CreditOverrideDate]   DATETIME         NULL,
    [CreditOverrideBy]     VARCHAR (20)     NULL,
    [Contact]              VARCHAR (60)     NULL,
    [ContactPhone]         VARCHAR (15)     NULL,
    [WorkDesc]             TEXT             NULL,
    [WorkCodeId]           INT              NULL,
    [SysId]                INT              NULL,
    [CustId]               VARCHAR (10)     NULL,
    [CustPoNum]            VARCHAR (25)     NULL,
    [RepPlanId]            INT              NULL,
    [PriceId]              VARCHAR (15)     NULL,
    [BranchId]             INT              NULL,
    [DivId]                INT              NULL,
    [DeptId]               INT              NULL,
    [SkillId]              INT              NULL,
    [LeadTechId]           INT              NULL,
    [EstHrs]               FLOAT (53)       NULL,
    [PrefDate]             DATETIME         NULL,
    [PrefTime]             VARCHAR (50)     NULL,
    [OtherComments]        TEXT             NULL,
    [ShowDetailYn]         BIT              CONSTRAINT [DF_tblJmSvcTkt_ShowDetailYn] DEFAULT (0) NULL,
    [CloseDate]            DATETIME         NULL,
    [BilledYN]             BIT              CONSTRAINT [DF_tblJmSvcTkt_BilledYN] DEFAULT (0) NULL,
    [OutOfRegYN]           BIT              CONSTRAINT [DF_tblJmSvcTkt_OutOfRegYN] DEFAULT (0) NULL,
    [HolidayYN]            BIT              CONSTRAINT [DF_tblJmSvcTkt_HolidayYN] DEFAULT (0) NULL,
    [SalesRepId]           VARCHAR (3)      NULL,
    [RevisedBy]            VARCHAR (50)     NULL,
    [RevisedDate]          DATETIME         NULL,
    [ProjectId]            VARCHAR (10)     NULL,
    [ContractId]           INT              NULL,
    [CsConnectYn]          BIT              CONSTRAINT [DF_tblJmSvcTkt_CsConnectYn] DEFAULT (0) NULL,
    [LseYn]                BIT              CONSTRAINT [DF_tblJmSvcTkt_LseYn] DEFAULT (0) NULL,
    [CompleteDate]         DATETIME         NULL,
    [TurnoverDate]         DATETIME         NULL,
    [StartRecurDate]       DATETIME         NULL,
    [NextRecurDate]        DATETIME         NULL,
    [CommPaidDate]         DATETIME         NULL,
    [RmrExpense]           [dbo].[pDec]     CONSTRAINT [DF_tblJmSvcTkt_RmrExpense] DEFAULT (0) NULL,
    [DiscRatePct]          FLOAT (53)       NULL,
    [ContractMths]         SMALLINT         NULL,
    [CancelDate]           DATETIME         NULL,
    [BoDate]               DATETIME         NULL,
    [StagedDate]           DATETIME         NULL,
    [BinNumber]            VARCHAR (10)     NULL,
    [ToSchDate]            DATETIME         NULL,
    [CreateBy]             VARCHAR (50)     NULL,
    [SalesTax]             [dbo].[pDec]     CONSTRAINT [DF_tblJmSvcTkt_SalesTax] DEFAULT (0) NULL,
    [CommAmt]              [dbo].[pDec]     CONSTRAINT [DF_tblJmSvcTkt_CommAmt] DEFAULT (0) NULL,
    [RMRAdded]             [dbo].[pDec]     CONSTRAINT [DF_tblJmSvcTkt_RMRAdded] DEFAULT (0) NULL,
    [PworkLabMarkupPct]    FLOAT (53)       NULL,
    [BaseInstPrice]        [dbo].[pDec]     CONSTRAINT [DF_tblJmSvcTkt_BaseInstPrice] DEFAULT (0) NULL,
    [OrderDate]            DATETIME         NULL,
    [ReschDate]            DATETIME         NULL,
    [PriceMethod]          TINYINT          NULL,
    [PartsPrice]           [dbo].[pDec]     CONSTRAINT [DF_tblJmSvcTkt_PartsPrice] DEFAULT (0) NULL,
    [PartsOhPct]           NUMERIC (20, 10) NULL,
    [MarkupPct]            NUMERIC (20, 10) NULL,
    [MarkupAmt]            [dbo].[pDec]     CONSTRAINT [DF_tblJmSvcTkt_MarkupAmt] DEFAULT (0) NULL,
    [MinHrs]               FLOAT (53)       CONSTRAINT [DF_ALP_tblJmSvcTkt_MinHrs] DEFAULT ((0)) NULL,
    [MinPrice]             [dbo].[pDec]     CONSTRAINT [DF_ALP_tblJmSvcTkt_MinPrice] DEFAULT ((0)) NULL,
    [RegHrs]               FLOAT (53)       CONSTRAINT [DF_ALP_tblJmSvcTkt_RegHrs] DEFAULT ((0)) NULL,
    [OutOfRegHrs]          FLOAT (53)       CONSTRAINT [DF_ALP_tblJmSvcTkt_OutOfRegHrs] DEFAULT ((0)) NULL,
    [HolHrs]               FLOAT (53)       CONSTRAINT [DF_ALP_tblJmSvcTkt_HolHrs] DEFAULT ((0)) NULL,
    [HrlyReg]              [dbo].[pDec]     CONSTRAINT [DF_tblJmSvcTkt_HrlyReg] DEFAULT (0) NULL,
    [HrlyOutOfReg]         [dbo].[pDec]     CONSTRAINT [DF_tblJmSvcTkt_HrlyOutOfReg] DEFAULT (0) NULL,
    [HrlyHol]              [dbo].[pDec]     CONSTRAINT [DF_tblJmSvcTkt_HrlyHol] DEFAULT (0) NULL,
    [LabPriceTotal]        [dbo].[pDec]     CONSTRAINT [DF_tblJmSvcTkt_LabPriceTotal] DEFAULT (0) NULL,
    [TotalPts]             [dbo].[pDec]     CONSTRAINT [DF_tblJmSvcTkt_TotalPts] DEFAULT (0) NULL,
    [BatchId]              VARCHAR (6)      NULL,
    [BillingFormat]        SMALLINT         NULL,
    [InvcDate]             DATETIME         NULL,
    [InvcNum]              VARCHAR (15)     NULL,
    [CommentAddlDesc]      TEXT             NULL,
    [PartsItemId]          VARCHAR (24)     NULL,
    [PartsDesc]            VARCHAR (35)     NULL,
    [PartsAddlDesc]        TEXT             NULL,
    [PartsTaxClass]        TINYINT          NULL,
    [LaborItemId]          VARCHAR (24)     NULL,
    [LaborDesc]            VARCHAR (35)     NULL,
    [LaborAddlDesc]        TEXT             NULL,
    [LaborTaxClass]        TINYINT          NULL,
    [TaxAmtTotal]          FLOAT (53)       NULL,
    [MailSiteYn]           BIT              CONSTRAINT [DF_tblJmSvcTkt_MailSiteYn] DEFAULT (0) NULL,
    [SendToPrintYn]        BIT              CONSTRAINT [DF_tblJmSvcTkt_SendToPrintYn] DEFAULT (0) NULL,
    [EstCostParts]         [dbo].[pDec]     CONSTRAINT [DF_tblJmSvcTkt_EstCostParts] DEFAULT (0) NULL,
    [EstCostLabor]         [dbo].[pDec]     CONSTRAINT [DF_tblJmSvcTkt_EstCostLabor] DEFAULT (0) NULL,
    [EstCostMisc]          [dbo].[pDec]     CONSTRAINT [DF_tblJmSvcTkt_EstCostMisc] DEFAULT (0) NULL,
    [EstHrs_FromQM]        DECIMAL (18, 2)  CONSTRAINT [DF_tblJmSvcTkt_EstHrs_FromQM_1] DEFAULT (0) NULL,
    [CommSplitYn]          BIT              CONSTRAINT [DF_tblJmSvcTkt_CommSplitYn] DEFAULT (0) NULL,
    [CommPayNowYn]         BIT              CONSTRAINT [DF_tblJmSvcTkt_CommPayNowYn] DEFAULT (0) NULL,
    [ResolId]              INT              NULL,
    [ResolComments]        TEXT             NULL,
    [CauseId]              INT              NULL,
    [CauseComments]        TEXT             NULL,
    [ReturnYN]             BIT              CONSTRAINT [DF_tblJmSvcTkt_ReturnYN] DEFAULT (0) NULL,
    [ts]                   ROWVERSION       NULL,
    [ModifiedBy]           VARCHAR (50)     NULL,
    [ModifiedDate]         DATETIME         NULL,
    [PhoneExt]             VARCHAR (10)     NULL,
    [NextInspectDate]      DATETIME         NULL,
    [RecJobEntryId]        INT              NULL,
    [RecSvcId]             INT              NULL,
    [OriginalEstimatesflg] BIT              NULL,
    [HoldInvCommitted]     BIT              DEFAULT ((0)) NOT NULL,
    [CompletedBy]          VARCHAR (50)     NULL,
    [CompletedOn]          DATETIME         NULL,
    [InvoicedBy]           VARCHAR (50)     NULL,
    CONSTRAINT [PK_tblJmSvcTkt] PRIMARY KEY CLUSTERED ([TicketId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblJmSvcTkt_ProjectID]
    ON [dbo].[ALP_tblJmSvcTkt]([ProjectId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_tblJmSvcTkt]
    ON [dbo].[ALP_tblJmSvcTkt]([Status] ASC) WITH (FILLFACTOR = 80);


GO
CREATE TRIGGER [dbo].[trgJmSvcTktD] ON [dbo].[ALP_tblJmSvcTkt] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmSvcTktItem */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTktItem WHERE (deleted.TicketId = ALP_tblJmSvcTktItem.TicketId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.TicketId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgJmSvcTktD', @FldVal, 'ALP_tblJmSvcTktItem.TicketId')
    Set @Undo = 1
END
/* END tblJmSvcTktItem */
/* BEGIN tblJmTimeCard */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmTimecard WHERE (deleted.TicketId = ALP_tblJmTimecard.TicketId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.TicketId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgJmSvcTkt', @FldVal, 'ALP_tblJmTimecard.TicketId')
    Set @Undo = 1
END
/* END tblJmTimecard */
If @Undo = 0
Begin
	
	/* BEGIN tblJmSvcTktItem */
	DELETE ALP_tblJmSvcTktItem FROM deleted, ALP_tblJmSvcTktItem
	WHERE deleted.TicketId = ALP_tblJmSvcTktItem.TicketId
	/* END tblJmSvcTktItem */
	/* BEGIN tblJmSvcTktPmt */
	DELETE ALP_tblJmSvcTktPmt FROM deleted, ALP_tblJmSvcTktPmt
	WHERE deleted.TicketId = ALP_tblJmSvcTktPmt.TicketId
	/* END tblJmSvcTktPmt */
End
Else
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgJmSvcTktU] ON [dbo].[ALP_tblJmSvcTkt] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmWorkCode */
IF (UPDATE(WorkCodeId))
BEGIN
    IF (SELECT COUNT(*) FROM inserted WHERE ((inserted.WorkCodeId Is Not Null))) != (SELECT COUNT(*) FROM ALP_tblJmWorkCode, inserted WHERE (ALP_tblJmWorkCode.WorkCodeID = inserted.WorkCodeId))
    BEGIN
        Select @FldVal = Cast(inserted.WorkCodeID As Varchar) from inserted
        RAISERROR (90021, 16, 1, 'trgJmSvcTktU', @FldVal, 'ALP_tblJmWorkCode.WorkCodeID')
        Set @Undo = 1
    END
END
/* END tblJmWorkCode */
--/* BEGIN tblJmPricePlanGenHeader */
--IF (UPDATE(PriceId))
--BEGIN
--    IF (SELECT COUNT(*) FROM inserted WHERE ((inserted.PriceId Is Not Null))) != (SELECT COUNT(*) FROM ALP_tblJmPricePlanGenHeader, inserted WHERE (ALP_tblJmPricePlanGenHeader.PriceId = inserted.PriceId))
--    BEGIN
--        Select @FldVal = Cast(inserted.PriceId As Varchar) from inserted
--        RAISERROR (90021, 16, 1, 'trgJmSvcTktU', @FldVal, 'ALP_tblJmPricePlanGenHeader.PriceId')
--        Set @Undo = 1
--    END
--END
--/* END tblJmPricePlanGenHeader */
/* BEGIN tblJmSkill */
IF (UPDATE(SkillId))
BEGIN
    IF (SELECT COUNT(*) FROM inserted WHERE ((inserted.SkillId Is Not Null))) != (SELECT COUNT(*) FROM ALP_tblJmSkill, inserted WHERE (ALP_tblJmSkill.SkillId = inserted.SkillId))
    BEGIN
        Select @FldVal = Cast(inserted.SkillId As Varchar) from inserted
        RAISERROR (90021, 16, 1, 'trgJmSvcTktU', @FldVal, 'ALP_tblJmSkill.SkillID')
        Set @Undo = 1
    END
END
/* END tblJmSkill */
/* BEGIN tblJmTech */
IF (UPDATE(LeadTechId))
BEGIN
    IF (SELECT COUNT(*) FROM inserted WHERE ((inserted.LeadTechId Is Not Null))) != (SELECT COUNT(*) FROM ALP_tblJmTech, inserted WHERE (ALP_tblJmTech.TechId = inserted.LeadTechId))
    BEGIN
        Select @FldVal = Cast(inserted.LeadTechId As Varchar) from inserted
        RAISERROR (90021, 16, 1, 'trgJmSvcTktU', @FldVal, 'ALP_tblJmTech.TechId')
        Set @Undo = 1
    END
END
/* END tblJmTech */
If @Undo = 1
Begin
	Rollback Transaction
End