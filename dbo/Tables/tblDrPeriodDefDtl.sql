CREATE TABLE [dbo].[tblDrPeriodDefDtl] (
    [PdDefID]   VARCHAR (10) NOT NULL,
    [Period]    SMALLINT     NOT NULL,
    [Increment] SMALLINT     DEFAULT ((1)) NOT NULL,
    [IncUnit]   TINYINT      DEFAULT ((20)) NOT NULL,
    [ts]        ROWVERSION   NULL,
    [CF]        XML          NULL,
    CONSTRAINT [PK_tblDrPeriodDefDtl] PRIMARY KEY CLUSTERED ([PdDefID] ASC, [Period] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDrPeriodDefDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDrPeriodDefDtl';

