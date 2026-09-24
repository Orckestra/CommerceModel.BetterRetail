--This script is used to set FutureItemEligiblePaymentTypes

IF NOT EXISTS (SELECT * FROM [dbo].[CONFIG] WHERE [Key] = 'FutureItemEligiblePaymentTypes')
BEGIN
  INSERT [dbo].[CONFIG] ([Key], [Value], [IsSystem], [Config_Guid]) VALUES (N'FutureItemEligiblePaymentTypes', N'[{"fulfillmentMethodType":"Shipping","eligiblePaymentMethodTypes":["SavedCreditCard"]},{"fulfillmentMethodType":"PickUp","eligiblePaymentMethodTypes":["SavedCreditCard","Cash"]}]', 1, N'2E95BDEA-72D3-43E3-9A3D-630B1C302287')
END
ELSE BEGIN
  UPDATE [dbo].[CONFIG] SET [Value] = '[{"fulfillmentMethodType":"Shipping","eligiblePaymentMethodTypes":["SavedCreditCard"]},{"fulfillmentMethodType":"PickUp","eligiblePaymentMethodTypes":["SavedCreditCard","Cash"]}]' WHERE [Key] = 'FutureItemEligiblePaymentTypes' --([Key], [Value], [IsSystem], [Config_Guid]) VALUES (N'IsOrderReturnsVisible', N'True', 1, N'0E815CD3-FA0D-4AE9-80C3-2DED33A50D4C')
END