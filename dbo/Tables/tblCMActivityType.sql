CREATE TABLE [dbo].[tblCMActivityType] (
    [ActTypeRef] INT                  NULL,
    [Descr]      [dbo].[pDescription] NOT NULL,
    [ts]         ROWVERSION           NULL,
    [CF]         XML                  NULL,
    [ID]         BIGINT               NOT NULL,
    CONSTRAINT [PK_tblCmActivityType] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCMActivityType';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCMActivityType';

