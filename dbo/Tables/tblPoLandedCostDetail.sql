CREATE TABLE [dbo].[tblPoLandedCostDetail] (
    [LandedCostID]  VARCHAR (10)    NOT NULL,
    [LCDtlSeqNum]   INT             IDENTITY (1, 1) NOT NULL,
    [Description]   VARCHAR (35)    NULL,
    [CostType]      TINYINT         NOT NULL,
    [Amount]        [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [Level]         TINYINT         NOT NULL,
    [GlAcctExpense] [dbo].[pGlAcct] NULL,
    [CF]            XML             NULL,
    CONSTRAINT [PK_tblPoLandedCostDetail] PRIMARY KEY CLUSTERED ([LCDtlSeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoLandedCostDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoLandedCostDetail';

