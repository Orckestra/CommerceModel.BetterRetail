/*

USAGE
1) Create Groups
2) For each attribute
2.1) Create custom attribute
2.2) Create localized display name

*/

/*

IF NOT EXISTS(SELECT 1
				FROM dbo.GROUP
				WHERE Group_Guid='<Group_Guid>')
BEGIN
	INSERT INTO [dbo].[GROUP] (
			[IsDeleted]
			,[GroupName]
			,[IsSystem]
			,[Description]
			,[SequenceNumber]
			,[Group_Guid]
		) VALUES (
			0
			,<GroupName, nvarchar(128),>
			,0
			,<Description, nvarchar(256),>
			,<SequenceNumber, int,>
			,<Group_Guid, uniqueidentifier,>
		)
END
GO

IF NOT EXISTS(SELECT 1
				FROM dbo.GROUP_LOCALIZE
				WHERE Group_Localize_Guid='<Group_Localize_Guid>')
BEGIN
	INSERT INTO [dbo].[GROUP_LOCALIZE] (
			[GroupName]
			,[CultureIso]
			,[DisplayName]
			,[Group_Localize_Guid]
		) VALUES (
			<GroupName, nvarchar(128),>
			,<CultureIso, varchar(16),>
			,<DisplayName, nvarchar(128),>
			,<Group_Localize_Guid, uniqueidentifier,>
		)
END
GO

IF NOT EXISTS(SELECT 1 
				FROM sys.columns
				WHERE Name = N'<AttributeName>'
				AND Object_ID = Object_ID(N'dbo.LINEITEM'))
BEGIN
	ALTER TABLE dbo.[LINEITEM] ADD <AttributeName> <COLUMN TYPE> NULL;
END
GO

-- COLUMN TYPES
-- boolean => BIT
-- datetime => DATETIME2(3)
-- text => NVARCHAR(<MaxValue>)
-- lookup => NVARCHAR(MAX)
-- decimal => DECIMAL(19,5)
-- integer => INT

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE
				WHERE Entity_Attribute_Guid='<Entity_Attribute_Guid>')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE] (
			[EntityName]
			,[AttributeName]
			,[IsSystemAttribute]
			,[DataType]
			,[DefaultValue]
			,[GroupName]
			,[Description]
			,[MinValue]
			,[MaxValue]
			,[MinMultiplicity]
			,[MaxMultiplicity]
			,[IsMultilingual]
			,[IsSearchable]
			,[ReferenceLookUpName]
			,[SequenceNumber]
			,[IsDeleted]
			,[Entity_Attribute_Guid]
			,[DataTypeSequence]
		) VALUES (
			'LineItem'
			,<AttributeName, nvarchar(64),>
			,0
			,<DataType, varchar(16),>
			,<DefaultValue, nvarchar(128),>
			,'Default' or group name
			,<Description, nvarchar(256),>
			,<MinValue, nvarchar(32),>
			,<MaxValue, nvarchar(32),>
			,'1' if the attribute is required, '0' otherwise
			,'*' if the attribute allow multiple values, '1' otherwise
			,1 if the attribute is localized, 0 otherwise
			,<IsSearchable, bit,>
			,<ReferenceLookUpName, nvarchar(64),>
			,<SequenceNumber, int,>
			,0
			,<Entity_Attribute_Guid, uniqueidentifier,>
			,<DataTypeSequence, int,> -- each non system custom attribute of the same type must have an incrementing number starting at 1
		)
END
GO

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='<Entity_Attribute_Guid>'
				  AND CultureIso='<CultureIso>')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					<Entity_Attribute_Guid, uniqueidentifier,>
					,<CultureIso, varchar(16),>
					,<DisplayName, nvarchar(128),>
				)
END
GO

*/

-- BOOLEAN ATTRIBUTE

IF NOT EXISTS(SELECT 1 
				FROM sys.columns
				WHERE Name = N'TestBoolean'
				AND Object_ID = Object_ID(N'dbo.LINEITEM'))
BEGIN
		ALTER TABLE dbo.[LINEITEM] ADD TestBoolean BIT NULL;
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE
				WHERE Entity_Attribute_Guid='98a2cede-389c-467e-99b2-5350d113e921')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE] (
			[EntityName]
			,[AttributeName]
			,[IsSystemAttribute]
			,[DataType]
			,[DefaultValue]
			,[GroupName]
			,[Description]
			,[MinValue]
			,[MaxValue]
			,[MinMultiplicity]
			,[MaxMultiplicity]
			,[IsMultilingual]
			,[IsSearchable]
			,[ReferenceLookUpName]
			,[SequenceNumber]
			,[IsDeleted]
			,[Entity_Attribute_Guid]
			,[DataTypeSequence]
		) VALUES (
			'LineItem'
			,'TestBoolean'
			,0
			,'Boolean'
			,'False'
			,'Test'
			,'Test boolean'
			,null
			,null
			,'0'
			,'1'
			,0
			,0
			,null
			,1
			,0
			,'98a2cede-389c-467e-99b2-5350d113e921'
			,1
		)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='98a2cede-389c-467e-99b2-5350d113e921'
				  AND CultureIso='en-US')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'98a2cede-389c-467e-99b2-5350d113e921'
					,'en-US'
					,'Test Boolean'
				)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='98a2cede-389c-467e-99b2-5350d113e921'
				  AND CultureIso='fr-CA')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'98a2cede-389c-467e-99b2-5350d113e921'
					,'fr-CA'
					,'Booléen test'
				)
END

-- TEXT ATTRIBUTE

IF NOT EXISTS(SELECT 1 
				FROM sys.columns
				WHERE Name = N'TestText'
				AND Object_ID = Object_ID(N'dbo.LINEITEM'))
BEGIN
	ALTER TABLE dbo.[LINEITEM] ADD TestText NVARCHAR(32) NULL;
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE
				WHERE Entity_Attribute_Guid='42ff767f-3398-43c6-a5d4-48a3f14a54d4')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE] (
			[EntityName]
			,[AttributeName]
			,[IsSystemAttribute]
			,[DataType]
			,[DefaultValue]
			,[GroupName]
			,[Description]
			,[MinValue]
			,[MaxValue]
			,[MinMultiplicity]
			,[MaxMultiplicity]
			,[IsMultilingual]
			,[IsSearchable]
			,[ReferenceLookUpName]
			,[SequenceNumber]
			,[IsDeleted]
			,[Entity_Attribute_Guid]
			,[DataTypeSequence]
		) VALUES (
			'LineItem'
			,'TestText'
			,0
			,'Text'
			,null
			,'Test'
			,'Test text'
			,0
			,32
			,'0'
			,'1'
			,0
			,0
			,null
			,1
			,0
			,'42ff767f-3398-43c6-a5d4-48a3f14a54d4'
			,1
		)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='42ff767f-3398-43c6-a5d4-48a3f14a54d4'
				  AND CultureIso='en-US')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'42ff767f-3398-43c6-a5d4-48a3f14a54d4'
					,'en-US'
					,'Test text'
				)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='42ff767f-3398-43c6-a5d4-48a3f14a54d4'
				  AND CultureIso='fr-CA')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'42ff767f-3398-43c6-a5d4-48a3f14a54d4'
					,'fr-CA'
					,'Texte test'
				)
END

-- LOOKUP ATTRIBUTE

IF NOT EXISTS(SELECT 1 
				FROM sys.columns
				WHERE Name = N'TestLookup'
				AND Object_ID = Object_ID(N'dbo.LINEITEM'))
BEGIN
	ALTER TABLE dbo.[LINEITEM] ADD TestLookup NVARCHAR(MAX) NULL;
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE
				WHERE Entity_Attribute_Guid='5488db52-dce0-49fb-8b4f-bd7286218f16')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE] (
			[EntityName]
			,[AttributeName]
			,[IsSystemAttribute]
			,[DataType]
			,[DefaultValue]
			,[GroupName]
			,[Description]
			,[MinValue]
			,[MaxValue]
			,[MinMultiplicity]
			,[MaxMultiplicity]
			,[IsMultilingual]
			,[IsSearchable]
			,[ReferenceLookUpName]
			,[SequenceNumber]
			,[IsDeleted]
			,[Entity_Attribute_Guid]
			,[DataTypeSequence]
		) VALUES (
			'LineItem'
			,'TestLookup'
			,0
			,'Lookup'
			,null
			,'Test'
			,'Test lookup'
			,null
			,null
			,'0'
			,'1'
			,0
			,0
			,'TestLookup'
			,1
			,0
			,'5488db52-dce0-49fb-8b4f-bd7286218f16'
			,1
		)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='5488db52-dce0-49fb-8b4f-bd7286218f16'
				  AND CultureIso='en-US')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'5488db52-dce0-49fb-8b4f-bd7286218f16'
					,'en-US'
					,'Test lookup'
				)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='5488db52-dce0-49fb-8b4f-bd7286218f16'
				  AND CultureIso='fr-CA')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'5488db52-dce0-49fb-8b4f-bd7286218f16'
					,'fr-CA'
					,'Liste test'
				)
END

-- LOOKUP ATTRIBUTE WITH MULTIPLE VALUES

IF NOT EXISTS(SELECT 1 
				FROM sys.columns
				WHERE Name = N'TestMultiLookup'
				AND Object_ID = Object_ID(N'dbo.LINEITEM'))
BEGIN
	ALTER TABLE dbo.[LINEITEM] ADD TestMultiLookup NVARCHAR(MAX) NULL;
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE
				WHERE Entity_Attribute_Guid='8a1a31cb-aaa0-43ce-9871-c98ae09735b2')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE] (
			[EntityName]
			,[AttributeName]
			,[IsSystemAttribute]
			,[DataType]
			,[DefaultValue]
			,[GroupName]
			,[Description]
			,[MinValue]
			,[MaxValue]
			,[MinMultiplicity]
			,[MaxMultiplicity]
			,[IsMultilingual]
			,[IsSearchable]
			,[ReferenceLookUpName]
			,[SequenceNumber]
			,[IsDeleted]
			,[Entity_Attribute_Guid]
			,[DataTypeSequence]
		) VALUES (
			'LineItem'
			,'TestMultiLookup'
			,0
			,'Lookup'
			,null
			,'Test'
			,'Test multi lookup'
			,null
			,null
			,'0'
			,'*'
			,0
			,0
			,'TestLookup'
			,1
			,0
			,'8a1a31cb-aaa0-43ce-9871-c98ae09735b2'
			,2
		)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='8a1a31cb-aaa0-43ce-9871-c98ae09735b2'
				  AND CultureIso='en-US')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'8a1a31cb-aaa0-43ce-9871-c98ae09735b2'
					,'en-US'
					,'Test multi lookup'
				)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='8a1a31cb-aaa0-43ce-9871-c98ae09735b2'
				  AND CultureIso='fr-CA')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'8a1a31cb-aaa0-43ce-9871-c98ae09735b2'
					,'fr-CA'
					,'Liste à sélection multiple test'
				)
END

-- DECIMAL ATTRIBUTE

IF NOT EXISTS(SELECT 1 
				FROM sys.columns
				WHERE Name = N'TestDecimal'
				AND Object_ID = Object_ID(N'dbo.LINEITEM'))
BEGIN
	ALTER TABLE dbo.[LINEITEM] ADD TestDecimal DECIMAL(19,5) NULL;
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE
				WHERE Entity_Attribute_Guid='35e62c7b-0318-42a5-bf30-56767d3874ad')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE] (
			[EntityName]
			,[AttributeName]
			,[IsSystemAttribute]
			,[DataType]
			,[DefaultValue]
			,[GroupName]
			,[Description]
			,[MinValue]
			,[MaxValue]
			,[MinMultiplicity]
			,[MaxMultiplicity]
			,[IsMultilingual]
			,[IsSearchable]
			,[ReferenceLookUpName]
			,[SequenceNumber]
			,[IsDeleted]
			,[Entity_Attribute_Guid]
			,[DataTypeSequence]
		) VALUES (
			'LineItem'
			,'TestDecimal'
			,0
			,'Decimal'
			,null
			,'Test'
			,'LineItem decimal'
			,null
			,null
			,'0'
			,'1'
			,0
			,0
			,null
			,1
			,0
			,'35e62c7b-0318-42a5-bf30-56767d3874ad'
			,1
		)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='35e62c7b-0318-42a5-bf30-56767d3874ad'
				  AND CultureIso='en-US')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'35e62c7b-0318-42a5-bf30-56767d3874ad'
					,'en-US'
					,'Test decimal'
				)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='35e62c7b-0318-42a5-bf30-56767d3874ad'
				  AND CultureIso='fr-CA')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'35e62c7b-0318-42a5-bf30-56767d3874ad'
					,'fr-CA'
					,'Décimal test'
				)
END

-- INTEGER ATTRIBUTE

IF NOT EXISTS(SELECT 1 
				FROM sys.columns
				WHERE Name = N'TestInteger'
				AND Object_ID = Object_ID(N'dbo.LINEITEM'))
BEGIN
	ALTER TABLE dbo.[LINEITEM] ADD TestInteger INT NULL;
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE
				WHERE Entity_Attribute_Guid='6c7fb2b8-2c3b-4f4c-a655-67eeb21ae7c8')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE] (
			[EntityName]
			,[AttributeName]
			,[IsSystemAttribute]
			,[DataType]
			,[DefaultValue]
			,[GroupName]
			,[Description]
			,[MinValue]
			,[MaxValue]
			,[MinMultiplicity]
			,[MaxMultiplicity]
			,[IsMultilingual]
			,[IsSearchable]
			,[ReferenceLookUpName]
			,[SequenceNumber]
			,[IsDeleted]
			,[Entity_Attribute_Guid]
			,[DataTypeSequence]
		) VALUES (
			'LineItem'
			,'TestInteger'
			,0
			,'Integer'
			,null
			,'Test'
			,'Test integer'
			,null
			,null
			,'0'
			,'1'
			,0
			,0
			,null
			,1
			,0
			,'ce5ee508-4c71-40f4-a587-99c7aa34a34e'
			,1
		)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='ce5ee508-4c71-40f4-a587-99c7aa34a34e'
				  AND CultureIso='en-US')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'ce5ee508-4c71-40f4-a587-99c7aa34a34e'
					,'en-US'
					,'Test integer'
				)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='ce5ee508-4c71-40f4-a587-99c7aa34a34e'
				  AND CultureIso='fr-CA')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'ce5ee508-4c71-40f4-a587-99c7aa34a34e'
					,'fr-CA'
					,'Entier test'
				)
END

-- DATETIME ATTRIBUTE

IF NOT EXISTS(SELECT 1 
				FROM sys.columns
				WHERE Name = N'TestDatetime'
				AND Object_ID = Object_ID(N'dbo.LINEITEM'))
BEGIN
	ALTER TABLE dbo.[LINEITEM] ADD TestDatetime DATETIME2(3) NULL;
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE
				WHERE Entity_Attribute_Guid='6c7fb2b8-2c3b-4f4c-a655-67eeb21ae7c8')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE] (
			[EntityName]
			,[AttributeName]
			,[IsSystemAttribute]
			,[DataType]
			,[DefaultValue]
			,[GroupName]
			,[Description]
			,[MinValue]
			,[MaxValue]
			,[MinMultiplicity]
			,[MaxMultiplicity]
			,[IsMultilingual]
			,[IsSearchable]
			,[ReferenceLookUpName]
			,[SequenceNumber]
			,[IsDeleted]
			,[Entity_Attribute_Guid]
			,[DataTypeSequence]
		) VALUES (
			'LineItem'
			,'TestDatetime'
			,0
			,'Datetime'
			,null
			,'Test'
			,'Test datetime'
			,null
			,null
			,'0'
			,'1'
			,0
			,0
			,null
			,1
			,0
			,'6c7fb2b8-2c3b-4f4c-a655-67eeb21ae7c8'
			,1
		)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='6c7fb2b8-2c3b-4f4c-a655-67eeb21ae7c8'
				  AND CultureIso='en-US')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'6c7fb2b8-2c3b-4f4c-a655-67eeb21ae7c8'
					,'en-US'
					,'Test datetime'
				)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='6c7fb2b8-2c3b-4f4c-a655-67eeb21ae7c8'
				  AND CultureIso='fr-CA')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'6c7fb2b8-2c3b-4f4c-a655-67eeb21ae7c8'
					,'fr-CA'
					,'Date test'
				)
END