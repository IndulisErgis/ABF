CREATE TABLE [dbo].[tblSvTechnicianLaborCode] (
    [ID]         INT            IDENTITY (1, 1) NOT NULL,
    [TechID]     [dbo].[pEmpID] NOT NULL,
    [LaborCode]  NVARCHAR (10)  NOT NULL,
    [SkillLevel] TINYINT        NOT NULL,
    [CF]         XML            NULL,
    [ts]         ROWVERSION     NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvTechnicianLaborCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvTechnicianLaborCode';

