CREATE TABLE [dbo].[Alp_tblJmSvcTktTOAWorkNote] (
    [TicketId]             INT             NOT NULL,
    [StartTime]            DATETIME        NULL,
    [EndTime]              DATETIME        NULL,
    [ArrivalVoltage]       VARCHAR (255)   NULL,
    [WorkCompleted]        VARCHAR (8000)  NULL,
    [SignalsSent]          BIT             NULL,
    [ResolutionCode]       INT             NULL,
    [ResolutionCode2]      INT             NULL,
    [AfterVoltage]         VARCHAR (255)   NULL,
    [PreventativeMeasures] VARCHAR (8000)  NULL,
    [Notes]                VARCHAR (8000)  NULL,
    [ABFOnlyNotes]         VARCHAR (8000)  NULL,
    [ArrivalVoltageZone]   VARCHAR (255)   NULL,
    [AfterVoltageZone]     VARCHAR (255)   NULL,
    [WorkHours]            NUMERIC (10, 2) NULL,
    [BillableHours]        NUMERIC (10, 2) NULL,
    [causeCodeId]          INT             NULL,
    [causeCodeDescription] VARCHAR (8000)  NULL,
    [SpecializedLaborType] VARCHAR (24)    NULL,
    [TicketItemId]         INT             NULL,
    CONSTRAINT [PK_Alp_tblJmSvcTktWorkNote] PRIMARY KEY CLUSTERED ([TicketId] ASC) WITH (FILLFACTOR = 80)
);

