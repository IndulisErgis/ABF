CREATE TABLE [dbo].[tblPcProject] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [ProjectName] NVARCHAR (10)   NOT NULL,
    [CustId]      [dbo].[pCustID] NULL,
    [Type]        TINYINT         CONSTRAINT [DF_tblPcProject_Type] DEFAULT ((0)) NOT NULL,
    [PrintOption] NVARCHAR (255)  NULL,
    [ts]          ROWVERSION      NULL,
    CONSTRAINT [PK_tblPcProject] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [uiProjectCust]
    ON [dbo].[tblPcProject]([ProjectName] ASC, [CustId] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlCustId]
    ON [dbo].[tblPcProject]([CustId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcProject';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcProject';

