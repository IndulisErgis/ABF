CREATE TABLE [dbo].[ALP_tblArAlpCustContract] (
    [ContractId]      INT              IDENTITY (1, 1) NOT NULL,
    [CustId]          VARCHAR (10)     NULL,
    [ContractNum]     VARCHAR (255)    NULL,
    [Ref]             VARCHAR (255)    NULL,
    [ContractFormId]  INT              NULL,
    [ContractDate]    DATETIME         NULL,
    [DfltWarrPlanId]  INT              NULL,
    [DfltWarrTerm]    SMALLINT         NULL,
    [DfltRepPlanId]   INT              NULL,
    [LeaseYN]         BIT              CONSTRAINT [DF_tblArAlpCustContract_LeaseYN] DEFAULT (0) NULL,
    [DfltBillCycleID] INT              NULL,
    [DfltBillTerm]    SMALLINT         NULL,
    [DfltBillRenTerm] SMALLINT         NULL,
    [DfltBillAutoRen] BIT              CONSTRAINT [DF_tblArAlpCustContract_DfltBillAutoRen] DEFAULT (0) NULL,
    [ContractValue]   NUMERIC (20, 10) CONSTRAINT [DF_tblArAlpCustContract_ContractValue] DEFAULT (0) NOT NULL,
    [SignedYN]        BIT              CONSTRAINT [DF_tblArAlpCustContract_SignedYN] DEFAULT (0) NULL,
    [AlteredYN]       BIT              CONSTRAINT [DF_tblArAlpCustContract_AlteredYN] DEFAULT (0) NULL,
    [Comments]        TEXT             NULL,
    [FinSourceID]     INT              NULL,
    [FinanceDate]     DATETIME         NULL,
    [FinanceEnds]     DATETIME         NULL,
    [CreateDate]      DATETIME         NULL,
    [LastUpdateDate]  DATETIME         NULL,
    [UploadDate]      DATETIME         NULL,
    [ts]              ROWVERSION       NULL,
    CONSTRAINT [PK_tblArAlpCustContract] PRIMARY KEY CLUSTERED ([ContractId] ASC) WITH (FILLFACTOR = 80)
);


GO

CREATE TRIGGER [dbo].[trgArAlpCustContractD] ON [dbo].[ALP_tblArAlpCustContract] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblArAlpSiteRecBill */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteRecBill WHERE (deleted.ContractId = ALP_tblArAlpSiteRecBill.ContractId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.ContractId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpCustContractD', @FldVal, 'ALP_tblArAlpSiteRecBill.ContractId')
    Set @Undo = 1
END
/* END tblArAlpSiteRecBill */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgArAlpCustContractU] ON [dbo].[ALP_tblArAlpCustContract] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(ContractID))
BEGIN
	/* BEGIN tblArAlpSiteRecBill */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteRecBill WHERE (deleted.ContractId = ALP_tblArAlpSiteRecBill.ContractId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.ContractId As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpCustContractU', @FldVal, 'ALP_tblArAlpSiteRecBill.ContractId')
		Set @Undo = 1
	END
	/* END tblArAlpSiteRecBill */
	/* BEGIN tblArAlpSiteRecBillServ */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteRecBillServ WHERE (deleted.ContractId = ALP_tblArAlpSiteRecBillServ.ContractId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.ContractId As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpCustContractU', @FldVal, 'ALP_tblArAlpSiteRecBillServ.ContractId')
		Set @Undo = 1
	END
	/* END tblArAlpSiteRecBillServ */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpCustContract] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpCustContract] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpCustContract] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpCustContract] TO PUBLIC
    AS [dbo];

