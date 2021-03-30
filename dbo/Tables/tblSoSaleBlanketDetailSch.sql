CREATE TABLE [dbo].[tblSoSaleBlanketDetailSch] (
    [BlanketDtlRef]    INT          NOT NULL,
    [ReleaseDate]      DATETIME     NULL,
    [QtyOrdered]       [dbo].[pDec] DEFAULT ((0)) NOT NULL,
    [Status]           TINYINT      DEFAULT ((0)) NOT NULL,
    [ts]               ROWVERSION   NULL,
    [CF]               XML          NULL,
    [BlanketDtlSchRef] INT          NOT NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoSaleBlanketDetailSch';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoSaleBlanketDetailSch';

