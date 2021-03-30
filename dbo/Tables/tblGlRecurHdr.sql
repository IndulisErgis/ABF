CREATE TABLE [dbo].[tblGlRecurHdr] (
    [GroupId]  VARCHAR (10) NOT NULL,
    [Desc]     VARCHAR (25) NULL,
    [Template] BIT          CONSTRAINT [DF__tblGlRecu__Templ__3675EF2B] DEFAULT (0) NULL,
    [ts]       ROWVERSION   NULL,
    [CF]       XML          NULL,
    PRIMARY KEY CLUSTERED ([GroupId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlRecurHdr';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlRecurHdr';

