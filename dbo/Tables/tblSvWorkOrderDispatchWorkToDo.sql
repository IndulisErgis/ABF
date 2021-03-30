CREATE TABLE [dbo].[tblSvWorkOrderDispatchWorkToDo] (
    [ID]            INT                  IDENTITY (1, 1) NOT NULL,
    [DispatchID]    BIGINT               NOT NULL,
    [WorkOrderID]   BIGINT               NOT NULL,
    [WorkToDoID]    NVARCHAR (10)        NOT NULL,
    [GroupID]       NVARCHAR (10)        NULL,
    [Description]   [dbo].[pDescription] NULL,
    [EstimatedTime] BIGINT               NOT NULL,
    [SkillLevel]    TINYINT              NULL,
    [CF]            XML                  NULL,
    [ts]            ROWVERSION           NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWorkOrderDispatchWorkToDo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWorkOrderDispatchWorkToDo';

