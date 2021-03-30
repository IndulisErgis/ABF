CREATE TABLE [dbo].[tblPoTransRequest] (
    [TransId]       [dbo].[pTransID] NOT NULL,
    [GroupId]       [dbo].[pTransID] NOT NULL,
    [RequestedDate] DATETIME         NOT NULL,
    [RequestedBy]   [dbo].[pUserID]  NOT NULL,
    [ApprovedDate]  DATETIME         NULL,
    [ApprovedBy]    [dbo].[pUserID]  NULL,
    [Status]        TINYINT          NOT NULL,
    [ts]            ROWVERSION       NULL,
    CONSTRAINT [PK_tblPoTransRequest] PRIMARY KEY CLUSTERED ([TransId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPoTransRequest_GroupId]
    ON [dbo].[tblPoTransRequest]([GroupId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransRequest';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransRequest';

