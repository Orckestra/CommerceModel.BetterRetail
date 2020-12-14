using System;
using System.Collections.Generic;
using Orckestra.Overture;
using Orckestra.Overture.Extensibility.Interfaces;
using Orckestra.Overture.ServiceModel.Dam;

namespace CommerceModel.BetterRetail.DamProviders
{
    //public class BetterRetailDamProvider : IDamProvider
    //{
    //    private const string CDN_IMAGE_FORMATTER = "https://refapp.azureedge.net/images/{0}_0_M.jpg";

    //    public Guid Id { get; set; }
    //    public string Name { get; set; }
    //    public bool IsActive { get; set; }
    //    public ILocalizedString DisplayName { get; set; }
    //    public Dictionary<string, Dictionary<string, object>> PropertyConfigurations { get; set; }

    //    public string GetAssetUrl(string assetType, string scope, string entityTypeName, string cultureName, string entityId,
    //        IDictionary<string, object> entityAttributes)
    //    {
    //        if (entityTypeName == "Variant" && entityAttributes.ContainsKey("ParentItemName"))
    //        {
    //            return string.Format(CDN_IMAGE_FORMATTER, entityAttributes["ParentItemName"] + "_" + entityId);
    //        }

    //        return string.Format(CDN_IMAGE_FORMATTER, entityId);
    //    }

    //    public IEnumerable<ProductMedia> GetProductsMedia(IEnumerable<string> productIds, string scope, string cultureName)
    //    {
    //        return new List<ProductMedia>();
    //    }
    //}
}
