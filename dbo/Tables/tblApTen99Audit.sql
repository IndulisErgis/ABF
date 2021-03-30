CREATE TABLE [dbo].[tblApTen99Audit] (
    [RecNo]       SMALLINT       NOT NULL,
    [RecType]     VARCHAR (1)    NULL,
    [RecPosition] SMALLINT       NOT NULL,
    [RecLength]   SMALLINT       CONSTRAINT [DF_tblApTen99Audit_RecLength] DEFAULT ((0)) NULL,
    [RecTitle]    VARCHAR (50)   NULL,
    [RecValue]    VARCHAR (1000) NULL,
    [PayToName]   VARCHAR (30)   NULL,
    CONSTRAINT [PK_tblApTen99Audit] PRIMARY KEY CLUSTERED ([RecNo] ASC, [RecPosition] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTen99Audit';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTen99Audit';

