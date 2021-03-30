CREATE TABLE [dbo].[tblHrIndProperty] (
    [ID]             BIGINT          NOT NULL,
    [IndId]          [dbo].[pEmpID]  NOT NULL,
    [PropertyCodeID] BIGINT          NOT NULL,
    [Description]    NVARCHAR (50)   NULL,
    [StartDate]      DATETIME        NOT NULL,
    [EndDate]        DATETIME        NULL,
    [Value]          DECIMAL (18, 2) CONSTRAINT [DF_tblHrIndProperty_Value] DEFAULT ((0)) NOT NULL,
    [SerialNumber]   NVARCHAR (10)   NULL,
    [CF]             XML             NULL,
    [ts]             ROWVERSION      NULL,
    CONSTRAINT [PK_tblHrIndProperty] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndProperty_IndId]
    ON [dbo].[tblHrIndProperty]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndProperty';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndProperty';

