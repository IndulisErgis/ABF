CREATE TABLE [dbo].[ALP_tblJmSkill] (
    [SkillId]    INT           IDENTITY (1, 1) NOT NULL,
    [Skill]      VARCHAR (15)  NULL,
    [Desc]       VARCHAR (255) NULL,
    [InactiveYN] BIT           CONSTRAINT [DF_tblJmSkill_InactiveYN] DEFAULT (0) NULL,
    [Comments]   TEXT          NULL,
    [ts]         ROWVERSION    NULL,
    CONSTRAINT [PK_tblJmSkill] PRIMARY KEY CLUSTERED ([SkillId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE TRIGGER [dbo].[trgJmSkillD] ON [dbo].[ALP_tblJmSkill] FOR DELETE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
/* BEGIN tblJmSvcTkt */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTkt WHERE (deleted.SkillId = ALP_tblJmSvcTkt.SkillId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.SkillId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgJmSkillD', @FldVal, 'ALP_tblJmSvcTkt.SkillId')
    Set @Undo = 1
END
/* END tblJmSvcTkt */
/* BEGIN tblJmTechSkills */
IF (SELECT COUNT(*) FROM deleted, ALP_tblJmTechSkills WHERE (deleted.SkillId = ALP_tblJmTechSkills.SkillId)) > 0
BEGIN
    Select @FldVal = Cast(deleted.SkillId As Varchar) from deleted
    RAISERROR (90000, 16, 1, 'trgJmSkillD', @FldVal, 'ALP_tblJmTechSkills.SkillId')
    Set @Undo = 1
END
/* END tblJmTechSkills */
If @Undo = 1
Begin
	Rollback Transaction
End
GO
CREATE TRIGGER [dbo].[trgJmSkillU] ON [dbo].[ALP_tblJmSkill] FOR UPDATE AS
SET NOCOUNT ON
Declare @FldVal varchar(255)
Declare @Undo bit
Set @Undo = 0
IF (UPDATE(SkillID))
BEGIN
	/* BEGIN tblJmSvcTkt */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblJmSvcTkt WHERE (deleted.SkillID = ALP_tblJmSvcTkt.SkillId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.SkillID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgJmSkillU', @FldVal, 'ALP_tblJmSvcTkt.SkillId')
		Set @Undo = 1
	END
	/* END tblJmSvcTkt */
	/* BEGIN tblJmTechSkills */
	IF (SELECT COUNT(*) FROM deleted, ALP_tblJmTechSkills WHERE (deleted.SkillID = ALP_tblJmTechSkills.SkillId)) > 0
	BEGIN
		Select @FldVal = Cast(deleted.SkillID As Varchar) from deleted
		RAISERROR (90020, 16, 1, 'trgJmSkillU', @FldVal, 'ALP_tblJmTechSkills.SkillId')
		Set @Undo = 1
	END
	/* END tblJmTechSkills */
END
If @Undo = 1
Begin
	Rollback Transaction
End
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmSkill] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmSkill] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmSkill] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmSkill] TO PUBLIC
    AS [dbo];

