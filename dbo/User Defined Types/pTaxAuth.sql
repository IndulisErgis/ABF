﻿CREATE TYPE [dbo].[pTaxAuth]
    FROM VARCHAR (4) NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pTaxAuth] TO PUBLIC;
