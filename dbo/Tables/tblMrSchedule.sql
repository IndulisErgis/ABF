CREATE TABLE [dbo].[tblMrSchedule] (
    [Id]    NVARCHAR (10)        NOT NULL,
    [Descr] [dbo].[pDescription] NULL,
    [CF]    XML                  NULL,
    [ts]    ROWVERSION           NULL,
    CONSTRAINT [PK_tblMrSchedule] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrSchedule';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMrSchedule';

