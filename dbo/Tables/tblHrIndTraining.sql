CREATE TABLE [dbo].[tblHrIndTraining] (
    [ID]             BIGINT               NOT NULL,
    [IndId]          [dbo].[pEmpID]       NOT NULL,
    [TrainingCodeID] BIGINT               NOT NULL,
    [DateAcquired]   DATETIME             NOT NULL,
    [TrainingTypeID] BIGINT               NULL,
    [Hours]          [dbo].[pDecimal]     CONSTRAINT [DF_tblHrIndTraining_Hours] DEFAULT ((0)) NOT NULL,
    [Score]          NVARCHAR (20)        NULL,
    [EventCost]      [dbo].[pCurrDecimal] CONSTRAINT [DF_tblHrIndTraining_EventCost] DEFAULT ((0)) NOT NULL,
    [TravelCost]     [dbo].[pCurrDecimal] CONSTRAINT [DF_tblHrIndTraining_TravelCost] DEFAULT ((0)) NOT NULL,
    [Approver]       NVARCHAR (35)        NULL,
    [DeptId]         [dbo].[pDeptID]      NULL,
    [Notes]          NVARCHAR (MAX)       NULL,
    [CF]             XML                  NULL,
    [ts]             ROWVERSION           NULL,
    CONSTRAINT [PK_tblHrIndTraining] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndTraining_IndId]
    ON [dbo].[tblHrIndTraining]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndTraining';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndTraining';

