--This script is used to enable order returns for better retail

IF NOT EXISTS (SELECT * FROM [dbo].[CONFIG] WHERE [Key] = 'IsOrderReturnsEnabled')
BEGIN
  INSERT [dbo].[CONFIG] ([Key], [Value], [IsSystem], [Config_Guid]) VALUES (N'IsOrderReturnsEnabled', N'True', 1, N'5D885034-E45B-4623-83CA-6B2F9A718F19')
END

IF NOT EXISTS (SELECT * FROM [dbo].[CONFIG] WHERE [Key] = 'IsOrderReturnsVisible')
BEGIN
  INSERT [dbo].[CONFIG] ([Key], [Value], [IsSystem], [Config_Guid]) VALUES (N'IsOrderReturnsVisible', N'True', 1, N'0E815CD3-FA0D-4AE9-80C3-2DED33A50D4C')
END