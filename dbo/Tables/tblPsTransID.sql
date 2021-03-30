CREATE TABLE [dbo].[tblPsTransID] (
    [HostID] [dbo].[pWrkStnID] NOT NULL,
    [NextID] INT               CONSTRAINT [DF_tblPsTransID_NextID] DEFAULT ((1)) NOT NULL,
    [ts]     ROWVERSION        NULL,
    CONSTRAINT [PK_tblPsTransID] PRIMARY KEY NONCLUSTERED ([HostID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsTransID';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsTransID';

