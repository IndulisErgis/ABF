CREATE TABLE [dbo].[tblHrAttributeGroupDetail] (
    [ID]                       BIGINT        NOT NULL,
    [AttributeGroupTypeCodeID] BIGINT        NOT NULL,
    [Description]              NVARCHAR (50) NOT NULL,
    [CF]                       XML           NULL,
    [ts]                       ROWVERSION    NULL,
    CONSTRAINT [PK_tblHrAttributeGroupDetail] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblHrAttributeGroupDetail_AttributeGroupTypeCodeIDDescription]
    ON [dbo].[tblHrAttributeGroupDetail]([AttributeGroupTypeCodeID] ASC, [Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrAttributeGroupDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrAttributeGroupDetail';

