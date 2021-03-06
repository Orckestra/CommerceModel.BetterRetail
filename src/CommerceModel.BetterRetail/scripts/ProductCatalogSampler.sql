/****** 
This script will effectively remove all the products that do not fall within the first X of each category. 
The current set value is 40. 
After installing a complete dataset execute this to bring it down to a more manageable size for DEV/TEST.
  ******/

CREATE Table #ProductsPerCategoryToKeep
(
	ProductInternalId int not null,
	ProductName nvarchar(128) not null,
	ParentCategoryId int not null,
	VariantId int null
);
GO
CREATE Table #EnsureProducts
(
	ProductName nvarchar(128) not null
);
GO
INSERT INTO #EnsureProducts VALUES ('3637085'),('3637085'),('43918'),('43798'),('36858'),('2933193'),('3510605'),('2287321')
,('3658802'),('3511991'),('3817505'),('2938655'),('2766007'),('3511983'),('2287321'),('37999'),('36881'),('53659'),('36911'),('36912'),('37999'),
('44637'),('44639'),('46235'),('53639'),('40914'),('40915'),('36575'),('53659'),('39800'),('39742'),('39740'),('39741'),('39800')
GO
DECLARE @ProductsNumberToKeepPerCategory int;
SET @ProductsNumberToKeepPerCategory=40;
--Select a page size of data per category
WITH ProductsPerCategoryToKeep(ProductInternalId,ProductName,ParentCategoryId,VariantId)
AS
(	 
		SELECT prod.ProductInternalId,prod.ProductName,prod.ParentCategoryId,variant.Item_Id as VariantId FROM 
		(SELECT a.ProductInternalId,a.ProductName,a.ParentCategoryId,a.r FROM 
			(SELECT  i.Item_Id as ProductInternalId, i.ItemName as ProductName,a.[ParentItem_Id] as ParentCategoryId,r=ROW_NUMBER() OVER (partition by a.[ParentItem_Id] ORDER BY i.ItemName)
				FROM [scope].[GLOBAL_ITEM_ASSOCIATION] a 
				INNER JOIN [scope].[GLOBAL_ITEM] i on i.Item_Id=a.Item_Id
				WHERE i.ItemDiscriminator='PRODUCT' )a	
			WHERE r<=40 OR ProductName IN (SELECT ProductName FROM #EnsureProducts)) prod
		LEFT OUTER JOIN [scope].[GLOBAL_ITEM] variant
		ON prod.ProductInternalId=variant.ParentItem_Id
)
INSERT INTO #ProductsPerCategoryToKeep
SELECT ProductInternalId,ProductName,ParentCategoryId,VariantId FROM ProductsPerCategoryToKeep ORDER BY ParentCategoryId
GO
DECLARE @samplingQuery nvarchar(max);
SET @samplingQuery=N'
DELETE FROM [scope].[[[SCOPE]]_ITEM_PRICELIST]
WHERE Item_Id NOT IN (
SELECT DISTINCT VariantId FROM #ProductsPerCategoryToKeep WHERE VariantId IS NOT NULL
UNION 
SELECT DISTINCT ProductInternalId FROM #ProductsPerCategoryToKeep
)
--DELETE VARIANT VALUES

DELETE FROM [scope].[[[SCOPE]]_VARIANTVALUE_LOCALIZE]
WHERE Variant_Id NOT IN (SELECT DISTINCT VariantId FROM #ProductsPerCategoryToKeep WHERE VariantId IS NOT NULL)

DELETE FROM [scope].[[[SCOPE]]_VARIANTVALUE]
WHERE Variant_Id NOT IN (SELECT DISTINCT VariantId FROM #ProductsPerCategoryToKeep WHERE VariantId IS NOT NULL)

--DELETE PRODUCT VALUES
DELETE FROM [scope].[[[SCOPE]]_PRODUCTVALUE_LOCALIZE]
WHERE  Product_Id NOT IN (SELECT DISTINCT ProductInternalId FROM #ProductsPerCategoryToKeep)

DELETE FROM [scope].[[[SCOPE]]_PRODUCTVALUE]
WHERE Product_Id NOT IN (SELECT DISTINCT ProductInternalId FROM #ProductsPerCategoryToKeep)

--DELETE PRODUCT Associations that do not belong to products we don''t want to keep or a category
DELETE FROM [scope].[[[SCOPE]]_ITEM_ASSOCIATION]
WHERE Item_Id NOT IN (SELECT DISTINCT ProductInternalId FROM #ProductsPerCategoryToKeep) 
AND Item_Id NOT IN (SELECT Item_Id FROM [scope].[[[SCOPE]]_ITEM] WHERE ItemDiscriminator=''CATEGORY'')

--DELETE VARIANTS AND PRODUCTS

DELETE FROM [scope].[[[SCOPE]]_ITEM]
WHERE Item_Id 
NOT IN (SELECT DISTINCT VariantId FROM #ProductsPerCategoryToKeep WHERE VariantId IS NOT NULL
		UNION 
		SELECT DISTINCT ProductInternalId FROM #ProductsPerCategoryToKeep) 
AND (ItemDiscriminator=''VARIANT'' OR ItemDiscriminator=''PRODUCT'')

--Activate all remaining products
UPDATE [scope].[[[SCOPE]]_ITEM]
SET IsActive = 1 WHERE IsActive=0
'

DECLARE @statement nvarchar(max);
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','Global')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','Australia')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','BetterRetailBritishColombia')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','BetterRetailCalifornia')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','BetterRetailCanada')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','BetterRetailFlorida')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','BetterRetailHawaii')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','BetterRetailOntario')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','BetterRetailQuebec')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','BetterRetailUSA')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','Canada')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','France')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','Ontario')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','Quebec')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','USA')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','Yukon')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','BetterRetailNorway')
EXEC sp_executesql @statement;
SET @statement=REPLACE(@samplingQuery,'[[Scope]]','BetterRetailNetherlands')
EXEC sp_executesql @statement;
GO
DROP TABLE #ProductsPerCategoryToKeep;
DROP TABLE #EnsureProducts;

