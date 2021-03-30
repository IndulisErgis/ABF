CREATE TABLE [dbo].[tblSvEquipmentService] (
    [ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [EquipmentID]        BIGINT        NOT NULL,
    [WorkToDoID]         NVARCHAR (10) NOT NULL,
    [ScheduleType]       TINYINT       DEFAULT ((0)) NOT NULL,
    [ScheduleInterval]   TINYINT       DEFAULT ((0)) NOT NULL,
    [ScheduleAutoPrompt] TINYINT       DEFAULT ((0)) NOT NULL,
    [ScheduleStartDate]  DATETIME      NULL,
    [ScheduleEndDate]    DATETIME      NULL,
    [ScheduleNextDate]   DATETIME      NULL,
    [CF]                 XML           NULL,
    [ts]                 ROWVERSION    NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvEquipmentService';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvEquipmentService';

