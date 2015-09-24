ALTER TABLE Index_Taxon_Name 
	ADD ACTUAL_NAME_ATTRIBUTE VARCHAR(65) NULL
ALTER TABLE Index_Taxon_Name 
	ADD COMMON_NAME_ATTRIBUTE VARCHAR(65) NULL
ALTER TABLE Index_Taxon_Name 
	ADD PREFERRED_NAME_ATTRIBUTE VARCHAR(65) NULL
ALTER TABLE Index_Taxon_Name 
	ADD PREFERRED_NAME_AUTHORITY VARCHAR(80) NULL

GO

-- Correctly set the list_font_italic flag
UPDATE Taxon_Rank SET List_Font_Italic=
	CASE WHEN Sequence >= (SELECT MIN(Sequence) FROM Taxon_Rank WHERE Long_Name LIKE 'Species%') THEN 1 ELSE 0 END
 
UPDATE ITN 
SET ACTUAL_NAME_ATTRIBUTE=TV.Attribute, ACTUAL_NAME_ITALIC=CASE WHEN TR.LIST_FONT_ITALIC=1 AND T.LANGUAGE='la' THEN 1 ELSE 0 END
FROM INDEX_TAXON_NAME ITN
INNER JOIN Taxon_List_Item TLI ON TLI.Taxon_List_Item_Key=ITN.Taxon_List_Item_Key
INNER JOIN Taxon_Version TV ON TV.Taxon_Version_Key=TLI.Taxon_Version_Key
INNER JOIN Taxon T ON T.TAXON_KEY=TV.Taxon_Key
INNER JOIN Taxon_Rank TR ON TR.TAXON_RANK_KEY=TLI.TAXON_RANK_KEY


UPDATE ITN 
SET COMMON_NAME_ATTRIBUTE=TV.Attribute
FROM INDEX_TAXON_NAME ITN
INNER JOIN Taxon_Common_Name AS TCN ON TCN.Taxon_List_Item_Key = ITN.Taxon_List_Item_Key
INNER JOIN Taxon_Version TV ON TV.Taxon_Version_Key=TCN.Taxon_Version_Key

UPDATE ITN 
SET PREFERRED_NAME_ATTRIBUTE=TV.Attribute, PREFERRED_NAME_AUTHORITY=T.AUTHORITY, 
    PREFERRED_NAME_ITALIC=CASE WHEN TR.LIST_FONT_ITALIC=1 AND T.LANGUAGE='la' THEN 1 ELSE 0 END
FROM INDEX_TAXON_NAME ITN
INNER JOIN Taxon_List_Item TLI ON TLI.Taxon_List_Item_Key=ITN.Taxon_List_Item_Key
INNER JOIN Taxon_List_Item TL2 ON TLI.Taxon_List_Item_Key=TLI.Preferred_Name
INNER JOIN Taxon_Version TV ON TV.Taxon_Version_Key=TLI.Taxon_Version_Key
INNER JOIN Taxon T ON T.TAXON_KEY=TV.TAXON_KEY
INNER JOIN Taxon_Rank TR ON TR.TAXON_RANK_KEY=TLI.TAXON_RANK_KEY


