-- Please refer to https://help.azureedge.net/notes/Content/Release_Notes/4.5/Release_notes_4_5.htm 
-- in section NEW ADMINISTRATION SETTINGS for more information

declare @@key varchar(255)
declare @@value varchar(255)
declare @@configGuid uniqueidentifier

begin
set @@key = 'MaxNumberOfVariantAttributes'
set @@value = '50'
set @@configGuid = '34431C31-1801-4E01-BA7F-4A98E3B0DDF8'
if not exists (select 1 from CONFIG where [Key] = @@key)
    INSERT INTO CONFIG ([Key], [Value], [IsSystem], [Config_Guid]) VALUES (@@key, @@value, 1, @@configGuid)
else if exists (select 1 from CONFIG where [Key] = @@key and NOT([Value] = '' or [Value] is null))
    update CONFIG set [Value] = @@value where [Key] = @@key
end

begin
set @@key = 'MaxNumberOfProductAttributes'
set @@value = '50'
set @@configGuid = '78040FEA-7B83-4289-9FED-34B6DC1D3858'
if not exists (select 1 from CONFIG where [Key] = @@key)
    INSERT INTO CONFIG ([Key], [Value], [IsSystem], [Config_Guid]) VALUES (@@key, @@value, 1, @@configGuid)
else if exists (select 1 from CONFIG where [Key] = @@key and NOT([Value] = '' or [Value] is null))
    update CONFIG set [Value] = @@value where [Key] = @@key
end

BEGIN
SET @@key = 'MaxNumberOfMediaItems'
SET @@value = '100'
SET @@configGuid = 'FEF52F82-E0EF-4FFE-BD35-690C12C62F46'
IF NOT EXISTS (SELECT 1 FROM CONFIG WHERE [Key] = @@key)
    INSERT INTO CONFIG ([Key], [Value], [IsSystem], [Config_Guid]) VALUES (@@key, @@value, 1, @@configGuid)
ELSE IF EXISTS (SELECT 1 FROM CONFIG WHERE [Key] = @@key AND NOT([Value] = '' OR [Value] IS NULL))
    UPDATE CONFIG SET [Value] = @@value WHERE [Key] = @@key
END