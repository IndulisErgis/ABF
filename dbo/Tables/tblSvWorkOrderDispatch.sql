CREATE TABLE [dbo].[tblSvWorkOrderDispatch] (
    [ID]                   BIGINT               NOT NULL,
    [WorkOrderID]          BIGINT               NOT NULL,
    [DispatchNo]           INT                  NOT NULL,
    [Description]          [dbo].[pDescription] NULL,
    [Status]               TINYINT              NOT NULL,
    [EquipmentID]          BIGINT               NULL,
    [EquipmentDescription] [dbo].[pDescription] NULL,
    [BillingType]          NVARCHAR (10)        NULL,
    [BillToID]             [dbo].[pCustID]      NULL,
    [RequestedDate]        DATETIME             NULL,
    [RequestedAMPM]        TINYINT              DEFAULT ((0)) NOT NULL,
    [RequestedTechID]      [dbo].[pEmpID]       NULL,
    [CancelledYN]          BIT                  DEFAULT ((0)) NOT NULL,
    [HoldYN]               BIT                  DEFAULT ((0)) NOT NULL,
    [EstTravel]            BIGINT               DEFAULT ((0)) NOT NULL,
    [SchedApproved]        BIT                  DEFAULT ((0)) NOT NULL,
    [EntryDate]            DATETIME             NOT NULL,
    [Counter]              INT                  NULL,
    [LocID]                [dbo].[pLocID]       NULL,
    [SourceId]             UNIQUEIDENTIFIER     NULL,
    [PostRun]              [dbo].[pPostRun]     NULL,
    [CF]                   XML                  NULL,
    [ts]                   ROWVERSION           NULL,
    [Priority]             TINYINT              CONSTRAINT [DF_tblSvWorkOrderDispatch_Priority] DEFAULT ((0)) NOT NULL,
    [StatusID]             TINYINT              NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWorkOrderDispatch';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWorkOrderDispatch';

