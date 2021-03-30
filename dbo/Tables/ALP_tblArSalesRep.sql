CREATE TABLE [dbo].[ALP_tblArSalesRep] (
    [AlpSalesRepID]  [dbo].[pSalesRep] NOT NULL,
    [AlpPager]       VARCHAR (15)      NULL,
    [AlpMobile]      VARCHAR (15)      NULL,
    [AlpBranchID]    INT               NULL,
    [AlpDivisionID]  INT               NULL,
    [AlpInactiveYn]  BIT               NULL,
    [AlpPctNewParts] DECIMAL (20, 10)  NULL,
    [AlpPctNewLabor] DECIMAL (20, 10)  NULL,
    [AlpPctNewOther] DECIMAL (20, 10)  NULL,
    [AlpPctNewDisc]  DECIMAL (20, 10)  NULL,
    [AlpPctOthParts] DECIMAL (20, 10)  NULL,
    [AlpPctOthLabor] DECIMAL (20, 10)  NULL,
    [AlpPctOthOther] DECIMAL (20, 10)  NULL,
    [AlpPctOthDisc]  DECIMAL (20, 10)  NULL,
    [AlpMultipleRmr] DECIMAL (20, 10)  NULL,
    [AlpAdjPercent]  DECIMAL (20, 10)  NULL,
    [AlpCosOffset]   VARCHAR (40)      NULL,
    [Alpts]          ROWVERSION        NULL,
    [Supervisor]     VARCHAR (30)      NULL,
    [SalesRoleId]    VARCHAR (10)      NULL,
    CONSTRAINT [PK_ALP_tblArSalesRep] PRIMARY KEY CLUSTERED ([AlpSalesRepID] ASC)
);

