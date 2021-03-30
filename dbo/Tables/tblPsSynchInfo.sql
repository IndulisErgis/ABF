CREATE TABLE [dbo].[tblPsSynchInfo] (
    [SynchID]     BIGINT            NOT NULL,
    [HostID]      [dbo].[pWrkStnID] NOT NULL,
    [ProcessType] SMALLINT          NOT NULL,
    [Status]      SMALLINT          NOT NULL,
    [ts]          ROWVERSION        NULL,
    [EntryDate]   DATETIME          NOT NULL,
    CONSTRAINT [PK_tblPsSynchInfo] PRIMARY KEY CLUSTERED ([SynchID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsSynchInfo_HostIDProcessType]
    ON [dbo].[tblPsSynchInfo]([HostID] ASC, [ProcessType] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsSynchInfo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsSynchInfo';

