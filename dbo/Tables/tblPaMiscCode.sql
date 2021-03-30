CREATE TABLE [dbo].[tblPaMiscCode] (
    [Id]             NVARCHAR (10) NOT NULL,
    [SequenceNumber] SMALLINT      CONSTRAINT [DF_tblPaMiscCode_SequenceNumber] DEFAULT ((0)) NOT NULL,
    [Descr]          NVARCHAR (50) NULL,
    [CF]             XML           NULL,
    [ts]             ROWVERSION    NULL,
    CONSTRAINT [PK_tblPaMiscCode] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaMiscCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaMiscCode';

