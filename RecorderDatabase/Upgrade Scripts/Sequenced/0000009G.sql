ALTER TABLE Index_Taxon_Name 
	ADD CAN_EXPAND BIT NULL

GO

ALTER TABLE [dbo].[INDEX_TAXON_NAME] ADD  CONSTRAINT [DF_INDEX_TAXON_NAME_CAN_EXPAND]  DEFAULT ((1)) FOR [CAN_EXPAND]


/****** Object:  StoredProcedure [dbo].[usp_Populate_Can_Expand]  Script Date: 05/10/2014 03:00:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
  DESCRIPTION
  This procedure populates Can_Expand in Index_Taxon_Name 

*/

CREATE PROCEDURE [dbo].[usp_Populate_Can_Expand] 

AS


Update Index_Taxon_Name
set Can_Expand = 0
FROM Index_Taxon_Name INNER JOIN
Taxon_List_Item TLI
ON TLI.TAXON_LIST_ITEM_KEY = Index_Taxon_Name.Recommended_Taxon_List_Item_Key
INNER JOIN ORGANISM ORG ON ORG.Taxon_Version_Key = TLI.TAXON_VERSION_KEY
INNER JOIN ORGANISM ORG2 ON ORG.PARENT_KEY = ORG2.ORGANISM_KEY
WHERE ORG.REDUNDANT_FLAG is not null OR ORG2.REDUNDANT_FLAG is not null

Update Index_Taxon_Name
set Can_Expand = 0
FROM Index_Taxon_Name INNER JOIN
Taxon_List_Item TLI
ON TLI.TAXON_LIST_ITEM_KEY = Index_Taxon_Name.Recommended_Taxon_List_Item_Key
INNER JOIN ORGANISM ORG ON ORG.Taxon_Version_Key = TLI.TAXON_VERSION_KEY
INNER JOIN TAXON_RANK TR ON TR.TAXON_RANK_KEY = ORG.ORGANISM_RANK_KEY
WHERE NOT EXISTS (SELECT * FROM ORGANISM WHERE ORGANISM.PARENT_KEY = ORG.ORGANISM_KEY )
AND TR.SEQUENCE < 250 

GO

GRANT EXECUTE ON [dbo].[usp_Populate_Can_Expand] TO PUBLIC

GO

/****** Object:  StoredProcedure [dbo].[usp_IndexTaxonName_ApplyNameServer]    Script Date: 05/10/2014 02:50:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*===========================================================================*\
  Description: Applies the NameServer information to the Index_Taxon_Name
		Recommended_Taxon_List_Item_Key table.  Updates all records where this value
		is null.

  Parameters:	None

  Created:	November 2004

  Last revision information:
    $Revision: 4 $
    $Date: 1/11/13 11:35 $
    $Author: Johnvanbreda $

\*=========================================================================== */
ALTER PROCEDURE [dbo].[usp_IndexTaxonName_ApplyNameServer]
AS
/* Remove any disconnected index_taxon_name records */
DELETE ITN 
FROM Index_Taxon_Name ITN
LEFT JOIN Taxon_List_Item TLI ON TLI.Taxon_List_Item_Key=ITN.Taxon_List_Item_Key
WHERE TLI.Taxon_List_Item_Key IS NULL

UPDATE ITN
SET ITN.RECOMMENDED_TAXON_LIST_ITEM_KEY = NS.RECOMMENDED_TAXON_LIST_ITEM_KEY
FROM NAMESERVER NS
INNER JOIN TAXON_LIST_ITEM TLI ON NS.INPUT_TAXON_VERSION_KEY = TLI.TAXON_VERSION_KEY
INNER JOIN INDEX_TAXON_NAME ITN ON ITN.TAXON_LIST_ITEM_KEY = TLI.TAXON_LIST_ITEM_KEY
WHERE ITN.RECOMMENDED_TAXON_LIST_ITEM_KEY IS NULL 

UPDATE ITN
SET ITN.RECOMMENDED_TAXON_LIST_ITEM_KEY = TLI.PREFERRED_NAME
FROM TAXON_LIST TL 
INNER JOIN TAXON_LIST_VERSION TLV ON TL.TAXON_LIST_KEY = TLV.TAXON_LIST_KEY
INNER JOIN TAXON_LIST_ITEM TLI ON TLV.TAXON_LIST_VERSION_KEY = TLI.TAXON_LIST_VERSION_KEY
INNER JOIN TAXON_LIST_ITEM TLI1 ON TLI.TAXON_VERSION_KEY = TLI1.TAXON_VERSION_KEY
INNER JOIN INDEX_TAXON_NAME ITN ON TLI1.TAXON_LIST_ITEM_KEY = ITN.TAXON_LIST_ITEM_KEY
WHERE TL.PREFERRED=1 AND ITN.RECOMMENDED_TAXON_LIST_ITEM_KEY IS NULL

UPDATE ITN
SET ITN.RECOMMENDED_TAXON_LIST_ITEM_KEY = TLI.PREFERRED_NAME
FROM TAXON_VERSION TV
INNER JOIN TAXON_LIST_ITEM TLI ON TV.TAXON_VERSION_KEY = TLI.TAXON_VERSION_KEY
INNER JOIN TAXON_GROUP TG ON TV.Output_group_key = TG.TAXON_GROUP_KEY
INNER JOIN TAXON_LIST_VERSION TLV ON TLV.TAXON_LIST_KEY=TG.USE_TAXON_LIST_KEY
		AND TLI.TAXON_LIST_VERSION_KEY=TLV.TAXON_LIST_VERSION_KEY
INNER JOIN TAXON_LIST_ITEM AS TLI1 
		ON TLI.TAXON_VERSION_KEY = TLI1.TAXON_VERSION_KEY
INNER JOIN INDEX_TAXON_NAME ITN ON TLI1.TAXON_LIST_ITEM_KEY = ITN.TAXON_LIST_ITEM_KEY
WHERE ITN.RECOMMENDED_TAXON_LIST_ITEM_KEY IS NULL

UPDATE ITN
SET ITN.RECOMMENDED_TAXON_LIST_ITEM_KEY = TLI.PREFERRED_NAME
FROM INDEX_TAXON_NAME ITN
INNER JOIN TAXON_LIST_ITEM TLI ON TLI.TAXON_LIST_ITEM_KEY=ITN.TAXON_LIST_ITEM_KEY
INNER JOIN TAXON_LIST_ITEM TLI2 on TLI2.TAXON_LIST_ITEM_KEY=TLI.PREFERRED_NAME
WHERE ITN.RECOMMENDED_TAXON_LIST_ITEM_KEY IS NULL

--Now set up the recommended sort orders, which depend on the recommended names

UPDATE ITN
SET ITN.Sort_Order=
	LEFT('000', 3 - LEN(CONVERT(VARCHAR(3), ISNULL(TG.Sort_Order,0))))
  + CONVERT(VARCHAR(3), ISNULL(TG.Sort_Order,0)) 
	+ LEFT('00000000', 8 - LEN(CONVERT(VARCHAR(8), ISNULL(TLI.Sort_Code,0))))
  + CONVERT(VARCHAR(8), ISNULL(TLI.Sort_Code,0)) 
FROM Index_Taxon_Name ITN 
INNER JOIN Taxon_List_Item TLI ON TLI.Taxon_List_Item_Key=ITN.Recommended_Taxon_List_Item_Key
INNER JOIN Taxon_Version TV ON TV.Taxon_Version_Key=TLI.Taxon_Version_Key
LEFT JOIN Taxon_Group TG ON TG.Taxon_Group_Key=TV.Output_Group_Key

-- Set Can_Expand to True

Update Index_Taxon_Name set Can_Expand = 1

-- Poulate Can_Expand in ITN

EXECUTE [dbo].[usp_Populate_Can_Expand]

-- Rebuild the lineage and sort order on the Organism table

EXECUTE [dbo].[spPopulateOrganismLineage]


-- If there is anything in the Organism table and the Sort_Method not there or set to Recommended.

UPDATE Index_Taxon_Name 
  SET SORT_ORDER = ORG.SORT_ORDER
  FROM INDEX_TAXON_NAME ITN 
  INNER JOIN TAXON_LIST_ITEM TLI ON TLI.TAXON_LIST_ITEM_KEY = ITN.RECOMMENDED_TAXON_LIST_ITEM_KEY
  INNER JOIN ORGANISM ORG ON ORG.TAXON_VERSION_KEY = TLI.TAXON_VERSION_KEY
  WHERE NOT EXISTS (SELECT * FROM SETTING WHERE [NAME]  = 'SortMethod' AND [DATA] = 'Recommended')

-- If there is anything in the Organism table, then populate Index_Taxon_Hierarchy
 
EXECUTE [dbo].[usp_Populate_Index_Taxon_Hierarchy]

