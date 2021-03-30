CREATE TABLE [dbo].[tblHrLeavePlanDetail] (
    [ID]          BIGINT        NOT NULL,
    [LeavePlanID] BIGINT        NOT NULL,
    [LeaveCode]   [dbo].[pCode] NOT NULL,
    [CF]          XML           NULL,
    [ts]          ROWVERSION    NULL,
    CONSTRAINT [PK_tblHrLeavePlanDetail] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblHrLeavePlanDetail_LeavePlanIDLeaveCode]
    ON [dbo].[tblHrLeavePlanDetail]([LeavePlanID] ASC, [LeaveCode] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrLeavePlanDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrLeavePlanDetail';

