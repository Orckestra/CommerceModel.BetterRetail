
IF NOT EXISTS (SELECT * FROM [dbo].[TEMPLATEVARIABLE] WHERE [Name] = 'OrderReturnCenterContactPhoneNumber' AND [ScopeName] = 'Global')
BEGIN

	DECLARE @ContactPhoneNumberTemplateID UNIQUEIDENTIFIER
	SET @ContactPhoneNumberTemplateID = NEWID()
	INSERT [dbo].[TEMPLATEVARIABLE] ([TemplateVariable_Id], [Name], [ScopeName], [Description], [Created], [CreatedBy], [LastModified], [LastModifiedBy]) VALUES (@ContactPhoneNumberTemplateID, N'OrderReturnCenterContactPhoneNumber', N'Global', N'Order Return Center Contact Phone Number', GETUTCDATE(), GETUTCDATE(), GETUTCDATE(), NULL)

	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (@ContactPhoneNumberTemplateID, N'en-ca', N'11111111')
	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (@ContactPhoneNumberTemplateID, N'en-us', N'11111111')
	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (@ContactPhoneNumberTemplateID, N'fr-ca', N'11111111')
END

IF NOT EXISTS (SELECT * FROM [dbo].[TEMPLATEVARIABLE] WHERE [Name] = 'OrderReturnCenterContactEmail' AND [ScopeName] = 'Global')
BEGIN

	DECLARE @ContactEmailTemplateID UNIQUEIDENTIFIER
	SET @ContactEmailTemplateID = NEWID()

	DECLARE @TemplateLocalizeValue AS VARCHAR(100)='example@email.com'

	INSERT [dbo].[TEMPLATEVARIABLE] ([TemplateVariable_Id], [Name], [ScopeName], [Description], [Created], [CreatedBy], [LastModified], [LastModifiedBy]) VALUES (@ContactEmailTemplateID, N'OrderReturnCenterContactEmail', N'Global', N'Order Return Center Contact Email', GETUTCDATE(), GETUTCDATE(), GETUTCDATE(), NULL)

	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (@ContactEmailTemplateID, N'en-ca', @TemplateLocalizeValue)
	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (@ContactEmailTemplateID, N'en-us', @TemplateLocalizeValue)
	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (@ContactEmailTemplateID, N'fr-ca', @TemplateLocalizeValue)
END