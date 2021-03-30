CREATE TABLE [dbo].[tblCmContactGroupDtl] (
    [ID]              BIGINT     NOT NULL,
    [ContactGroupID]  BIGINT     NOT NULL,
    [Type]            TINYINT    NOT NULL,
    [ContactID]       BIGINT     NOT NULL,
    [ContactMethodID] BIGINT     NOT NULL,
    [SelectYn]        BIT        CONSTRAINT [DF_tblCmContactGroupDtl_SelectYn] DEFAULT ((1)) NOT NULL,
    [CF]              XML        NULL,
    [ts]              ROWVERSION NULL,
    CONSTRAINT [PK_tblCmContactGroupDtl] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmContactGroupDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmContactGroupDtl';

