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
				AND Object_ID = Object_ID(N'dbo.ORDER'))
BEGIN
	ALTER TABLE dbo.[ORDER] ADD <AttributeName> <COLUMN TYPE> NULL;
END
GO

-- COLUMN TYPES
-- Boolean => BIT
-- Datetime => DATETIME2(3)
-- Text => NVARCHAR(<MaxValue>)
-- Lookup => NVARCHAR(MAX)
-- Decimal => DECIMAL(19,5)
-- Integer => INT

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
			'Order'
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



-- EXAMPLES

-- BOOLEAN ATTRIBUTE

IF NOT EXISTS(SELECT 1 
				FROM sys.columns
				WHERE Name = N'CustomBooleanAtt'
				AND Object_ID = Object_ID(N'dbo.ORDER'))
BEGIN
		ALTER TABLE dbo.[ORDER] ADD CustomBooleanAtt BIT NULL;
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE
				WHERE Entity_Attribute_Guid='fab5214b-4684-4ab1-93c2-010858155b57')
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
			'Order'
			,'CustomBooleanAtt'
			,0
			,'Boolean'
			,'False'
			,'Default'
			,'My boolean attribute'
			,null
			,null
			,'0'
			,'1'
			,0
			,0
			,null
			,1
			,0
			,'fab5214b-4684-4ab1-93c2-010858155b57'
			,1
		)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='fab5214b-4684-4ab1-93c2-010858155b57'
				  AND CultureIso='en-US')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'fab5214b-4684-4ab1-93c2-010858155b57'
					,'en-US'
					,'Custom Boolean Att'
				)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='fab5214b-4684-4ab1-93c2-010858155b57'
				  AND CultureIso='fr-CA')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'fab5214b-4684-4ab1-93c2-010858155b57'
					,'fr-CA'
					,'Att booléen custom'
				)
END

-- TEXT ATTRIBUTE

IF NOT EXISTS(SELECT 1 
				FROM sys.columns
				WHERE Name = N'CustomTextAtt'
				AND Object_ID = Object_ID(N'dbo.ORDER'))
BEGIN
	ALTER TABLE dbo.[ORDER] ADD CustomTextAtt NVARCHAR(32) NULL;
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE
				WHERE Entity_Attribute_Guid='92be239e-fcac-45ac-accf-5d84dcda2b7b')
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
			'Order'
			,'CustomTextAtt'
			,0
			,'Text'
			,null
			,'Default'
			,'My text attribute'
			,0
			,32
			,'0'
			,'1'
			,0
			,0
			,null
			,1
			,0
			,'92be239e-fcac-45ac-accf-5d84dcda2b7b'
			,1
		)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='92be239e-fcac-45ac-accf-5d84dcda2b7b'
				  AND CultureIso='en-US')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'92be239e-fcac-45ac-accf-5d84dcda2b7b'
					,'en-US'
					,'Custom text Att'
				)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='92be239e-fcac-45ac-accf-5d84dcda2b7b'
				  AND CultureIso='fr-CA')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'92be239e-fcac-45ac-accf-5d84dcda2b7b'
					,'fr-CA'
					,'Att texte custom'
				)
END

-- LOOKUP ATTRIBUTE

IF NOT EXISTS(SELECT 1 
				FROM sys.columns
				WHERE Name = N'CustomLookupAtt'
				AND Object_ID = Object_ID(N'dbo.ORDER'))
BEGIN
	ALTER TABLE dbo.[ORDER] ADD CustomLookupAtt NVARCHAR(MAX) NULL;
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE
				WHERE Entity_Attribute_Guid='95c95e9f-124c-4338-a82a-64e4f7969159')
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
			'Order'
			,'CustomLookupAtt'
			,0
			,'Lookup'
			,null
			,'Default'
			,'My lookup attribute'
			,null
			,null
			,'0'
			,'1'
			,0
			,0
			,'ValidationsFulfillment'
			,1
			,0
			,'95c95e9f-124c-4338-a82a-64e4f7969159'
			,1
		)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='95c95e9f-124c-4338-a82a-64e4f7969159'
				  AND CultureIso='en-US')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'95c95e9f-124c-4338-a82a-64e4f7969159'
					,'en-US'
					,'Custom lookup Att'
				)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='95c95e9f-124c-4338-a82a-64e4f7969159'
				  AND CultureIso='fr-CA')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'95c95e9f-124c-4338-a82a-64e4f7969159'
					,'fr-CA'
					,'Att lookup custom'
				)
END

-- LOOKUP ATTRIBUTE WITH MULTIPLE VALUES

IF NOT EXISTS(SELECT 1 
				FROM sys.columns
				WHERE Name = N'CustomMultLookupAtt'
				AND Object_ID = Object_ID(N'dbo.ORDER'))
BEGIN
	ALTER TABLE dbo.[ORDER] ADD CustomMultLookupAtt NVARCHAR(MAX) NULL;
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE
				WHERE Entity_Attribute_Guid='5f68b52b-ec0c-424a-8106-4bcb8811b3f8')
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
			'Order'
			,'CustomMultLookupAtt'
			,0
			,'Lookup'
			,null
			,'Default'
			,'My multiple lookup attribute'
			,null
			,null
			,'0'
			,'*'
			,0
			,0
			,'ValidationsFulfillment'
			,1
			,0
			,'5f68b52b-ec0c-424a-8106-4bcb8811b3f8'
			,2
		)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='5f68b52b-ec0c-424a-8106-4bcb8811b3f8'
				  AND CultureIso='en-US')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'5f68b52b-ec0c-424a-8106-4bcb8811b3f8'
					,'en-US'
					,'Custom multi lookup Att'
				)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='5f68b52b-ec0c-424a-8106-4bcb8811b3f8'
				  AND CultureIso='fr-CA')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'5f68b52b-ec0c-424a-8106-4bcb8811b3f8'
					,'fr-CA'
					,'Att lookup multiple custom'
				)
END

-- DECIMAL ATTRIBUTE

IF NOT EXISTS(SELECT 1 
				FROM sys.columns
				WHERE Name = N'CustomDecimalAtt'
				AND Object_ID = Object_ID(N'dbo.ORDER'))
BEGIN
	ALTER TABLE dbo.[ORDER] ADD CustomDecimalAtt DECIMAL(19,5) NULL;
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE
				WHERE Entity_Attribute_Guid='c230eb37-0ec3-4487-a27b-1c80dc0bae82')
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
			'Order'
			,'CustomDecimalAtt'
			,0
			,'Decimal'
			,null
			,'Default'
			,'My decimal attribute'
			,null
			,null
			,'0'
			,'1'
			,0
			,0
			,null
			,1
			,0
			,'c230eb37-0ec3-4487-a27b-1c80dc0bae82'
			,1
		)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='c230eb37-0ec3-4487-a27b-1c80dc0bae82'
				  AND CultureIso='en-US')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'c230eb37-0ec3-4487-a27b-1c80dc0bae82'
					,'en-US'
					,'Custom decimal Att'
				)
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE_LOCALIZE
				WHERE Entity_Attribute_Guid='c230eb37-0ec3-4487-a27b-1c80dc0bae82'
				  AND CultureIso='fr-CA')
BEGIN
	INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
					[Entity_Attribute_Guid]
					,[CultureIso]
					,[DisplayName]
				) VALUES (
					'c230eb37-0ec3-4487-a27b-1c80dc0bae82'
					,'fr-CA'
					,'Att décimal custom'
				)
END

-- INTEGER ATTRIBUTE

IF NOT EXISTS(SELECT 1 
				FROM sys.columns
				WHERE Name = N'CustomIntegerAtt'
				AND Object_ID = Object_ID(N'dbo.ORDER'))
BEGIN
	ALTER TABLE dbo.[ORDER] ADD CustomIntegerAtt INT NULL;
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE
				WHERE Entity_Attribute_Guid='996a161d-7326-496e-b280-213365df68e4')
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
			'Order'
			,'CustomIntegerAtt'
			,0
			,'Integer'
			,null
			,'Default'
			,'My integer attribute'
			,null
			,null
			,'0'
			,'1'
			,0
			,0
			,null
			,1
			,0
			,'996a161d-7326-496e-b280-213365df68e4'
			,1
		)
END

-- DATETIME ATTRIBUTE

IF NOT EXISTS(SELECT 1 
				FROM sys.columns
				WHERE Name = N'CustomDatetimeAtt'
				AND Object_ID = Object_ID(N'dbo.ORDER'))
BEGIN
	ALTER TABLE dbo.[ORDER] ADD CustomDatetimeAtt DATETIME2(3) NULL;
END

IF NOT EXISTS(SELECT 1
				FROM dbo.ENTITY_ATTRIBUTE
				WHERE Entity_Attribute_Guid='9e003f71-e55e-4d46-901b-bbc17ba1a969')
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
			'Order'
			,'CustomDatetimeAtt'
			,0
			,'Datetime'
			,null
			,'Default'
			,'My datetime attribute'
			,null
			,null
			,'0'
			,'1'
			,0
			,0
			,null
			,1
			,0
			,'9e003f71-e55e-4d46-901b-bbc17ba1a969'
			,1
		)
END