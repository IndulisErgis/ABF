CREATE TABLE [dbo].[tblSmMAPIInfo] (
    [InfoRef]   INT           IDENTITY (1, 1) NOT NULL,
    [InfoID]    VARCHAR (50)  NOT NULL,
    [InfoValue] VARCHAR (255) NULL,
    [ts]        ROWVERSION    NULL,
    CONSTRAINT [PK_tblSmMAPIInfo] PRIMARY KEY CLUSTERED ([InfoRef] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_InfoID]
    ON [dbo].[tblSmMAPIInfo]([InfoID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmMAPIInfo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmMAPIInfo';

