CREATE TABLE [dbo].[tblCfConfigVariable] (
    [VariableId]   BIGINT        NOT NULL,
    [ConfigId]     BIGINT        NOT NULL,
    [VariableCode] NVARCHAR (50) NOT NULL,
    [VariableType] TINYINT       CONSTRAINT [DF_tblCfConfigVariable_VariableType] DEFAULT ((0)) NOT NULL,
    [TextLength]   INT           NULL,
    [Descr]        NVARCHAR (50) NULL,
    [CF]           XML           NULL,
    [ts]           ROWVERSION    NULL,
    CONSTRAINT [PK_tblCfConfigVariable] PRIMARY KEY CLUSTERED ([VariableId] ASC),
    CONSTRAINT [UX_tblCfConfigVariable_ConfigId_VariableCode] UNIQUE NONCLUSTERED ([ConfigId] ASC, [VariableCode] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigVariable';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigVariable';

