CREATE TABLE [dbo].[tblDrPeriodDef] (
    [PdDefID]      VARCHAR (10)         NOT NULL,
    [Descr]        [dbo].[pDescription] NULL,
    [TimeFencePds] SMALLINT             DEFAULT ((0)) NOT NULL,
    [ts]           ROWVERSION           NULL,
    [CF]           XML                  NULL,
    CONSTRAINT [PK_tblDrPeriodDef] PRIMARY KEY CLUSTERED ([PdDefID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDrPeriodDef';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDrPeriodDef';

