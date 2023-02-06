
IF NOT EXISTS (SELECT * FROM [dbo].[TEMPLATEVARIABLE] WHERE [Name] = 'OrderReturnCenterContactPhoneNumber' AND [ScopeName] = 'Global')
BEGIN
	INSERT [dbo].[TEMPLATEVARIABLE] ([TemplateVariable_Id], [Name], [ScopeName], [Description], [Created], [CreatedBy], [LastModified], [LastModifiedBy]) VALUES (N'c375bc49-a065-411d-bd19-04c72e0013b7', N'OrderReturnCenterContactPhoneNumber', N'Global', N'Order Return Center Contact Phone Number', GETUTCDATE(), GETUTCDATE(), GETUTCDATE(), NULL)

	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (N'c375bc49-a065-411d-bd19-04c72e0013b7', N'en-ca', N'11111111')
	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (N'c375bc49-a065-411d-bd19-04c72e0013b7', N'en-us', N'11111111')
	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (N'c375bc49-a065-411d-bd19-04c72e0013b7', N'fr-ca', N'11111111')
END

IF NOT EXISTS (SELECT * FROM [dbo].[TEMPLATEVARIABLE] WHERE [Name] = 'OrderReturnCenterContactEmail' AND [ScopeName] = 'Global')
BEGIN
	INSERT [dbo].[TEMPLATEVARIABLE] ([TemplateVariable_Id], [Name], [ScopeName], [Description], [Created], [CreatedBy], [LastModified], [LastModifiedBy]) VALUES (N'ecb5bbc7-7faa-4193-adc6-5ac81730adf8', N'OrderReturnCenterContactEmail', N'Global', N'Order Return Center Contact Email', GETUTCDATE(), GETUTCDATE(), GETUTCDATE(), NULL)

	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (N'ecb5bbc7-7faa-4193-adc6-5ac81730adf8', N'en-ca', N'example@email.com')
	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (N'ecb5bbc7-7faa-4193-adc6-5ac81730adf8', N'en-us', N'example@email.com')
	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (N'ecb5bbc7-7faa-4193-adc6-5ac81730adf8', N'fr-ca', N'example@email.com')
END