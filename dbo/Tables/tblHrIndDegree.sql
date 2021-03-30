CREATE TABLE [dbo].[tblHrIndDegree] (
    [ID]               BIGINT         NOT NULL,
    [IndId]            [dbo].[pEmpID] NOT NULL,
    [DegreeTypeCodeID] BIGINT         NOT NULL,
    [DateAcquired]     DATETIME       NULL,
    [Notes]            NVARCHAR (MAX) NULL,
    [CF]               XML            NULL,
    [ts]               ROWVERSION     NULL,
    CONSTRAINT [PK_tblHrIndDegree] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndDegree_IndId]
    ON [dbo].[tblHrIndDegree]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndDegree';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndDegree';

