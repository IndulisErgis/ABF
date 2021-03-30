CREATE TABLE [dbo].[tblHrIndRetFundAllocation] (
    [ID]           BIGINT           NOT NULL,
    [RetirementId] BIGINT           NOT NULL,
    [RetFundID]    BIGINT           NOT NULL,
    [Allocation]   [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndRetFundAllocation_Allocation] DEFAULT ((0)) NOT NULL,
    [CF]           XML              NULL,
    [ts]           ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrIndRetFundAllocation] PRIMARY KEY CLUSTERED ([ID] ASC, [RetirementId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndRetFundAllocation';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndRetFundAllocation';

