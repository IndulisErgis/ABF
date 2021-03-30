CREATE TABLE [dbo].[tblGlAllocPdCodeSegment] (
    [ID]           BIGINT           NOT NULL,
    [AllocCodeID]  BIGINT           NOT NULL,
    [DetailType]   TINYINT          NOT NULL,
    [Sequence]     BIGINT           NOT NULL,
    [SegmentID]    NVARCHAR (12)    NOT NULL,
    [AltSegmentID] NVARCHAR (12)    NULL,
    [AllocType]    TINYINT          NULL,
    [AllocAmount]  [dbo].[pDecimal] NULL,
    [AllocLimit]   [dbo].[pDecimal] NULL,
    [CF]           XML              NULL,
    [ts]           ROWVERSION       NULL,
    CONSTRAINT [PK_tblGlAllocPdCodeSegment] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocPdCodeSegment';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocPdCodeSegment';

