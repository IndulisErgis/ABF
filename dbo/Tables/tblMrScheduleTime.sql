CREATE TABLE [dbo].[tblMrScheduleTime] (
    [Id]             INT        NOT NULL,
    [ScheduleDateId] INT        NOT NULL,
    [BeginTime]      INT        CONSTRAINT [DF_tblMrScheduleTime_BeginTime] DEFAULT ((0)) NOT NULL,
    [Duration]       INT        CONSTRAINT [DF_tblMrScheduleTime_Duration] DEFAULT ((0)) NOT NULL,
    [CF]             XML        NULL,
    [ts]             ROWVERSION NULL,
    CONSTRAINT [PK_tblMrScheduleTime] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrScheduleTime';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrScheduleTime';

