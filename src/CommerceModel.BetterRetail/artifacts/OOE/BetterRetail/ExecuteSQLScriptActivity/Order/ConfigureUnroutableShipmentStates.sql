--This script is used to configure unroutable shipment states

IF NOT EXISTS (SELECT * FROM [dbo].[CONFIG] WHERE [Key] = 'UnroutableShipmentStates')
BEGIN
  INSERT [dbo].[CONFIG] ([Key], [Value], [IsSystem], [Config_Guid]) VALUES (N'UnroutableShipmentStates', N'Abandoned|Canceled|UnableToRoute', 1, N'73FFAF8D-0DC3-4BAE-9F31-EA0954D81709')
END