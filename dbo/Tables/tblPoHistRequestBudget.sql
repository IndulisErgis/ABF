CREATE TABLE [dbo].[tblPoHistRequestBudget] (
    [PostRun]       [dbo].[pPostRun] NOT NULL,
    [TransID]       [dbo].[pTransID] NOT NULL,
    [GLAcct]        [dbo].[pGlAcct]  NOT NULL,
    [BudgetBalance] [dbo].[pDec]     DEFAULT ((0)) NULL,
    [OrderBalance]  [dbo].[pDec]     DEFAULT ((0)) NULL,
    [PendingReq]    [dbo].[pDec]     DEFAULT ((0)) NULL,
    [CF]            XML              NULL,
    CONSTRAINT [PK_tblPoHistRequestBudget] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransID] ASC, [GLAcct] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistRequestBudget';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistRequestBudget';

