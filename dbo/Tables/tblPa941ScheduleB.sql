CREATE TABLE [dbo].[tblPa941ScheduleB] (
    [Id]      INT          IDENTITY (1, 1) NOT NULL,
    [PaYear]  SMALLINT     NOT NULL,
    [PaMonth] TINYINT      NOT NULL,
    [PaDay]   TINYINT      NOT NULL,
    [Amount]  [dbo].[pDec] CONSTRAINT [DF_tblPa941ScheduleB_Amount] DEFAULT ((0)) NOT NULL,
    [CF]      XML          NULL,
    [ts]      ROWVERSION   NULL,
    CONSTRAINT [PK_tblPa941ScheduleB] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPa941ScheduleB_PaYear]
    ON [dbo].[tblPa941ScheduleB]([PaYear] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPa941ScheduleB';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPa941ScheduleB';

