--This script is used to disable providers that are not currenlty supported by BetterRetail

Update [dbo].[PROVIDER]
Set Active = '0'
Where ImplementationTypeName IN ('ShipToStoreFulfillmentProvider')

DELETE [dbo].[PROVIDER]
Where ImplementationTypeName = 'AvalaraTaxProvider'