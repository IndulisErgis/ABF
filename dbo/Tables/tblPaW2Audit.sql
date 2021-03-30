CREATE TABLE [dbo].[tblPaW2Audit] (
    [RecNo]       SMALLINT        NOT NULL,
    [RecType]     NVARCHAR (3)    NULL,
    [RecPosition] SMALLINT        NOT NULL,
    [RecLength]   SMALLINT        CONSTRAINT [DF_tblPaW2Audit_RecLength] DEFAULT ((0)) NULL,
    [RecTitle]    NVARCHAR (50)   NULL,
    [RecValue]    NVARCHAR (1050) NULL,
    CONSTRAINT [PK_tblPaW2Audit] PRIMARY KEY CLUSTERED ([RecNo] ASC, [RecPosition] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaW2Audit';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaW2Audit';

