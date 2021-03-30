CREATE TABLE [dbo].[tblGlAllocPdCodeDetail] (
    [ID]           BIGINT           NOT NULL,
    [AllocCodeID]  BIGINT           NOT NULL,
    [DetailType]   TINYINT          NOT NULL,
    [Sequence]     BIGINT           NOT NULL,
    [AccountID]    [dbo].[pGlAcct]  NOT NULL,
    [AltAccountID] [dbo].[pGlAcct]  NULL,
    [AllocType]    TINYINT          NULL,
    [AllocAmount]  [dbo].[pDecimal] NULL,
    [AllocLimit]   [dbo].[pDecimal] NULL,
    [CF]           XML              NULL,
    [ts]           ROWVERSION       NULL,
    CONSTRAINT [PK_tblGlAllocPdCodeDetail] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocPdCodeDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocPdCodeDetail';

