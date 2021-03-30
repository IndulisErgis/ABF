CREATE TABLE [dbo].[tblPaAatrixInfo] (
    [Counter]  INT               IDENTITY (1, 1) NOT NULL,
    [UserId]   [dbo].[pUserID]   NOT NULL,
    [WrkStnId] [dbo].[pWrkStnID] NOT NULL,
    [Id]       NVARCHAR (50)     NOT NULL,
    [Value]    NVARCHAR (255)    NULL,
    [ts]       ROWVERSION        NULL,
    CONSTRAINT [PK_tblPaAatrixInfo] PRIMARY KEY CLUSTERED ([Counter] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaAatrixInfo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaAatrixInfo';

