CREATE TABLE [dbo].[tblSvWorkToDo] (
    [WorkToDoID]         NVARCHAR (10)        NOT NULL,
    [Description]        [dbo].[pDescription] NULL,
    [LaborCode]          NVARCHAR (10)        NULL,
    [EstimatedTime]      BIGINT               NOT NULL,
    [RequiredSkillLevel] TINYINT              NULL,
    [CF]                 XML                  NULL,
    [ts]                 ROWVERSION           NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWorkToDo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWorkToDo';

