CREATE TABLE [dbo].[tblGlAllocTransHdr] (
    [TransAllocId] VARCHAR (10)    NOT NULL,
    [Desc]         VARCHAR (30)    NULL,
    [ExpDate]      DATETIME        NULL,
    [Notes]        TEXT            NULL,
    [SegmentFlags] [dbo].[pGlAcct] NOT NULL,
    [CF]           XML             NULL,
    CONSTRAINT [PK__tblGlAllocTransHdr] PRIMARY KEY CLUSTERED ([TransAllocId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocTransHdr';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAllocTransHdr';

