CREATE TABLE [dbo].[tblSvHistoryWorkOrderDispatch] (
    [ID]                   BIGINT               NOT NULL,
    [WorkOrderID]          BIGINT               NOT NULL,
    [DispatchNo]           INT                  NOT NULL,
    [Description]          [dbo].[pDescription] NULL,
    [EquipmentID]          BIGINT               NULL,
    [EquipmentDescription] [dbo].[pDescription] NULL,
    [BillingType]          NVARCHAR (10)        NULL,
    [BillableYN]           BIT                  NOT NULL,
    [BillToID]             [dbo].[pCustID]      NULL,
    [RequestedDate]        DATETIME             NULL,
    [RequestedAMPM]        TINYINT              NOT NULL,
    [RequestedTechID]      [dbo].[pEmpID]       NULL,
    [CancelledYN]          BIT                  NOT NULL,
    [EstTravel]            BIGINT               NOT NULL,
    [SchedApproved]        BIT                  NOT NULL,
    [EntryDate]            DATETIME             NOT NULL,
    [Counter]              INT                  NULL,
    [LocID]                [dbo].[pLocID]       NULL,
    [SourceId]             UNIQUEIDENTIFIER     NULL,
    [PostRun]              [dbo].[pPostRun]     NULL,
    [CF]                   XML                  NULL,
    [Priority]             TINYINT              NULL,
    [StatusID]             TINYINT              NULL,
    [StatusDescription]    [dbo].[pDescription] NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvHistoryWorkOrderDispatch';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvHistoryWorkOrderDispatch';

