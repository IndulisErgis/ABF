CREATE TABLE [dbo].[tblHrIndStatus] (
    [ID]                  BIGINT         NOT NULL,
    [IndId]               [dbo].[pEmpID] NOT NULL,
    [StartDate]           DATETIME       NOT NULL,
    [IndStatusTypeCodeID] BIGINT         NOT NULL,
    [LeavePlanID]         BIGINT         NULL,
    [GroupCode]           TINYINT        NULL,
    [CF]                  XML            NULL,
    [ts]                  ROWVERSION     NULL,
    CONSTRAINT [PK_tblHrIndStatus] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndStatus_IndId]
    ON [dbo].[tblHrIndStatus]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndStatus';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndStatus';

