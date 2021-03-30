CREATE TABLE [dbo].[ALP_tblJmTechSkills] (
    [TechId]  INT        NOT NULL,
    [SkillId] INT        NOT NULL,
    [ts]      ROWVERSION NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_tblJmTechSkills_1]
    ON [dbo].[ALP_tblJmTechSkills]([SkillId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_tblJmTechSkills]
    ON [dbo].[ALP_tblJmTechSkills]([TechId] ASC, [SkillId] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmTechSkills] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmTechSkills] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmTechSkills] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmTechSkills] TO PUBLIC
    AS [dbo];

