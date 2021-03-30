CREATE TABLE [dbo].[tblPsFeature] (
    [ID]           BIGINT               NOT NULL,
    [ReplaceID]    BIGINT               NULL,
    [Description]  [dbo].[pDescription] NULL,
    [Order]        SMALLINT             CONSTRAINT [DF_tblPsFeature_Order] DEFAULT ((0)) NOT NULL,
    [HideYn]       BIT                  CONSTRAINT [DF_tblPsFeature_HideYn] DEFAULT ((0)) NOT NULL,
    [Param]        NVARCHAR (255)       NULL,
    [PluginName]   NVARCHAR (255)       NULL,
    [AssemblyName] NVARCHAR (255)       NULL,
    [ts]           ROWVERSION           NULL,
    CONSTRAINT [PK_tblPsFeature] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsFeature';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsFeature';

