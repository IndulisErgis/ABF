﻿CREATE TABLE [dbo].[tblCfCategory] (
    [CategoryId]    NVARCHAR (10)        NOT NULL,
    [CategoryDescr] [dbo].[pDescription] NULL,
    [CF]            XML                  NULL,
    [ts]            ROWVERSION           NULL,
    CONSTRAINT [PK_tblCfCategory] PRIMARY KEY CLUSTERED ([CategoryId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfCategory';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfCategory';

