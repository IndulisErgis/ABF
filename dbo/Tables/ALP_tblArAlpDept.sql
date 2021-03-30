CREATE TABLE [dbo].[ALP_tblArAlpDept] (
    [DeptId]     INT           IDENTITY (1, 1) NOT NULL,
    [Dept]       VARCHAR (10)  NULL,
    [Name]       VARCHAR (255) NULL,
    [GlSegId]    VARCHAR (12)  NULL,
    [InactiveYN] BIT           CONSTRAINT [DF_tblArAlpDept_InactiveYN] DEFAULT (0) NULL,
    [ts]         ROWVERSION    NULL,
    CONSTRAINT [PK_tblArAlpDept] PRIMARY KEY CLUSTERED ([DeptId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgArAlpDeptD] ON [dbo].[ALP_tblArAlpDept] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmSvcTkt */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTkt WHERE (deleted.DeptId = ALP_tblJmSvcTkt.DeptId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.DeptId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpDeptD', @FldVal, 'ALP_tblJmSvcTkt.DeptId')
    Set @Undo = 1
END
/* END tblJmSvcTkt */
/* BEGIN tblJmTech */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmTech WHERE (deleted.DeptId = ALP_tblJmTech.DeptId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.DeptId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgArAlpDeptD', @FldVal, 'ALP_tblJmTech.DeptId')
    Set @Undo = 1
END
/* END tblJmTech */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgArAlpDeptU] ON [dbo].[ALP_tblArAlpDept] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(DeptID))
BEGIN
	/* BEGIN tblJmSvcTkt */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTkt WHERE (deleted.DeptID = ALP_tblJmSvcTkt.DeptId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.DeptID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpDeptU', @FldVal, 'ALP_tblJmSvcTkt.DeptId')
		Set @Undo = 1
	END
	/* END tblJmSvcTkt */
	/* BEGIN tblJmTech */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblJmTech WHERE (deleted.DeptID = ALP_tblJmTech.DeptId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.DeptID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgArAlpDeptU', @FldVal, 'ALP_tblJmTech.DeptId')
		Set @Undo = 1
	END
	/* END tblJmTech */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpDept] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpDept] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpDept] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpDept] TO PUBLIC
    AS [dbo];

