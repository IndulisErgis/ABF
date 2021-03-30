CREATE TABLE [dbo].[tblSvTechnicianRelation] (
    [ID]         INT            IDENTITY (1, 1) NOT NULL,
    [TechID]     [dbo].[pEmpID] NOT NULL,
    [RelationID] [dbo].[pEmpID] NOT NULL,
    [CF]         XML            NULL,
    [ts]         ROWVERSION     NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvTechnicianRelation';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvTechnicianRelation';

