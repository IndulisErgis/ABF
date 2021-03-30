CREATE TABLE [dbo].[ALP_tblJmTrackingStaging_temp] (
    [TicketId]           INT           NOT NULL,
    [SiteId]             INT           NOT NULL,
    [Status]             VARCHAR (10)  NULL,
    [WorkCodeId]         INT           NULL,
    [LeadTechId]         INT           NULL,
    [FirstScheduledDate] DATETIME      NULL,
    [LastScheduledDate]  DATETIME      NULL,
    [TechID]             INT           NULL,
    [Tech]               VARCHAR (3)   NULL,
    [WorkCode]           VARCHAR (10)  NULL,
    [NewWorkYN]          BIT           NULL,
    [SiteComposite]      VARCHAR (150) NULL
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmTrackingStaging_temp] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmTrackingStaging_temp] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmTrackingStaging_temp] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmTrackingStaging_temp] TO PUBLIC
    AS [dbo];

