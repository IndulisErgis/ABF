﻿CREATE TYPE [dbo].[pDec]
    FROM DECIMAL (20, 10) NOT NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pDec] TO PUBLIC;

