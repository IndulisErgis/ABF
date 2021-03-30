CREATE TABLE [dbo].[tblPaW2MagMed] (
    [Counter]    INT             IDENTITY (1, 1) NOT NULL,
    [LineRecord] NVARCHAR (2048) CONSTRAINT [DF_tblPaW2MagMed_LineRecord] DEFAULT ((0)) NULL,
    [EmployeeId] [dbo].[pEmpID]  NULL,
    [State]      NVARCHAR (4)    NULL,
    [Type]       NVARCHAR (2)    NULL,
    CONSTRAINT [PK_tblPaW2MagMed] PRIMARY KEY CLUSTERED ([Counter] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaW2MagMed';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaW2MagMed';

