CREATE TABLE [dbo].[ABF_tblInCOGSAdj] (
    [SeqNum]     INT                 IDENTITY (1, 1) NOT NULL,
    [ItemId]     [dbo].[pItemID]     NULL,
    [LocId]      [dbo].[pLocID]      NULL,
    [AdjType]    TINYINT             NOT NULL,
    [AdjAmt]     [dbo].[pDec]        NOT NULL,
    [GLAcctCode] [dbo].[pGLAcctCode] NOT NULL,
    [GLYear]     SMALLINT            NOT NULL,
    [GLPeriod]   SMALLINT            NOT NULL,
    [SumPeriod]  SMALLINT            NOT NULL,
    [LinkOffset] INT                 NULL,
    [PostedYn]   BIT                 NOT NULL
);

