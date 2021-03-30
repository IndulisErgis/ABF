CREATE TABLE [dbo].[tblPsPmtMethod] (
    [PmtMethodID] NVARCHAR (10)        NOT NULL,
    [Description] [dbo].[pDescription] NULL,
    [Status]      TINYINT              CONSTRAINT [DF_tblPsPmtMethod_Status] DEFAULT ((0)) NOT NULL,
    [Image]       VARBINARY (MAX)      NULL,
    [CF]          XML                  NULL,
    [ts]          ROWVERSION           NULL,
    CONSTRAINT [PK_tblPsPmtMethod] PRIMARY KEY CLUSTERED ([PmtMethodID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsPmtMethod';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsPmtMethod';

