CREATE TABLE [dbo].[tblMbECOStatus] (
    [Descr]      [dbo].[pDescription] NULL,
    [ts]         ROWVERSION           NULL,
    [CF]         XML                  NULL,
    [_StatusRef] INT                  NULL,
    [StatusRef]  INT                  NOT NULL,
    CONSTRAINT [PK_tblMbECOStatus] PRIMARY KEY CLUSTERED ([StatusRef] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMbECOStatus';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMbECOStatus';

