CREATE TABLE [dbo].[ALP_tblArAlpBranch] (
    [BranchId]   INT           IDENTITY (1, 1) NOT NULL,
    [Branch]     VARCHAR (255) NULL,
    [InactiveYN] BIT           CONSTRAINT [DF_tblArAlpBranch_InactiveYN] DEFAULT (0) NULL,
    [Name]       VARCHAR (255) NULL,
    [Addr1]      VARCHAR (255) NULL,
    [Addr2]      VARCHAR (255) NULL,
    [City]       VARCHAR (255) NULL,
    [Region]     VARCHAR (50)  NULL,
    [Country]    VARCHAR (255) NULL,
    [PostalCode] VARCHAR (10)  NULL,
    [IntlPrefix] VARCHAR (6)   NULL,
    [Phone]      VARCHAR (15)  NULL,
    [Fax]        VARCHAR (15)  NULL,
    [Email]      TEXT          NULL,
    [DfltLocID]  VARCHAR (10)  NULL,
    [GlSegId]    VARCHAR (12)  NULL,
    [ts]         ROWVERSION    NULL,
    CONSTRAINT [PK_tblArAlpBranch] PRIMARY KEY CLUSTERED ([BranchId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgArAlpBranchD] ON [dbo].[ALP_tblArAlpBranch] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmSvcTkt */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTkt WHERE (deleted.BranchId = ALP_tblJmSvcTkt.BranchId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.BranchId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpBranchD', @FldVal, 'ALP_tblJmSvcTkt.BranchId')
    Set @Undo = 1
END
/* END tblJmSvcTkt */
/* BEGIN tblArAlpSite */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSite WHERE (deleted.BranchId = ALP_tblArAlpSite.BranchId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.BranchId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpBranchD', @FldVal, 'ALP_tblArAlpSite.BranchId')
    Set @Undo = 1
END
/* END tblArAlpSite */
/* BEGIN tblArSalesRep */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArSalesRep WHERE (deleted.BranchId = ALP_tblArSalesRep.AlpBranchId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.BranchId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpBranchD', @FldVal, 'ALP_tblArSalesRep.AlpBranchId')
    Set @Undo = 1
END
/* END tblArSalesRep */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgArAlpBranchU] ON [dbo].[ALP_tblArAlpBranch] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(BranchID))
BEGIN
	/* BEGIN tblArAlpSite */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSite WHERE (deleted.BranchID = ALP_tblArAlpSite.BranchId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.BranchID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpBranchU', @FldVal, 'ALP_tblArAlpSite.BranchId')
		Set @Undo = 1
	END
	/* END tblArAlpSite */
	/* BEGIN tblArSalesRep */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArSalesRep WHERE (deleted.BranchID = ALP_tblArSalesRep.AlpBranchId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.BranchID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpBranchU', @FldVal, 'ALP_tblArSalesRep.AlpBranchId')
		Set @Undo = 1
	END
	/* END tblArSalesRep */
	/* BEGIN tblJmSvcTkt */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTkt WHERE (deleted.BranchID = ALP_tblJmSvcTkt.BranchId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.BranchID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpBranchU', @FldVal, 'ALP_tblJmSvcTkt.BranchId')
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
    ON OBJECT::[dbo].[ALP_tblArAlpBranch] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpBranch] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpBranch] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpBranch] TO PUBLIC
    AS [dbo];

