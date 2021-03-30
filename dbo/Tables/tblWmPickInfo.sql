CREATE TABLE [dbo].[tblWmPickInfo] (
    [Id]            NVARCHAR (20)  NOT NULL,
    [Description]   NVARCHAR (50)  NULL,
    [Selected]      INT            NOT NULL,
    [Filter]        NVARCHAR (MAX) NULL,
    [DisplayFilter] NVARCHAR (MAX) NULL,
    [CF]            XML            NULL,
    [ts]            ROWVERSION     NULL,
    CONSTRAINT [PK_tblWmPickInfo] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmPickInfo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmPickInfo';

