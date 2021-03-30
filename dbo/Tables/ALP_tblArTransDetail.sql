CREATE TABLE [dbo].[ALP_tblArTransDetail] (
    [AlpTransID]      [dbo].[pTransID] NOT NULL,
    [AlpEntryNum]     INT              NOT NULL,
    [AlpUseRecBillYn] BIT              NULL,
    [AlpFromDate]     DATETIME         NULL,
    [AlpThruDate]     DATETIME         NULL,
    [AlpDeferYn]      BIT              NULL,
    [AlpAlarmID]      VARCHAR (50)     NULL,
    [AlpSiteID]       INT              NULL,
    [AlpRmrItemYn]    BIT              NULL,
    [Alpts]           ROWVERSION       NULL,
    CONSTRAINT [PK_ALP_tblArTransDetail] PRIMARY KEY CLUSTERED ([AlpTransID] ASC, [AlpEntryNum] ASC)
);

