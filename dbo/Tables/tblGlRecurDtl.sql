CREATE TABLE [dbo].[tblGlRecurDtl] (
    [GroupId]    VARCHAR (10)     NOT NULL,
    [LineNum]    REAL             DEFAULT ((0)) NOT NULL,
    [AcctNum]    [dbo].[pGlAcct]  NOT NULL,
    [Desc]       VARCHAR (30)     NULL,
    [DebitAmt]   [dbo].[pCurrDec] DEFAULT ((0)) NULL,
    [CreditAmt]  [dbo].[pCurrDec] DEFAULT ((0)) NULL,
    [Alloc]      BIT              DEFAULT ((0)) NULL,
    [SourceCode] VARCHAR (2)      DEFAULT ('RE') NULL,
    [Reference]  VARCHAR (15)     NULL,
    [CF]         XML              NULL,
    [ts]         ROWVERSION       NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlRecurDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlRecurDtl';

