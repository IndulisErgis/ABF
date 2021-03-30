CREATE TABLE [dbo].[tblSmFunctionFlag] (
    [FunctionID] VARCHAR (10) NOT NULL,
    [GlYear]     SMALLINT     NOT NULL,
    [Period]     SMALLINT     NOT NULL,
    [Id]         INT          IDENTITY (1, 1) NOT NULL,
    [ts]         ROWVERSION   NULL,
    CONSTRAINT [PK_tblSmFunctionFlag] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSmFunctionFlag_FunctionIdGlYearPeriod]
    ON [dbo].[tblSmFunctionFlag]([FunctionID] ASC, [GlYear] ASC, [Period] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmFunctionFlag';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmFunctionFlag';

