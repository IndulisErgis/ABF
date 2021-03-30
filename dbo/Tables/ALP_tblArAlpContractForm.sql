CREATE TABLE [dbo].[ALP_tblArAlpContractForm] (
    [ContractFormId]    INT           IDENTITY (1, 1) NOT NULL,
    [ContractForm]      VARCHAR (255) NULL,
    [Title]             VARCHAR (255) NULL,
    [DateFirstUsed]     DATETIME      NULL,
    [DateInactive]      DATETIME      NULL,
    [RepPlanId]         INT           NULL,
    [WarrPlanId]        INT           NULL,
    [WarrTerm]          SMALLINT      NULL,
    [LeasedYN]          BIT           NULL,
    [CycleId]           INT           NULL,
    [InitialTerm]       SMALLINT      NULL,
    [RenewalTerm]       SMALLINT      NULL,
    [AutoRenewYN]       BIT           CONSTRAINT [DF_tblArAlpContractForm_AutoRenewYN] DEFAULT (0) NULL,
    [IncreasePriceYN]   BIT           CONSTRAINT [DF_tblArAlpContractForm_IncreasePriceYN] DEFAULT (0) NULL,
    [LateFeesYN]        BIT           CONSTRAINT [DF_tblArAlpContractForm_LateFeesYN] DEFAULT (0) NULL,
    [BalDueYN]          BIT           CONSTRAINT [DF_tblArAlpContractForm_BalDueYN] DEFAULT (0) NULL,
    [LimitLiabYN]       BIT           CONSTRAINT [DF_tblArAlpContractForm_LimitLiabYN] DEFAULT (0) NULL,
    [LiqDamagesYN]      BIT           CONSTRAINT [DF_tblArAlpContractForm_LiqDamagesYN] DEFAULT (0) NULL,
    [LiqDamAmount]      MONEY         NULL,
    [ThirdPartyIndemYN] BIT           NULL,
    [AssignYN]          BIT           CONSTRAINT [DF_tblArAlpContractForm_AssignYN] DEFAULT (0) NULL,
    [RecisionYN]        BIT           CONSTRAINT [DF_tblArAlpContractForm_RecisionYN] DEFAULT (0) NULL,
    [Udf1YN]            BIT           CONSTRAINT [DF_tblArAlpContractForm_Udf1YN] DEFAULT (0) NULL,
    [Udf2YN]            BIT           CONSTRAINT [DF_tblArAlpContractForm_Udf2YN] DEFAULT (0) NULL,
    [Udf3YN]            BIT           CONSTRAINT [DF_tblArAlpContractForm_Udf3YN] DEFAULT (0) NULL,
    [Comments]          TEXT          NULL,
    [ts]                ROWVERSION    NULL,
    CONSTRAINT [PK_tblArAlpContractForm] PRIMARY KEY CLUSTERED ([ContractFormId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgArAlpContractFormU] ON [dbo].[ALP_tblArAlpContractForm] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(ContractFormId))
BEGIN
	/* BEGIN tblArAlpCustContract */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpCustContract WHERE (deleted.ContractFormId = ALP_tblArAlpCustContract.ContractFormId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.ContractFormId As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpContractFormU', @FldVal, 'ALP_tblArAlpCustContract.ContractFormId')
		Set @Undo = 1
	END
	/* END tblArAlpCustContract */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgArAlpContractFormD] ON [dbo].[ALP_tblArAlpContractForm] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblArAlpCustContract */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpCustContract WHERE (deleted.ContractFormId = ALP_tblArAlpCustContract.ContractFormId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.ContractFormId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpContractFormD', @FldVal, 'ALP_tblArAlpCustContract.ContractFormId')
    Set @Undo = 1
END
/* END tblArAlpCustContract */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpContractForm] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpContractForm] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpContractForm] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpContractForm] TO PUBLIC
    AS [dbo];

