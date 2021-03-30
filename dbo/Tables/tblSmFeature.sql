CREATE TABLE [dbo].[tblSmFeature] (
    [ID]           BIGINT           NOT NULL,
    [FunctionId]   UNIQUEIDENTIFIER NOT NULL,
    [ReplaceID]    BIGINT           NULL,
    [Description]  NVARCHAR (255)   NULL,
    [Order]        SMALLINT         CONSTRAINT [DF_tblSmFeature_Order] DEFAULT ((0)) NOT NULL,
    [HideYn]       BIT              CONSTRAINT [DF_tblSmFeature_HideYn] DEFAULT ((0)) NOT NULL,
    [Param]        NVARCHAR (255)   NULL,
    [PluginName]   NVARCHAR (255)   NULL,
    [AssemblyName] NVARCHAR (255)   NULL,
    [ts]           ROWVERSION       NULL,
    CONSTRAINT [PK_tblSmFeature] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmFeature';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmFeature';

