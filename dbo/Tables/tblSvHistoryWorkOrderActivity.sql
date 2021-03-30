CREATE TABLE [dbo].[tblSvHistoryWorkOrderActivity] (
    [ID]                INT                  IDENTITY (1, 1) NOT NULL,
    [DispatchID]        BIGINT               NOT NULL,
    [WorkOrderID]       BIGINT               NOT NULL,
    [ActivityType]      TINYINT              NOT NULL,
    [ActivityDateTime]  DATETIME             NULL,
    [TechID]            [dbo].[pEmpID]       NULL,
    [Duration]          BIGINT               NOT NULL,
    [EntryDate]         DATETIME             NOT NULL,
    [EnteredBy]         [dbo].[pUserID]      NOT NULL,
    [Notes]             NVARCHAR (MAX)       NULL,
    [CF]                XML                  NULL,
    [StatusDescription] [dbo].[pDescription] NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvHistoryWorkOrderActivity';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvHistoryWorkOrderActivity';

