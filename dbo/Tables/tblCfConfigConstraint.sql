CREATE TABLE [dbo].[tblCfConfigConstraint] (
    [ConstraintId]        BIGINT               NOT NULL,
    [ConfigId]            BIGINT               NOT NULL,
    [SeqNum]              INT                  NOT NULL,
    [ConstraintType]      TINYINT              CONSTRAINT [DF_tblCfConfigConstraint_ConstraintType] DEFAULT ((0)) NOT NULL,
    [ConstraintDescr]     [dbo].[pDescription] NULL,
    [ConstraintCondition] [dbo].[pDescription] NOT NULL,
    [ActiveFrom]          DATETIME             NULL,
    [ActiveThru]          DATETIME             NULL,
    [ConstraintAction]    NVARCHAR (255)       NULL,
    [ConstraintText]      [dbo].[pDescription] NULL,
    [ConstraintCat]       NVARCHAR (15)        NULL,
    [CF]                  XML                  NULL,
    [ts]                  ROWVERSION           NULL,
    CONSTRAINT [PK_tblCfConfigConstraint] PRIMARY KEY CLUSTERED ([ConstraintId] ASC),
    CONSTRAINT [UX_tblCfConfigConstraint_ConfigId_SeqNum] UNIQUE NONCLUSTERED ([ConfigId] ASC, [SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigConstraint';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCfConfigConstraint';

