CREATE TABLE [dbo].[tblPsUserPermission] (
    [ID]        BIGINT            NOT NULL,
    [UserID]    BIGINT            NOT NULL,
    [HostID]    [dbo].[pWrkStnID] NULL,
    [FeatureID] BIGINT            NULL,
    [CF]        XML               NULL,
    [ts]        ROWVERSION        NULL,
    CONSTRAINT [PK_tblPsUserPermission] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPsUserPermission_UserIDHostIDFeatureID]
    ON [dbo].[tblPsUserPermission]([UserID] ASC, [HostID] ASC, [FeatureID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsUserPermission';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsUserPermission';

