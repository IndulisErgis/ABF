CREATE TYPE [dbo].[pSalesRep]
    FROM VARCHAR (3) NULL;


GO
GRANT REFERENCES
    ON TYPE::[dbo].[pSalesRep] TO PUBLIC;

