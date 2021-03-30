CREATE TABLE [dbo].[tblSmLog] (
    [LogId]       INT              IDENTITY (1, 1) NOT NULL,
    [ActivityId]  UNIQUEIDENTIFIER NOT NULL,
    [Description] VARCHAR (50)     NULL,
    [Log]         VARBINARY (MAX)  NULL,
    [ts]          ROWVERSION       NULL,
    CONSTRAINT [PK_tblSmLog] PRIMARY KEY NONCLUSTERED ([LogId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmLog';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmLog';

