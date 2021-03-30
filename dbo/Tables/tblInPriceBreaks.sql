CREATE TABLE [dbo].[tblInPriceBreaks] (
    [SeqNum]     INT          IDENTITY (1, 1) NOT NULL,
    [BrkId]      VARCHAR (10) NULL,
    [BrkQty]     [dbo].[pDec] CONSTRAINT [DF__tblInPric__BrkQt__09042A36] DEFAULT (0) NULL,
    [BrkAdj]     [dbo].[pDec] CONSTRAINT [DF__tblInPric__BrkAd__09F84E6F] DEFAULT (0) NULL,
    [BrkAdjType] TINYINT      CONSTRAINT [DF__tblInPric__BrkAd__0AEC72A8] DEFAULT (0) NULL,
    [ts]         ROWVERSION   NULL,
    [CF]         XML          NULL,
    CONSTRAINT [PK__tblInPriceBreaks__2E3BD7D3] PRIMARY KEY CLUSTERED ([SeqNum] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInPriceBreaks] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInPriceBreaks';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInPriceBreaks';

