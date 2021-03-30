CREATE TABLE [dbo].[tblWmPhysCount] (
    [ID]         BIGINT            IDENTITY (1, 1) NOT NULL,
    [DtlSeqNum]  INT               NULL,
    [SeqNum]     INT               NULL,
    [BatchId]    [dbo].[pBatchID]  NOT NULL,
    [ItemId]     [dbo].[pItemID]   NOT NULL,
    [LocId]      [dbo].[pLocID]    NOT NULL,
    [LotNum]     [dbo].[pLotNum]   NULL,
    [SerNum]     [dbo].[pSerNum]   NULL,
    [ExtLocAId]  NVARCHAR (10)     NULL,
    [ExtLocBId]  NVARCHAR (10)     NULL,
    [QtyCounted] [dbo].[pDec]      NULL,
    [CountedUom] [dbo].[pUom]      NULL,
    [Status]     TINYINT           CONSTRAINT [DF_tblWmPhysCount_Status] DEFAULT ((0)) NOT NULL,
    [UID]        [dbo].[pUserID]   NULL,
    [HostId]     [dbo].[pWrkStnID] NULL,
    [CF]         XML               NULL,
    [ts]         ROWVERSION        NULL,
    CONSTRAINT [PK_tblWmPhysCount] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmPhysCount';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmPhysCount';

