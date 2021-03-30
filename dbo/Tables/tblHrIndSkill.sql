CREATE TABLE [dbo].[tblHrIndSkill] (
    [ID]              BIGINT           NOT NULL,
    [IndId]           [dbo].[pEmpID]   NOT NULL,
    [SkillTypeCodeID] BIGINT           NOT NULL,
    [DateAcquired]    DATETIME         NULL,
    [Hours]           [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndSkill_Hours] DEFAULT ((0)) NOT NULL,
    [Notes]           NVARCHAR (MAX)   NULL,
    [CF]              XML              NULL,
    [ts]              ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrIndSkill] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndSkill_IndId]
    ON [dbo].[tblHrIndSkill]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndSkill';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndSkill';

