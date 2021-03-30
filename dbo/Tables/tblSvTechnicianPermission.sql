CREATE TABLE [dbo].[tblSvTechnicianPermission] (
    [ID]        BIGINT     NOT NULL,
    [TechID]    BIGINT     NOT NULL,
    [FeatureID] BIGINT     NULL,
    [CF]        XML        NULL,
    [ts]        ROWVERSION NULL,
    CONSTRAINT [PK_tblSvTechnicianPermission] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSvTechnicianPermission_TechIDFeatureID]
    ON [dbo].[tblSvTechnicianPermission]([TechID] ASC, [FeatureID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvTechnicianPermission';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvTechnicianPermission';

