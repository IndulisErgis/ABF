CREATE TABLE [dbo].[ALP_tblArAlpServiceType] (
    [ServiceTypeId] SMALLINT     IDENTITY (1, 1) NOT NULL,
    [Service Type]  VARCHAR (50) NOT NULL,
    [RecurringSvc]  BIT          CONSTRAINT [DF_tblArAlpServiceType_RecurringSvc] DEFAULT (0) NULL,
    [ts]            ROWVERSION   NULL,
    CONSTRAINT [PK_tblArAlpServiceType] PRIMARY KEY CLUSTERED ([ServiceTypeId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgArAlpServiceTypeU] ON [dbo].[ALP_tblArAlpServiceType] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(ServiceTypeID))
BEGIN
	/* BEGIN tblArAlpSiteRecBillServ */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteRecBillServ WHERE (deleted.ServiceTypeID = ALP_tblArAlpSiteRecBillServ.ServiceType)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.ServiceTypeID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpServiceTypeU', @FldVal, 'ALP_tblArAlpSiteRecBillServ.ServiceType')
		Set @Undo = 1
	END
	/* END tblArAlpSiteRecBillServ */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgArAlpServiceTypeD] ON [dbo].[ALP_tblArAlpServiceType] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblArAlpSiteRecBillServ */
IF (SELECT COUNT(*) FROM deleted, ALP_tblArAlpSiteRecBillServ WHERE (deleted.ServiceTypeId = ALP_tblArAlpSiteRecBillServ.ServiceType)) > 0
BEGIN
    Select @FldVal = Cast(deleted.ServiceTypeId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpServiceTypeD', @FldVal, 'ALP_tblArAlpSiteRecBillServ.ServiceType')
    Set @Undo = 1
END
/* END tblArAlpSiteRecBillServ */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpServiceType] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpServiceType] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpServiceType] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpServiceType] TO PUBLIC
    AS [dbo];

