CREATE TABLE [dbo].[tblCmBulkComm] (
    [BCRef]    INT                  IDENTITY (1, 1) NOT NULL,
    [BCType]   SMALLINT             DEFAULT ((0)) NOT NULL,
    [Descr]    [dbo].[pDescription] NOT NULL,
    [Subject]  [dbo].[pDescription] NULL,
    [Body]     NVARCHAR (MAX)       NULL,
    [FileName] [dbo].[pDescription] NULL,
    [ts]       ROWVERSION           NULL,
    [CF]       XML                  NULL,
    [ID]       BIGINT               NOT NULL,
    CONSTRAINT [PK_tblCmBulkComm] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmBulkComm';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmBulkComm';

