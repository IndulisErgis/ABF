CREATE TABLE [dbo].[tblPoTransRequestResponse] (
    [TransId]      NVARCHAR (8) NOT NULL,
    [Level]        INT          NOT NULL,
    [UserId]       INT          NULL,
    [Response]     SMALLINT     NULL,
    [ResponseDate] DATETIME     NULL,
    [Comments]     TEXT         NULL,
    [CF]           XML          NULL,
    CONSTRAINT [PK__tblPoTransRequestResponse] PRIMARY KEY CLUSTERED ([TransId] ASC, [Level] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransRequestResponse';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransRequestResponse';

