CREATE TABLE [dbo].[Alp_tblJmSvcTktTOAWorkTotal] (
    [TicketId]              INT             NOT NULL,
    [PartsCosts]            MONEY           NULL,
    [PartTaxRate]           NUMERIC (10, 5) NULL,
    [TaxAmount]             MONEY           NULL,
    [TotalPartsCost]        MONEY           NULL,
    [LaborHours]            NUMERIC (10, 5) NULL,
    [TotalLaborCost]        MONEY           NULL,
    [ServiceTicketCost]     MONEY           NULL,
    [ServiceCostToCustomer] MONEY           NULL,
    [RepairPlan]            INT             NULL,
    [RepairPlan2]           INT             NULL,
    [PaymentType]           INT             NULL,
    [CustomerPrintedName]   VARCHAR (255)   NULL,
    [DeclinedEmailTicket]   BIT             NULL,
    [Signature]             INT             NULL,
    CONSTRAINT [PK_Alp_tblJmSvcTktWorkTotal] PRIMARY KEY CLUSTERED ([TicketId] ASC) WITH (FILLFACTOR = 80)
);

