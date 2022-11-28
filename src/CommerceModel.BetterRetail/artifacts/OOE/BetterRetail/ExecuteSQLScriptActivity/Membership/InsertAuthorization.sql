--isf-testuser-commanagement-reader@@orcdevcmpmsdn.onmicrosoft.com: c5886cf7-49cb-406d-9762-4c620ba1d851
DECLARE @@objectId AS VARCHAR(36);
SET @@objectId = 'c5886cf7-49cb-406d-9762-4c620ba1d851'

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -20 AND [ScopeId] = 'BetterRetailCanada')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-20 --OrderReader
           ,'BetterRetailCanada'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -20 AND [ScopeId] = 'BetterRetailUSA')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-20 --OrderReader
           ,'BetterRetailUSA'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -20 AND [ScopeId] = 'BetterRetailNorway')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-20 --OrderReader
           ,'BetterRetailNorway'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -20 AND [ScopeId] = 'BetterRetailEuro')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-20 --OrderReader
           ,'BetterRetailEuro'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -20 AND [ScopeId] = '*')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-20 --OrderReader
           ,'*'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -54 AND [ScopeId] = 'BetterRetailCanada')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-54 --PriceListReader
           ,'BetterRetailCanada'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -54 AND [ScopeId] = 'BetterRetailUSA')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-54 --PriceListReader
           ,'BetterRetailUSA'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -54 AND [ScopeId] = 'BetterRetailNorway')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-54 --PriceListReader
           ,'BetterRetailNorway'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -54 AND [ScopeId] = 'BetterRetailEuro')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-54 --PriceListReader
           ,'BetterRetailEuro'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -54 AND [ScopeId] = '*')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-54 --PriceListReader
           ,'*'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

--isf-testuser-picker-1@@orcdevcmpmsdn.onmicrosoft.com: b2c6c56d-3a0d-481d-b03e-6823fb9a78be
SET @@objectId = 'b2c6c56d-3a0d-481d-b03e-6823fb9a78be'

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -1001 AND [ScopeId] = 'BetterRetailCanada')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-1001 --Picker
           ,'BetterRetailCanada'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -1001 AND [ScopeId] = 'BetterRetailUSA')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-1001 --Picker
           ,'BetterRetailUSA'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -1001 AND [ScopeId] = 'BetterRetailNorway')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-1001 --Picker
           ,'BetterRetailNorway'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -1001 AND [ScopeId] = 'BetterRetailEuro')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-1001 --Picker
           ,'BetterRetailEuro'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

--isf-testuser-picker-2@@orcdevcmpmsdn.onmicrosoft.com: b2c6c56d-3a0d-481d-b03e-6823fb9a78be
SET @@objectId = '9595cdd9-1f6a-4c85-8c90-95d005a9ce3c'

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -1001 AND [ScopeId] = 'BetterRetailCanada')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-1001 --Picker
           ,'BetterRetailCanada'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -1001 AND [ScopeId] = 'BetterRetailUSA')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-1001 --Picker
           ,'BetterRetailUSA'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -1001 AND [ScopeId] = 'BetterRetailNorway')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-1001 --Picker
           ,'BetterRetailNorway'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END

IF NOT EXISTS (SELECT * FROM [dbo].[AUTHORIZATION] WHERE [ObjectId] = @@objectId AND [Role_Id] = -1001 AND [ScopeId] = 'BetterRetailEuro')
BEGIN
INSERT INTO [dbo].[AUTHORIZATION]
           ([Role_Id]
           ,[ScopeId]
           ,[ObjectId]
           ,[ObjectType]
           ,[Created]
           ,[CreatedBy])
     VALUES
           (-1001 --Picker
           ,'BetterRetailEuro'
           ,@@objectId
           ,'User'
           ,GETDATE()
           ,'ExecuteSQLScriptActivity')
END
