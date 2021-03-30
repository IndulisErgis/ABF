CREATE TABLE [dbo].[tblSysEncDec] (
    [Counter]  INT               IDENTITY (1, 1) NOT NULL,
    [UserID]   [dbo].[pUserID]   NOT NULL,
    [WrkStnID] [dbo].[pWrkStnID] NOT NULL,
    [RefID]    NVARCHAR (50)     NULL,
    [Value1]   NVARCHAR (255)    NULL,
    [Value2]   NVARCHAR (255)    NULL,
    CONSTRAINT [PK_tblSysEncDec] PRIMARY KEY CLUSTERED ([Counter] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblSysEncDec_RefID]
    ON [dbo].[tblSysEncDec]([RefID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysEncDec';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysEncDec';

