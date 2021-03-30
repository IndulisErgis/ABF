CREATE TABLE [dbo].[tblPsCountHeader] (
    [ID]          BIGINT            NOT NULL,
    [HostID]      [dbo].[pWrkStnID] NOT NULL,
    [TransDate]   DATETIME          NOT NULL,
    [ClosingDate] DATETIME          NULL,
    [EntryDate]   DATETIME          NOT NULL,
    [Synched]     BIT               NOT NULL,
    [CF]          XML               NULL,
    [ts]          ROWVERSION        NULL,
    [ConfigID]    BIGINT            NOT NULL,
    CONSTRAINT [PK_tblPsCountHeader] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsCountHeader_HostID]
    ON [dbo].[tblPsCountHeader]([HostID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsCountHeader_ConfigID]
    ON [dbo].[tblPsCountHeader]([ConfigID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsCountHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsCountHeader';

