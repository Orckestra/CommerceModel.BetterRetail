UPDATE [dbo].[CONFIG]
SET Value = 'OrderNumber|ScopeName|OrderStatus|Created|FulfillmentDate|ShipmentCount|Total|CustomerName|DestinationLocation|CustomLookupAtt'
WHERE [Key] = 'DisplayedOrderAttributes'

UPDATE [dbo].[CONFIG]
SET Value = 'CustomLookupAtt'
WHERE [Key] = 'FilteredCustomOrderAttributes'

DROP INDEX IF EXISTS IX___dbo___ORDER___CustomLookupAtt  ON [dbo].[ORDER];
CREATE NONCLUSTERED INDEX IX___dbo___ORDER___CustomLookupAtt ON [dbo].[ORDER]
(
	[CustomLookupAtt] ASC
)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF);