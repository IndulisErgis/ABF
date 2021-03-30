CREATE TABLE [dbo].[tblPsUser] (
    [ID]              BIGINT            NOT NULL,
    [UserName]        [dbo].[pUserID]   NOT NULL,
    [Password]        NVARCHAR (MAX)    NULL,
    [EmployeeID]      [dbo].[pEmpID]    NULL,
    [SalesRepID]      [dbo].[pSalesRep] NULL,
    [HostID]          [dbo].[pWrkStnID] NULL,
    [CF]              XML               NULL,
    [ts]              ROWVERSION        NULL,
    [DefaultConfigID] [dbo].[pWrkStnID] NULL,
    CONSTRAINT [PK_tblPsUser] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPsUser_UserName]
    ON [dbo].[tblPsUser]([UserName] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsUser';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsUser';

