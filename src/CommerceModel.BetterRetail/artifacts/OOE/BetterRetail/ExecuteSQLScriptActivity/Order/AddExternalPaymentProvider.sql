IF OBJECT_ID('tempdb..#ScopeToAdd') IS NOT NULL DROP TABLE #ScopeToAdd

CREATE TABLE #ScopeToAdd (
    ScopeId VARCHAR(30),
    ProviderGuid VARCHAR(40)
)

INSERT INTO #ScopeToAdd 
VALUES 
    ('BetterRetailCanada','7E5F8183-CBF4-467B-9200-6F39D586B64A')
    ,('BetterRetailNetherlands','D4D01053-67A1-4CF4-A194-2B65DE20A63B')
    ,('BetterRetailNorway','997DADB2-49F1-4764-934F-9C6E530E8515')
    ,('BetterRetailUSA','13C0BA5C-2BF2-4DF1-813E-4342541BBCCF')

DECLARE @@webAppPaymentURL AS VARCHAR(100)
DECLARE @@providerType AS VARCHAR(10) = 'Payment'
DECLARE @@providerName AS VARCHAR(20) = 'Bambora'
DECLARE @@paymentProviderType AS VARCHAR(25) = 'ExternalPaymentProvider'

SELECT @@webAppPaymentURL =
    CASE 
        WHEN [Name] LIKE '%dev_commerce_order' THEN 'https://localhost:7107/'
		WHEN [Name] LIKE '%int_commerce_order' THEN 'https://occintbamborawa-webapp-u4oio7wixsviq.azurewebsites.net/'
		WHEN [Name] LIKE '%qa_commerce_order' THEN 'https://occqabamborawa-webapp-u4oio7wixsviq.azurewebsites.net/'
        ELSE 'https://occintbamborawa-webapp-u4oio7wixsviq.azurewebsites.net/'
    END
FROM sys.databases WHERE [Name] like '%_commerce_order'

WHILE EXISTS(SELECT * FROM #ScopeToAdd)
BEGIN
    DECLARE @@providerGuid AS VARCHAR(40) = (SELECT TOP 1 ProviderGuid FROM #ScopeToAdd)
    DECLARE @@scopeId AS VARCHAR(30) = (SELECT TOP 1 ScopeId FROM #ScopeToAdd)
    DELETE #ScopeToAdd WHERE ProviderGuid = @@providerGuid AND ScopeId = @@scopeId

    IF NOT EXISTS(SELECT * FROM dbo.PROVIDER WHERE [Type] = @@providerType AND [Name] = @@providerName AND [ScopeName] = @@scopeId)

    BEGIN
        INSERT INTO [dbo].[PROVIDER]
               ([Provider_Id]
               ,[ScopeName]
               ,[Type]
               ,[Name]
               ,[ImplementationTypeName]
               ,[Active]
               ,[ProviderDetails])
         VALUES
               (@@providerGuid
               ,@@scopeId
               ,@@providerType
               ,@@providerName
               ,@@paymentProviderType
               ,1
               ,'<PaymentProvider>
                <IsDefaultPaymentMethodSupported Type="Boolean">False</IsDefaultPaymentMethodSupported>
                <IsRefreshOperationSupported Type="Boolean">True</IsRefreshOperationSupported>
                <Id Type="Guid">' + @@providerGuid + '</Id>
                <Type Type="ProviderType">' + @@providerType + '</Type>
                <ScopeId Type="String">' + @@scopeId + '</ScopeId>
                <Name Type="String">' + @@providerName + '</Name>
                <ImplementationTypeName Type="String">' + @@paymentProviderType + '</ImplementationTypeName>
                <DisplayName Type="Localizable:String">
                <type Type="String">String</type>
                <en_x2d_US Type="String">Bambora</en_x2d_US>
                <en_x2d_CA Type="String">Bambora</en_x2d_CA>
                <fr_x2d_CA Type="String">Bambora</fr_x2d_CA>
                </DisplayName>
                <IsActive Type="Boolean">True</IsActive>
                <Values Type="Dictionary">
                <Timeout Type="Int32">30</Timeout>
                <IsRefreshOperationSupported Type="Boolean">True</IsRefreshOperationSupported>
                <AuthorizePaymentUrl Type="String">' + @@webAppPaymentURL + 'api/paymentprovider/authorize</AuthorizePaymentUrl>
                <RefreshPaymentUrl Type="String">' + @@webAppPaymentURL + 'api/paymentprovider/refresh</RefreshPaymentUrl>
                <RefundPaymentUrl Type="String">' + @@webAppPaymentURL + 'api/paymentprovider/refund</RefundPaymentUrl>
                <SettlePaymentUrl Type="String">' + @@webAppPaymentURL + 'api/paymentprovider/settle</SettlePaymentUrl>
                <VoidPaymentUrl Type="String">' + @@webAppPaymentURL + 'api/paymentprovider/void</VoidPaymentUrl>
                <DeletePaymentMethodUrl Type="String">' + @@webAppPaymentURL + 'api/paymentmethod/delete</DeletePaymentMethodUrl>
                <GetPaymentMethodsByCustomerIdUrl Type="String">' + @@webAppPaymentURL + 'api/paymentmethod/getpaymentmethodsbycustomerid</GetPaymentMethodsByCustomerIdUrl>
                <GetPaymentMethodsByCartUrl Type="String">' + @@webAppPaymentURL + 'api/paymentmethod/get</GetPaymentMethodsByCartUrl>
                <SetDefaultPaymentMethodUrl Type="String">' + @@webAppPaymentURL + 'api/paymentmethod/set</SetDefaultPaymentMethodUrl>
                <InitializePaymentUrl Type="String">' + @@webAppPaymentURL + 'api/paymentprovider/initialize</InitializePaymentUrl>
				<CreateCartPaymentVaultProfileUrl Type="String">' + @@webAppPaymentURL + '​api​/paymentprofile​/createcartpaymentvaultprofile</CreateCartPaymentVaultProfileUrl>
				<SupportedCultureIds Type="String">en-US,en-CA,fr-CA</SupportedCultureIds
                </Values>
                <PropertyConfigurations Type="Dictionary" />
                <FullTypeName Type="String">Orckestra.Overture.Entities.Providers.PaymentProvider, Orckestra.Overture.Entities</FullTypeName>
                <TypeName Type="String">' + @@providerType + 'Provider</TypeName>
                <PropertyBag Type="Dictionary" />
                </PaymentProvider>')

    END
END

DROP TABLE #ScopeToAdd
