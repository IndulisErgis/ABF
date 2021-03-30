CREATE TABLE [dbo].[ALP_tblArAlpRepairPlan] (
    [RepPlanId]          INT              IDENTITY (1, 1) NOT NULL,
    [RepPlan]            VARCHAR (15)     NULL,
    [Desc]               VARCHAR (255)    NULL,
    [InactiveYN]         BIT              CONSTRAINT [DF_tblArAlpRepairPlan_InactiveYN] DEFAULT (0) NULL,
    [DfltPlanID]         TINYINT          NULL,
    [DfltWarrTerm]       SMALLINT         NULL,
    [PartsPricingMethod] TINYINT          NULL,
    [SuppCostPct]        NUMERIC (20, 10) NULL,
    [MarkupPct]          NUMERIC (20, 10) NULL,
    [LabCover100YN]      BIT              CONSTRAINT [DF_tblArAlpRepairPlan_LabCover100YN] DEFAULT (0) NULL,
    [RegHrsFrom]         DATETIME         NULL,
    [RegHrsTo]           DATETIME         NULL,
    [RegHrsSatYN]        BIT              CONSTRAINT [DF_tblArAlpRepairPlan_RegHrsSatYN] DEFAULT (0) NULL,
    [RegHrsSunYN]        BIT              CONSTRAINT [DF_tblArAlpRepairPlan_RegHrsSunYN] DEFAULT (0) NULL,
    [RegHrsHolYN]        BIT              CONSTRAINT [DF_tblArAlpRepairPlan_RegHrsHolYN] DEFAULT (0) NULL,
    [HrlyReg]            NUMERIC (20, 10) NULL,
    [HrlyOutOfReg]       NUMERIC (20, 10) NULL,
    [HrlyNonWork]        NUMERIC (20, 10) NULL,
    [HrlyHol]            NUMERIC (20, 10) NULL,
    [MinAmt]             NUMERIC (20, 10) NULL,
    [MinHrs]             NUMERIC (20, 10) NULL,
    [MinAmtOut]          NUMERIC (20, 10) NULL,
    [MinHrsOut]          NUMERIC (20, 10) NULL,
    [MinAmtHol]          NUMERIC (20, 10) NULL,
    [MinHrsHol]          NUMERIC (20, 10) NULL,
    [ts]                 ROWVERSION       NULL,
    CONSTRAINT [PK_tblArAlpRepairPlan] PRIMARY KEY CLUSTERED ([RepPlanId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgArAlpRepairPlanD] ON [dbo].[ALP_tblArAlpRepairPlan] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblArAlpSiteSys */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteSys WHERE (deleted.RepPlanId = ALP_tblArAlpSiteSys.RepPlanId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.RepPlanId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpRepairPlanD', @FldVal, 'ALP_tblArAlpSiteSys.RepPlanId')
    Set @Undo = 1
END
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteSys WHERE (deleted.RepPlanId = ALP_tblArAlpSiteSys.WarrPlanId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.RepPlanId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpRepairPlanD', @FldVal, 'ALP_tblArAlpSiteSys.WarrPlanId')
    Set @Undo = 1
END
/* END tblArAlpSiteSys */
/* BEGIN tblJmSvcTkt */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTkt WHERE (deleted.RepPlanId = ALP_tblJmSvcTkt.RepPlanId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.RepPlanId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpRepairPlanD', @FldVal, 'ALP_tblJmSvcTkt.RepPlanId')
    Set @Undo = 1
END
/* END tblJmSvcTkt */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgArAlpRepairPlanU] ON [dbo].[ALP_tblArAlpRepairPlan] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(RepPlanID))
BEGIN
	/* BEGIN tblArAlpSiteSys */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteSys WHERE (deleted.RepPlanID = ALP_tblArAlpSiteSys.RepPlanId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.RepPlanID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpRepairPlanU', @FldVal, 'ALP_tblArAlpSiteSys.RepPlanId')
		Set @Undo = 1
	END
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteSys WHERE (deleted.RepPlanID = ALP_tblArAlpSiteSys.WarrPlanId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.RepPlanID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpRepairPlanU', @FldVal, 'ALP_tblArAlpSiteSys.WarrPlanId')
		Set @Undo = 1
	END
	/* END tblArAlpSiteSys */
	/* BEGIN tblJmSvcTkt */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTkt WHERE (deleted.RepPlanID = ALP_tblJmSVcTkt.RepPlanId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.RepPlanID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpRepairPlanU', @FldVal, 'ALP_tblJmSvcTkt.RepPlanId')
		Set @Undo = 1
	END
	/* END tblJmSvcTkt */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpRepairPlan] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpRepairPlan] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpRepairPlan] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpRepairPlan] TO PUBLIC
    AS [dbo];

