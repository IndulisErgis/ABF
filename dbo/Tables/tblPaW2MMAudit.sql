CREATE TABLE [dbo].[tblPaW2MMAudit] (
    [RecordType] NCHAR (2)     NOT NULL,
    [Title]      NVARCHAR (50) NULL,
    [Position]   SMALLINT      NOT NULL,
    [Length]     SMALLINT      CONSTRAINT [DF_tblPaW2MMAudit_Length] DEFAULT ((0)) NULL,
    [Note]       NVARCHAR (50) NULL,
    CONSTRAINT [PK_tblPaW2MMAudit] PRIMARY KEY CLUSTERED ([RecordType] ASC, [Position] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaW2MMAudit';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaW2MMAudit';

