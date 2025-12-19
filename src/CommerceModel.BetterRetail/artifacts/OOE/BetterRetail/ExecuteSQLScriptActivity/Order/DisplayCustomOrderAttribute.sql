UPDATE [dbo].[CONFIG]
SET Value = 'OrderNumber|ScopeName|OrderStatus|Created|FulfillmentDate|ShipmentCount|Total|CustomerName|DestinationLocation|CustomOrderChannel'
WHERE [Key] = 'DisplayedOrderAttributes'

UPDATE [dbo].[CONFIG]
SET Value = 'CustomOrderChannel'
WHERE [Key] = 'FilteredCustomOrderAttributes'

DROP INDEX IF EXISTS IX___dbo___ORDER___CustomOrderChannel  ON [dbo].[ORDER];
CREATE NONCLUSTERED INDEX IX___dbo___ORDER___CustomOrderChannel ON [dbo].[ORDER]
(
	[CustomOrderChannel] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF);