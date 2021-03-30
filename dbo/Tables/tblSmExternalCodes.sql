CREATE TABLE [dbo].[tblSmExternalCodes] (
    [CodeId]    NVARCHAR (15)        NOT NULL,
    [Code]      NVARCHAR (25)        NOT NULL,
    [Descr]     [dbo].[pDescription] NULL,
    [Status]    TINYINT              CONSTRAINT [DF_tblSmExternalCodes_Status] DEFAULT ((0)) NOT NULL,
    [DefaultYn] BIT                  CONSTRAINT [DF_tblSmExternalCodes_DefaultYn] DEFAULT ((0)) NOT NULL,
    [CF]        XML                  NULL,
    [ts]        ROWVERSION           NULL,
    CONSTRAINT [PK_tblSmExternalCodes] PRIMARY KEY CLUSTERED ([CodeId] ASC, [Code] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmExternalCodes';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmExternalCodes';

