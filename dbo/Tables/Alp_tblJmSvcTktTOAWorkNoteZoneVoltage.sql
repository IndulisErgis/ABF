CREATE TABLE [dbo].[Alp_tblJmSvcTktTOAWorkNoteZoneVoltage] (
    [TicketId]       INT           NOT NULL,
    [Zone]           VARCHAR (255) NOT NULL,
    [ArrivalVoltage] VARCHAR (255) NULL,
    [AfterVoltage]   VARCHAR (255) NULL,
    CONSTRAINT [PK_Alp_tblJmSvcTktTOAWorkNoteZoneVoltage] PRIMARY KEY CLUSTERED ([TicketId] ASC, [Zone] ASC)
);

