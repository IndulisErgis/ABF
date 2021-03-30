CREATE TABLE [dbo].[tblGlAcctMaskSegment] (
    [Number]       INT          NOT NULL,
    [Mask]         VARCHAR (12) NULL,
    [Length]       TINYINT      CONSTRAINT [DF_tblGlAcctMaskSegment_Length] DEFAULT ((0)) NOT NULL,
    [Description]  VARCHAR (20) NULL,
    [Abbreviation] VARCHAR (4)  NULL,
    [CF]           XML          NULL,
    [ts]           ROWVERSION   NULL,
    CONSTRAINT [PK_tblGlAcctMaskSegment] PRIMARY KEY CLUSTERED ([Number] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAcctMaskSegment';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAcctMaskSegment';

