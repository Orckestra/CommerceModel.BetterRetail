/*

MAIN CUSTOM ATTRIBUTE STORED PROCEDURES

*/

CREATE PROCEDURE #AddCustomGroup
	@GroupName nvarchar(128)
	,@Description nvarchar(256)
	,@SequenceNumber int
	,@Group_Guid uniqueidentifier
AS
	if NOT EXISTS(SELECT 1 FROM [dbo].[GROUP] WHERE [Group_Guid] = @Group_Guid)
	BEGIN
		INSERT INTO [dbo].[GROUP] (
			[GroupName]
			,[IsSystem]
			,[Description]
			,[SequenceNumber]
			,[Group_Guid]
		) VALUES (
			@GroupName
			,0
			,@Description
			,@SequenceNumber
			,@Group_Guid
		)
	END
GO

CREATE PROCEDURE #AddCustomAttributeLocalizedDisplayName
	@Entity_Attribute_Guid uniqueidentifier
	,@CultureIso varchar(16)
	,@DisplayName nvarchar(128)
AS
	IF NOT EXISTS(SELECT 1 FROM [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] WHERE Entity_Attribute_Guid = @Entity_Attribute_Guid AND CultureIso = @CultureIso)
	BEGIN
		INSERT INTO [dbo].[ENTITY_ATTRIBUTE_LOCALIZE] (
			Entity_Attribute_Guid
			,CultureIso
			,DisplayName
		) VALUES (
			@Entity_Attribute_Guid
			,@CultureIso
			,@DisplayName
		)
	END
GO

CREATE PROCEDURE #AddCustomAttribute
	@Entity_Attribute_Guid	uniqueidentifier
	,@AttributeName nvarchar(64)
	,@DataType varchar(16)
	,@DefaultValue nvarchar(128)
	,@GroupName nvarchar(128)
	,@Description nvarchar(256)
	,@MinValue nvarchar(32)
	,@MaxValue nvarchar(32)
	,@IsMultilingual bit
	,@IsSearchable bit
	,@ReferenceLookUpName nvarchar(64)
	,@SequenceNumber int
	,@DataTypeSequence int	
	,@Required bit
	,@AllowMultipleValues bit
AS

IF NOT EXISTS(SELECT 1               
				FROM dbo.ENTITY_ATTRIBUTE               
				WHERE Entity_Attribute_Guid=@Entity_Attribute_Guid) 
BEGIN
	DECLARE @EntityName nvarchar(64) = 'Order'
	DECLARE @FinalDataTypeSequence int = COALESCE(@DataTypeSequence,0)
	DECLARE @FinalGroupName nvarchar(128) = COALESCE(@GroupName, 'Default')

	IF (COALESCE(@DataTypeSequence,0) = 0)
	BEGIN
		SELECT @FinalDataTypeSequence = COALESCE(MAX(@DataTypeSequence),0) + 1 
		FROM dbo.ENTITY_ATTRIBUTE 
		WHERE DataType = @DataType
		  AND EntityName LIKE @EntityName
		  AND IsSystemAttribute = 0
	END

	DECLARE @MinMultiplicity VARCHAR(1) = '0'
	DECLARE @MaxMultiplicity VARCHAR(1) = '1'

	IF(COALESCE(@Required,0) = 1)
	BEGIN
		SET @MinMultiplicity = '1'
	END

	IF(COALESCE(@AllowMultipleValues,0) = 1)
	BEGIN
		SET @MaxMultiplicity = '*'
	END

	INSERT INTO dbo.ENTITY_ATTRIBUTE
		(
			EntityName
			,AttributeName
			,IsSystemAttribute
			,DataType
			,DefaultValue
			,GroupName
			,[Description]
			,MinValue
			,MaxValue
			,MinMultiplicity
			,MaxMultiplicity
			,IsMultilingual
			,IsSearchable
			,ReferenceLookUpName
			,SequenceNumber
			,IsDeleted
			,Entity_Attribute_Guid
			,DataTypeSequence
		)
	VALUES
		(
			@EntityName
			,@AttributeName
			,0
			,@DataType
			,@DefaultValue
			,@FinalGroupName
			,@Description
			,@MinValue
			,@MaxValue
			,@MinMultiplicity
			,@MaxMultiplicity
			,COALESCE(@IsMultilingual,0)
			,COALESCE(@IsSearchable,0)
			,@ReferenceLookUpName
			,@SequenceNumber
			,0
			,@Entity_Attribute_Guid
			,@FinalDataTypeSequence
		);
END
GO

/*

SPECIFIC CUSTOM ATTRIBUTE STORED PROCEDURES

*/

CREATE PROCEDURE #AddBooleanCustomAttribute
	@Entity_Attribute_Guid	uniqueidentifier
	,@AttributeName nvarchar(64)
	,@DefaultValue bit
	,@GroupName nvarchar(128)
	,@Description nvarchar(256)
	,@SequenceNumber int
	,@DataTypeSequence int
	,@Required bit
	,@AllowMultipleValues bit
AS

IF NOT EXISTS(SELECT 1           
				FROM sys.columns           
				WHERE Name = @AttributeName          
				AND Object_ID = Object_ID(N'dbo.ORDER'))
BEGIN
	DECLARE @sql NVARCHAR(255) = 'ALTER TABLE dbo.[ORDER] ADD ' +  @AttributeName + ' BIT'
	EXEC (@sql)

	DECLARE @DataType varchar(16) = 'Boolean';

	EXEC #AddCustomAttribute
		@Entity_Attribute_Guid
		,@AttributeName
		,@DataType
		,@DefaultValue
		,@GroupName
		,@Description
		,null
		,null
		,0
		,0
		,null
		,@SequenceNumber
		,@DataTypeSequence
		,@Required
		,@AllowMultipleValues
END
GO

CREATE PROCEDURE #AddTextCustomAttribute
	@Entity_Attribute_Guid	uniqueidentifier
	,@AttributeName nvarchar(64)
	,@DefaultValue nvarchar(128)
	,@GroupName nvarchar(128)
	,@Description nvarchar(256)
	,@MinValue int
	,@MaxValue int
	,@IsMultilingual bit
	,@IsSearchable bit
	,@SequenceNumber int
	,@DataTypeSequence int
	,@Required bit
	,@AllowMultipleValues bit
AS

IF NOT EXISTS(SELECT 1           
				FROM sys.columns           
				WHERE Name = @AttributeName          
				AND Object_ID = Object_ID(N'dbo.ORDER'))
BEGIN
	DECLARE @sql NVARCHAR(255) = 'ALTER TABLE dbo.[ORDER] ADD ' +  @AttributeName + ' NVARCHAR(' + CONVERT(NVARCHAR(16),@MaxValue) + ')'
	EXEC (@sql)

	DECLARE @DataType varchar(16) = 'Text';

	EXEC #AddCustomAttribute
		@Entity_Attribute_Guid
		,@AttributeName
		,@DataType
		,@DefaultValue
		,@GroupName
		,@Description
		,@MinValue
		,@MaxValue
		,@IsMultilingual
		,@IsSearchable
		,null
		,@SequenceNumber
		,@DataTypeSequence
		,@Required
		,@AllowMultipleValues
END
GO

CREATE PROCEDURE #AddLookupCustomAttribute
	@Entity_Attribute_Guid	uniqueidentifier
	,@AttributeName nvarchar(64)
	,@GroupName nvarchar(128)
	,@Description nvarchar(256)
	,@IsSearchable bit
	,@ReferenceLookUpName nvarchar(64)
	,@SequenceNumber int
	,@DataTypeSequence int
	,@Required bit
	,@AllowMultipleValues bit
AS

IF NOT EXISTS(SELECT 1           
				FROM sys.columns           
				WHERE Name = @AttributeName          
				AND Object_ID = Object_ID(N'dbo.ORDER'))
BEGIN
	DECLARE @sql NVARCHAR(255) = 'ALTER TABLE dbo.[ORDER] ADD ' +  @AttributeName + ' NVARCHAR(max)'
	EXEC (@sql)

	DECLARE @DataType varchar(16) = 'Lookup';

	EXEC #AddCustomAttribute
		@Entity_Attribute_Guid
		,@AttributeName
		,@DataType
		,null
		,@GroupName
		,@Description
		,null
		,null
		,0
		,@IsSearchable
		,@ReferenceLookUpName
		,@SequenceNumber
		,@DataTypeSequence
		,@Required
		,@AllowMultipleValues
END
GO

CREATE PROCEDURE #AddDecimalCustomAttribute
	@Entity_Attribute_Guid	uniqueidentifier
	,@AttributeName nvarchar(64)
	,@DefaultValue decimal(19,5)
	,@GroupName nvarchar(128)
	,@Description nvarchar(256)
	,@IsSearchable bit
	,@SequenceNumber int
	,@DataTypeSequence int
	,@Required bit
	,@AllowMultipleValues bit
AS

IF NOT EXISTS(SELECT 1           
				FROM sys.columns           
				WHERE Name = @AttributeName          
				AND Object_ID = Object_ID(N'dbo.ORDER'))
BEGIN
	DECLARE @sql NVARCHAR(255) = 'ALTER TABLE dbo.[ORDER] ADD ' +  @AttributeName + ' DECIMAL(19,5)'
	EXEC (@sql)

	DECLARE @DataType varchar(16) = 'Decimal';

	EXEC #AddCustomAttribute
		@Entity_Attribute_Guid
		,@AttributeName
		,@DataType
		,@DefaultValue
		,@GroupName
		,@Description
		,null
		,null
		,null
		,@IsSearchable
		,null
		,@SequenceNumber
		,@DataTypeSequence
		,@Required
		,@AllowMultipleValues
END
GO

CREATE PROCEDURE #AddIntegerCustomAttribute
	@Entity_Attribute_Guid	uniqueidentifier
	,@AttributeName nvarchar(64)
	,@DefaultValue int
	,@GroupName nvarchar(128)
	,@Description nvarchar(256)
	,@IsSearchable bit
	,@SequenceNumber int
	,@DataTypeSequence int
	,@Required bit
	,@AllowMultipleValues bit
AS

IF NOT EXISTS(SELECT 1           
				FROM sys.columns           
				WHERE Name = @AttributeName          
				AND Object_ID = Object_ID(N'dbo.ORDER'))
BEGIN
	DECLARE @sql NVARCHAR(255) = 'ALTER TABLE dbo.[ORDER] ADD ' +  @AttributeName + ' int'
	EXEC (@sql)

	DECLARE @DataType varchar(16) = 'Integer';

	EXEC #AddCustomAttribute
		@Entity_Attribute_Guid
		,@AttributeName
		,@DataType
		,@DefaultValue
		,@GroupName
		,@Description
		,null
		,null
		,null
		,@IsSearchable
		,null
		,@SequenceNumber
		,@DataTypeSequence
		,@Required
		,@AllowMultipleValues
END
GO

CREATE PROCEDURE #AddDatetimeCustomAttribute
	@Entity_Attribute_Guid	uniqueidentifier
	,@AttributeName nvarchar(64)
	,@DefaultValue datetime2(3)
	,@GroupName nvarchar(128)
	,@Description nvarchar(256)
	,@IsSearchable bit
	,@SequenceNumber int
	,@DataTypeSequence int
	,@Required bit
	,@AllowMultipleValues bit
AS

IF NOT EXISTS(SELECT 1           
				FROM sys.columns           
				WHERE Name = @AttributeName          
				AND Object_ID = Object_ID(N'dbo.ORDER'))
BEGIN
	DECLARE @sql NVARCHAR(255) = 'ALTER TABLE dbo.[ORDER] ADD ' +  @AttributeName + ' datetime2(3)'
	EXEC (@sql)

	DECLARE @DataType varchar(16) = 'Datetime';
	
	EXEC #AddCustomAttribute
		@Entity_Attribute_Guid
		,@AttributeName
		,@DataType
		,@DefaultValue
		,@GroupName
		,@Description
		,null
		,null
		,null
		,@IsSearchable
		,null
		,@SequenceNumber
		,@DataTypeSequence
		,@Required
		,@AllowMultipleValues
END
GO

/*

USAGE PROCESS
1) Create Groups
2) For each attribute
2.1) Create custom attribute
2.2) Create localized display name

*/


/*

CUSTOM ATTRIBUTE ADDING
These are for test purpose and example usage.

*/

DECLARE @DatetimeCustomAttributeId uniqueidentifier = CONVERT(uniqueidentifier,'5c9c9cd2-67c2-4e33-89a2-9c5103e44634')
EXEC #AddDatetimeCustomAttribute
	@DatetimeCustomAttributeId
	,'SP_CustomDatetime'
	,'11-05-2021'
	,null
	,null
	,0
	,1
	,0
	,0
	,0

DECLARE @IntegerCustomAttributeId uniqueidentifier = CONVERT(uniqueidentifier,'0c56aeb7-53c9-49ce-af67-a5b1bf1d53ab')
EXEC #AddIntegerCustomAttribute
	@IntegerCustomAttributeId
	,'SP_CustomInteger'
	,1
	,'Default'
	,'Integer description'
	,0
	,1
	,0
	,0
	,0

DECLARE @DecimalCustomAttributeId uniqueidentifier = CONVERT(uniqueidentifier,'94bb9d2e-d2e9-4639-90ef-0da4a8d97ee0')
EXEC #AddDecimalCustomAttribute
	@DecimalCustomAttributeId
	,'SP_CustomDecimal'
	,null
	,null
	,null
	,null
	,null
	,null
	,null
	,null

DECLARE @LookupCustomAttributeId uniqueidentifier = CONVERT(uniqueidentifier,'724fb91d-90ac-44b9-b9bb-551a86d224ec')
EXEC #AddLookupCustomAttribute
	@LookupCustomAttributeId
	,'SP_CustomLookup'
	,null
	,null
	,0
	,'ValidationsFulfillment'
	,0
	,null
	,0
	,0

DECLARE @LookupMultiCustomAttributeId uniqueidentifier = CONVERT(uniqueidentifier,'07d62b41-83e7-4b29-aea4-20b800ebee7a')
EXEC #AddLookupCustomAttribute
	@LookupMultiCustomAttributeId
	,'SP_CustomLookupMulti'
	,null
	,null
	,0
	,'ValidationsFulfillment'
	,0
	,null
	,0
	,1

DECLARE @TextCustomAttributeId uniqueidentifier = CONVERT(uniqueidentifier,'c658c127-3e0a-4159-a36b-0bd82c866148')
EXEC #AddTextCustomAttribute
	@TextCustomAttributeId
	,'SP_CustomText'
	,'MyCustomtext'
	,null
	,null
	,null
	,128
	,1
	,1
	,1
	,0
	,0
	,0

DECLARE @BooleanCustomAttributeId uniqueidentifier = CONVERT(uniqueidentifier,'8dec6f8b-269c-4433-aad3-76dac0c95887')
EXEC #AddBooleanCustomAttribute
	@BooleanCustomAttributeId
	,'SP_CustomBoolean'
	,0
	,null
	,null
	,0
	,null
	,0
	,0

GO

/*

CLEAN STORED PROCEDURES
Leave at the end of the script.
*/

DROP PROCEDURE #AddBooleanCustomAttribute
DROP PROCEDURE #AddTextCustomAttribute
DROP PROCEDURE #AddLookupCustomAttribute
DROP PROCEDURE #AddDecimalCustomAttribute
DROP PROCEDURE #AddIntegerCustomAttribute
DROP PROCEDURE #AddDatetimeCustomAttribute
DROP PROCEDURE #AddCustomAttribute
DROP PROCEDURE #AddCustomAttributeLocalizedDisplayName
DROP PROCEDURE #AddCustomGroup