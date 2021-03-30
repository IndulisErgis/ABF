CREATE TABLE [dbo].[ALP_tblArAlpCycle] (
    [CycleId]     INT              IDENTITY (1, 1) NOT NULL,
    [Cycle]       VARCHAR (10)     NULL,
    [Desc]        VARCHAR (255)    NULL,
    [UOM]         TINYINT          NULL,
    [Units]       NUMERIC (20, 10) NULL,
    [PermanentYN] BIT              CONSTRAINT [DF_tblArAlpCycle_PermanentYN] DEFAULT (0) NULL,
    [InactiveYN]  BIT              CONSTRAINT [DF_tblArAlpCycle_InactiveYN] DEFAULT (0) NULL,
    [ts]          ROWVERSION       NULL,
    CONSTRAINT [PK_tblArAlpCycle] PRIMARY KEY CLUSTERED ([CycleId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgArAlpCycleU] ON [dbo].[ALP_tblArAlpCycle] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(CycleId))
BEGIN
	/* BEGIN tblArAlpContractForm */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpContractForm WHERE (deleted.CycleId = ALP_tblArAlpContractForm.CycleId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.CycleId As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpCycleU', @FldVal, 'ALP_tblArAlpContractForm.CycleId')
		Set @Undo = 1
	END
	/* END tblArAlpContractForm */
	
	/* BEGIN tblArAlpCustContract */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpCustContract WHERE (deleted.CycleId = ALP_tblArAlpCustContract.DfltBillCycleId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.CycleId As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpCycleU', @FldVal, 'ALP_tblArAlpCustContract.DfltBillCycleId')
		Set @Undo = 1
	END
	/* END tblArAlpCustContract */
	/* BEGIN tblArAlpSiteRecBill */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteRecBill WHERE (deleted.CycleId = ALP_tblArAlpSiteRecBill.BillCycleId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.CycleId As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpCycleU', @FldVal, 'ALP_tblArAlpSiteRecBill.BillCycleId')
		Set @Undo = 1
	END
	/* END tblArAlpSiteRecBill */
	/* BEGIN tblArAlpSiteRecBillServ */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteRecBillServ WHERE (deleted.CycleId = ALP_tblArAlpSiteRecBillServ.ActiveCycleId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.CycleId As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpCycleU', @FldVal, 'ALP_tblArAlpSiteRecBillServ.ActiveCycleId')
		Set @Undo = 1
	END
	/* END tblArAlpSiteRecBillServ */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgArAlpCycleD] ON [dbo].[ALP_tblArAlpCycle] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblArAlpContractForm */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpContractForm WHERE (deleted.CycleId = ALP_tblArAlpContractForm.CycleId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.CycleId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpCycleD', @FldVal, 'ALP_tblArAlpContractForm.CycleID')
    Set @Undo = 1
END
/* END tblArAlpContractForm */
/* BEGIN tblArAlpCustContract */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpCustContract WHERE (deleted.CycleId = ALP_tblArAlpCustContract.DfltBillCycleId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.CycleId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpCycleD', @FldVal, 'ALP_tblArAlpCustContract.DfltBillCycleID')
    Set @Undo = 1
END
/* END tblArAlpCustContract */
/* BEGIN tblArAlpSiteRecBill */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteRecBill WHERE (deleted.CycleId = ALP_tblArAlpSiteRecBill.BillCycleId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.CycleId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpCycleD', @FldVal, 'ALP_tblArAlpSiteRecBill.BillCycleID')
    Set @Undo = 1
END
/* END tblArAlpSiteRecBill */
/* BEGIN tblArAlpSiteRecBillServ */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteRecBillServ WHERE (deleted.CycleId = ALP_tblArAlpSiteRecBillServ.ActiveCycleId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.CycleId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpCycleD', @FldVal, 'ALP_tblArAlpSiteRecBillServ.ActiveCycleID')
    Set @Undo = 1
END
/* END tblArAlpSiteRecBillServ */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpCycle] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpCycle] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpCycle] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpCycle] TO PUBLIC
    AS [dbo];

