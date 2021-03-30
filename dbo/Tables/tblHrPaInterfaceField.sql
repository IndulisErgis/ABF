CREATE TABLE [dbo].[tblHrPaInterfaceField] (
    [FieldName]       NVARCHAR (255) NOT NULL,
    [EnableInterface] BIT            CONSTRAINT [DF_tblHrPaInterface_EnableInterface] DEFAULT ((0)) NOT NULL,
    [CF]              XML            NULL,
    [ts]              ROWVERSION     NULL,
    CONSTRAINT [PK_tblHrPAInterfaceField] PRIMARY KEY CLUSTERED ([FieldName] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrPaInterfaceField';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrPaInterfaceField';

