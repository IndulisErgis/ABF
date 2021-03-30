CREATE TABLE [dbo].[tblHrIndTest] (
    [ID]                  BIGINT         NOT NULL,
    [IndId]               [dbo].[pEmpID] NOT NULL,
    [TestTypeID]          BIGINT         NOT NULL,
    [DateAcquired]        DATETIME       NULL,
    [Score]               NVARCHAR (10)  NULL,
    [RecertificationDate] DATETIME       NULL,
    [CF]                  XML            NULL,
    [ts]                  ROWVERSION     NULL,
    CONSTRAINT [PK_tblHrIndTest] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndTest_IndId]
    ON [dbo].[tblHrIndTest]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndTest';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndTest';

