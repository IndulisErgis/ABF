CREATE TABLE [dbo].[tblGlAcctMask] (
    [CompId]     VARCHAR (3)   NOT NULL,
    [CurYear]    SMALLINT      NULL,
    [MaskFormat] VARCHAR (512) NULL,
    [MaskInput]  VARCHAR (512) NULL,
    [NumSegs]    TINYINT       CONSTRAINT [DF__tblGlAcct__NumSe__6FE376B1] DEFAULT (1) NULL,
    [FillChar]   VARCHAR (1)   NULL,
    [Case]       VARCHAR (1)   CONSTRAINT [DF__tblGlAcctM__Case__70D79AEA] DEFAULT (0) NULL,
    [ts]         ROWVERSION    NULL,
    [CF]         XML           NULL,
    PRIMARY KEY CLUSTERED ([CompId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAcctMask';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAcctMask';

