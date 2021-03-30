CREATE TABLE [dbo].[tblHrIndOverrideFactors] (
    [IndId]            [dbo].[pEmpID]   NOT NULL,
    [WithholdId]       BIGINT           NOT NULL,
    [Code]             [dbo].[pCode]    NOT NULL,
    [EmployerPaid]     BIT              NOT NULL,
    [OverrideFactor1]  [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor1] DEFAULT ((0)) NOT NULL,
    [OverrideFactor2]  [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor2] DEFAULT ((0)) NOT NULL,
    [OverrideFactor3]  [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor3] DEFAULT ((0)) NOT NULL,
    [OverrideFactor4]  [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor4] DEFAULT ((0)) NOT NULL,
    [OverrideFactor5]  [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor5] DEFAULT ((0)) NOT NULL,
    [OverrideFactor6]  [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor6] DEFAULT ((0)) NOT NULL,
    [OverrideFactor7]  [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor7] DEFAULT ((0)) NOT NULL,
    [OverrideFactor8]  [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor8] DEFAULT ((0)) NOT NULL,
    [OverrideFactor9]  [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor9] DEFAULT ((0)) NOT NULL,
    [OverrideFactor10] [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor10] DEFAULT ((0)) NOT NULL,
    [OverrideFactor11] [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor11] DEFAULT ((0)) NOT NULL,
    [OverrideFactor12] [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor12] DEFAULT ((0)) NOT NULL,
    [OverrideFactor13] [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor13] DEFAULT ((0)) NOT NULL,
    [OverrideFactor14] [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor14] DEFAULT ((0)) NOT NULL,
    [OverrideFactor15] [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor15] DEFAULT ((0)) NOT NULL,
    [OverrideFactor16] [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor16] DEFAULT ((0)) NOT NULL,
    [OverrideFactor17] [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor17] DEFAULT ((0)) NOT NULL,
    [OverrideFactor18] [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor18] DEFAULT ((0)) NOT NULL,
    [OverrideFactor19] [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor19] DEFAULT ((0)) NOT NULL,
    [OverrideFactor20] [dbo].[pDecimal] CONSTRAINT [DF_tblHrIndOverrideFactors_OverrideFactor20] DEFAULT ((0)) NOT NULL,
    [CF]               XML              NULL,
    [ts]               ROWVERSION       NULL,
    CONSTRAINT [PK_tblHrIndOverrideFactors] PRIMARY KEY CLUSTERED ([IndId] ASC, [WithholdId] ASC, [Code] ASC, [EmployerPaid] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndOverrideFactors';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrIndOverrideFactors';

