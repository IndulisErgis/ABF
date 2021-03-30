CREATE TABLE [dbo].[tblArCustPmtMethod] (
    [SeqNum]          INT             IDENTITY (1, 1) NOT NULL,
    [CustId]          [dbo].[pCustID] NOT NULL,
    [PmtMethod]       VARCHAR (10)    NOT NULL,
    [Descr]           VARCHAR (30)    NULL,
    [CcNum]           NVARCHAR (255)  NULL,
    [CcName]          VARCHAR (30)    NULL,
    [CcExpire]        DATETIME        NULL,
    [BankName]        VARCHAR (30)    NULL,
    [BankRoutingCode] VARCHAR (9)     NULL,
    [BankAcctNum]     NVARCHAR (255)  NULL,
    [MaskValue]       VARCHAR (4)     NULL,
    [CF]              XML             NULL,
    CONSTRAINT [PK__tblArCustPmtMethod] PRIMARY KEY CLUSTERED ([SeqNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblArCustPmtMethod_CustIdPmtMethodSeqNum]
    ON [dbo].[tblArCustPmtMethod]([CustId] ASC, [PmtMethod] ASC, [SeqNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArCustPmtMethod';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArCustPmtMethod';

