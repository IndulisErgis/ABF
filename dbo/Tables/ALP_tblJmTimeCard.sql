CREATE TABLE [dbo].[ALP_tblJmTimeCard] (
    [TimeCardID]           INT            IDENTITY (1, 1) NOT NULL,
    [TechID]               INT            NOT NULL,
    [StartDate]            DATETIME       NOT NULL,
    [EndDate]              DATETIME       NULL,
    [StartTime]            INT            NOT NULL,
    [EndTime]              INT            NOT NULL,
    [TimeCodeID]           INT            NOT NULL,
    [SvcJobYN]             BIT            CONSTRAINT [DF_tblJmTimeCard_SvcJobYN] DEFAULT ((1)) NULL,
    [TicketId]             INT            CONSTRAINT [DF_tblJmTimeCard_TicketId] DEFAULT ((0)) NULL,
    [BillableHrs]          [dbo].[pDec]   CONSTRAINT [DF_tblJmTimeCard_BillableHrs] DEFAULT (0) NULL,
    [PayBasedOn]           TINYINT        CONSTRAINT [DF_tblJmTimeCard_PayBasedOn] DEFAULT (0) NULL,
    [Points]               FLOAT (53)     CONSTRAINT [DF_tblJmTimeCard_Points] DEFAULT (0) NULL,
    [PworkRate]            FLOAT (53)     CONSTRAINT [DF_tblJmTimeCard_PworkRate] DEFAULT (0) NULL,
    [LaborCostRate]        FLOAT (53)     CONSTRAINT [DF_tblJmTimeCard_LaborCostRate] DEFAULT (0) NULL,
    [ts]                   ROWVERSION     NULL,
    [ModifiedBy]           VARCHAR (50)   NULL,
    [ModifiedDate]         DATETIME       NULL,
    [LockedYN]             BIT            CONSTRAINT [DF_tblJmTimeCard_LockedYN] DEFAULT ((0)) NULL,
    [TimeCardComment]      NVARCHAR (500) NULL,
    [SpecializedLaborType] VARCHAR (24)   NULL,
    CONSTRAINT [PK_tblJmTimeCard] PRIMARY KEY CLUSTERED ([TimeCardID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblJmTimeCard]
    ON [dbo].[ALP_tblJmTimeCard]([TicketId] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmTimeCard] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmTimeCard] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmTimeCard] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmTimeCard] TO PUBLIC
    AS [dbo];

