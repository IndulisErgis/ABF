CREATE TABLE [dbo].[ALP_tblJmTech] (
    [TechId]                  INT           IDENTITY (1, 1) NOT NULL,
    [Tech]                    VARCHAR (3)   NULL,
    [Name]                    VARCHAR (255) NULL,
    [Addr1]                   VARCHAR (255) NULL,
    [Addr2]                   VARCHAR (255) NULL,
    [City]                    VARCHAR (255) NULL,
    [Region]                  VARCHAR (255) NULL,
    [Country]                 VARCHAR (255) NULL,
    [PostalCode]              VARCHAR (10)  NULL,
    [IntlPrefix]              VARCHAR (6)   NULL,
    [Phone]                   VARCHAR (15)  NULL,
    [Fax]                     VARCHAR (15)  NULL,
    [Pager]                   VARCHAR (15)  NULL,
    [Mobile]                  VARCHAR (15)  NULL,
    [Email]                   TEXT          NULL,
    [EmplId]                  VARCHAR (10)  NULL,
    [InactiveYN]              BIT           CONSTRAINT [DF_tblJmTech_InactiveYN] DEFAULT (0) NULL,
    [BranchId]                INT           NULL,
    [DivisionId]              INT           NULL,
    [DeptId]                  INT           NULL,
    [PayBasedOn]              TINYINT       NULL,
    [DfltLaborCostPerHour]    FLOAT (53)    NULL,
    [DfltLaborCostPerPoint]   FLOAT (53)    NULL,
    [CosOffset]               VARCHAR (40)  NULL,
    [VehicleId]               INT           NULL,
    [GasCard]                 VARCHAR (255) NULL,
    [GasPIN]                  VARCHAR (255) NULL,
    [DfltSvcJobYN]            BIT           CONSTRAINT [DF_tblJmTech_DfltSvcJobYN] DEFAULT (0) NULL,
    [ts]                      ROWVERSION    NULL,
    [DfltTaxLocId]            VARCHAR (10)  NULL,
    [ActiveDirectoryUserName] VARCHAR (100) NULL,
    [TechDfltWhseLocID]       VARCHAR (10)  NULL,
    CONSTRAINT [PK_tblJmTech] PRIMARY KEY CLUSTERED ([TechId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgJmTechU] ON [dbo].[ALP_tblJmTech] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(TechID))
BEGIN
	/* BEGIN tblJmSvcTkt */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTkt WHERE (deleted.TechID = ALP_tblJmSvcTkt.LeadTechId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.TechID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgJmTechU', @FldVal, 'ALP_tblJmSvcTkt.LeadTechId')
		Set @Undo = 1
	END
	/* END tblJmSvcTkt */
	/* BEGIN tblJmTechSkills */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblJmTechSkills WHERE (deleted.TechID = ALP_tblJmTechSkills.TechId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.TechID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgJmTechU', @FldVal, 'ALP_tblJmTechSkills.TechId')
		Set @Undo = 1
	END
	/* END tblJmTechSkills */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgJmTechD] ON [dbo].[ALP_tblJmTech] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmSvcTkt */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTkt WHERE (deleted.TechId = ALP_tblJmSvcTkt.LeadTechId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.TechId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgJmTechD', @FldVal, 'ALP_tblJmSvcTkt.LeadTechId')
    Set @Undo = 1
END
/* END tblJmSvcTkt */
/* BEGIN tblJmTechSkills */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmTechSkills WHERE (deleted.TechId = ALP_tblJmTechSkills.TechId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.TechId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgJmTechD', @FldVal, 'ALP_tblJmTechSkills.TechId')
    Set @Undo = 1
END
/* END tblJmTechSkills */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmTech] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmTech] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmTech] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmTech] TO PUBLIC
    AS [dbo];

