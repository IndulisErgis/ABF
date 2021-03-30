CREATE TABLE [dbo].[tblInMatReqHeader] (
    [TransId]     INT             IDENTITY (1, 1) NOT NULL,
    [ReqType]     SMALLINT        CONSTRAINT [DF__tblInMatR__ReqTy__3DACFC9F] DEFAULT (1) NULL,
    [ReqNum]      VARCHAR (10)    NULL,
    [DatePlaced]  DATETIME        CONSTRAINT [DF__tblInMatR__DateP__3EA120D8] DEFAULT (getdate()) NULL,
    [DateShipped] DATETIME        CONSTRAINT [DF__tblInMatR__DateS__3F954511] DEFAULT (getdate()) NULL,
    [DateNeeded]  DATETIME        CONSTRAINT [DF__tblInMatR__DateN__4089694A] DEFAULT (getdate()) NULL,
    [SumYear]     SMALLINT        CONSTRAINT [DF__tblInMatR__SumYe__417D8D83] DEFAULT (0) NULL,
    [SumPeriod]   SMALLINT        CONSTRAINT [DF__tblInMatR__SumPe__4271B1BC] DEFAULT (0) NULL,
    [GLPeriod]    SMALLINT        CONSTRAINT [DF__tblInMatR__GLPer__4365D5F5] DEFAULT (0) NULL,
    [LocID]       [dbo].[pLocID]  NULL,
    [ShipToId]    [dbo].[pCustID] NULL,
    [ShipVia]     VARCHAR (20)    NULL,
    [ReqstdBy]    VARCHAR (25)    NULL,
    [ReqTotal]    [dbo].[pDec]    CONSTRAINT [DF__tblInMatR__ReqTo__4459FA2E] DEFAULT (0) NULL,
    [Notes]       TEXT            NULL,
    [CF]          XML             NULL,
    [ts]          ROWVERSION      NULL,
    CONSTRAINT [PK__tblInMatReqHeade__278EDA44] PRIMARY KEY CLUSTERED ([TransId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInMatReqHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInMatReqHeader';

