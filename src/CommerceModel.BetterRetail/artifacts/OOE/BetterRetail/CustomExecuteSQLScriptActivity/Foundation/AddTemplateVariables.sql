
IF NOT EXISTS (SELECT * FROM [dbo].[TEMPLATEVARIABLE] WHERE [Name] = 'OrderReturnCenterContactPhoneNumber' AND [ScopeName] = 'Global')
BEGIN

	INSERT [dbo].[TEMPLATEVARIABLE] ([TemplateVariable_Id], [Name], [ScopeName], [Description], [Created], [CreatedBy], [LastModified], [LastModifiedBy]) VALUES (N'822a10ff-c4bc-4bad-8f30-268b0f5e65f7', N'OrderReturnCenterContactPhoneNumber', N'Global', N'Order Return Center Contact Phone Number', GETUTCDATE(), GETUTCDATE(), GETUTCDATE(), NULL)

	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (N'822a10ff-c4bc-4bad-8f30-268b0f5e65f7', N'en-ca', N'11111111')
	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (N'822a10ff-c4bc-4bad-8f30-268b0f5e65f7', N'en-us', N'11111111')
	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (N'822a10ff-c4bc-4bad-8f30-268b0f5e65f7', N'fr-ca', N'11111111')
END

IF NOT EXISTS (SELECT * FROM [dbo].[TEMPLATEVARIABLE] WHERE [Name] = 'OrderReturnCenterContactEmail' AND [ScopeName] = 'Global')
BEGIN

	INSERT [dbo].[TEMPLATEVARIABLE] ([TemplateVariable_Id], [Name], [ScopeName], [Description], [Created], [CreatedBy], [LastModified], [LastModifiedBy]) VALUES (N'667077d9-45e1-47f7-9f12-67a135c40adf', N'OrderReturnCenterContactEmail', N'Global', N'Order Return Center Contact Email', GETUTCDATE(), GETUTCDATE(), GETUTCDATE(), NULL)

	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (N'667077d9-45e1-47f7-9f12-67a135c40adf', N'en-ca', 'example@@email.com')
	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (N'667077d9-45e1-47f7-9f12-67a135c40adf', N'en-us', 'example@@email.com')
	INSERT [dbo].[TEMPLATEVARIABLE_LOCALIZE] ([TemplateVariable_Id], [CultureIso], [Value]) VALUES (N'667077d9-45e1-47f7-9f12-67a135c40adf', N'fr-ca', 'example@@email.com')
END