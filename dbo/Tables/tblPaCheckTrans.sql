CREATE TABLE [dbo].[tblPaCheckTrans] (
    [Id]        INT        IDENTITY (1, 1) NOT NULL,
    [CheckId]   INT        NOT NULL,
    [TransType] TINYINT    NOT NULL,
    [TransId]   INT        NOT NULL,
    [ts]        ROWVERSION NULL,
    CONSTRAINT [PK_tblPaCheckTrans] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPaCheckTrans_CheckIdTransTypeTransId]
    ON [dbo].[tblPaCheckTrans]([CheckId] ASC, [TransType] ASC, [TransId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckTrans';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckTrans';

