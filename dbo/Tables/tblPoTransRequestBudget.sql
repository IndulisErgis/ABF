CREATE TABLE [dbo].[tblPoTransRequestBudget] (
    [TransID]       [dbo].[pTransID] NOT NULL,
    [GLAcct]        [dbo].[pGlAcct]  NOT NULL,
    [BudgetBalance] [dbo].[pDec]     DEFAULT ((0)) NULL,
    [OrderBalance]  [dbo].[pDec]     DEFAULT ((0)) NULL,
    [PendingReq]    [dbo].[pDec]     DEFAULT ((0)) NULL,
    [CF]            XML              NULL,
    CONSTRAINT [PK_tblPoTransRequestBudget] PRIMARY KEY CLUSTERED ([TransID] ASC, [GLAcct] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransRequestBudget';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransRequestBudget';

