 update [dbo].[ATTRIBUTE] set IsFacettableWeb = 1
where AttributeName = 'PromotionalRibbon' 
	or AttributeName = 'PromotionalBanner'