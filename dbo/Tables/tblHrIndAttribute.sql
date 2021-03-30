CREATE TABLE [dbo].[tblHrIndAttribute] (
    [ID]                       BIGINT           NOT NULL,
    [IndId]                    [dbo].[pEmpID]   NOT NULL,
    [AttributeGroupTypeCodeID] BIGINT           NOT NULL,
    [AttributeGroupDetailID]   BIGINT           NOT NULL,
    [AttributeDate]            DATETIME         NOT NULL,
    [Amount1]                  [dbo].[pDecimal] NULL,
    [Amount2]                  [dbo].[pDecimal] NULL,
    [Note]                     NVARCHAR (MAX)   NULL,
    [CF]                       XML              NULL,
    [ts]                       ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrIndAttribute] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblHrIndAttribute_IndId]
    ON [dbo].[tblHrIndAttribute]([IndId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndAttribute';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndAttribute';

