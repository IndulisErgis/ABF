﻿CREATE TYPE [dbo].[pVendorID]
    FROM VARCHAR (10) NOT NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pVendorID] TO PUBLIC;
