CREATE TABLE [dbo].[ALP_tblArHistDetail] (
    [AlpPostRun]   [dbo].[pPostRun] NOT NULL,
    [AlpTransID]   [dbo].[pTransID] NOT NULL,
    [AlpEntryNum]  INT              NOT NULL,
    [AlpAlarmID]   VARCHAR (50)     NULL,
    [AlpSiteID]    INT              NULL,
    [AlpRmrItemYn] BIT              NULL,
    [Alpts]        ROWVERSION       NULL,
    CONSTRAINT [PK_ALP_tblArHistDetail] PRIMARY KEY CLUSTERED ([AlpPostRun] ASC, [AlpTransID] ASC, [AlpEntryNum] ASC)
);

