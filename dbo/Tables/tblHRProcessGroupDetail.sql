CREATE TABLE [dbo].[tblHRProcessGroupDetail] (
    [ID]                  BIGINT         NOT NULL,
    [ProcessTypeCodeID]   BIGINT         NOT NULL,
    [ChecklistTypeCodeID] BIGINT         NOT NULL,
    [Description]         NVARCHAR (50)  NOT NULL,
    [PersonResponsible]   [dbo].[pEmpID] NULL,
    [DocumentLink]        NVARCHAR (255) NULL,
    [CF]                  XML            NULL,
    [ts]                  ROWVERSION     NULL,
    CONSTRAINT [PK_tblHRProcessGroupDetail] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblHRProcessGroupDetail_ProcessTypeCodeIDDescription]
    ON [dbo].[tblHRProcessGroupDetail]([ProcessTypeCodeID] ASC, [Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHRProcessGroupDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHRProcessGroupDetail';

