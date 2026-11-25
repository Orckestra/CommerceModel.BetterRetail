using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Threading.Tasks;
using Orckestra.Overture.Orders.Processing.Workflows.Activities;
using Orckestra.Overture.ServiceModel;

namespace CommerceModel.BetterRetail.Activities
{
    /// <summary>
    /// Populates the Mobile Store Fulfillment (MSF) attributes of the line items of the order, using sample data.
    /// One attribute is created for each supported value type (text, localized text, integer, decimal, money, boolean and date/time).
    /// </summary>
    [DisplayName("Set Mobile Store Fulfillment attributes")]
    [Description("Populates the Mobile Store Fulfillment attributes (sample data) of the line items of the order.")]
    public sealed class SetMobileStoreFulfillmentAttributesActivity : AsyncOrderProcessingActivity
    {
        // Sample SKUs (Global-Dev-v1.5 products "sku" field); the products exist in every scope under QueueProductCatalogsImportsActivity.
        // 3 products without variant (SKU is the product's sku, product ids 1617221, 3508033, 3121702) and 2 variants (SKU equals the variant id).
        private static readonly string[] SampleSkus = { "0078-55181DC", "0005-202514460001", "0003-VNV6070", "86284719", "85959305" };

        private static readonly string[] Materials = { "Cotton", "Leather", "Wool", "Linen", "Silk" };
        private static readonly string[] MaterialsFr = { "Coton", "Cuir", "Laine", "Lin", "Soie" };

        /// <summary>
        /// Sets the MSF attributes on the line items having a sample SKU.
        /// </summary>
        /// <param name="context"> The order processing activity context. </param>
        protected override Task Process(AsyncOrderProcessingActivityContext context)
        {
            var shipments = context.CurrentOrder?.Cart?.Shipments;
            if (shipments == null)
            {
                context.ProcessingRecordTracker.TrackVerbose(EmptyCartMessageId, "The cart does not contain any shipment");
                return Task.CompletedTask;
            }

            foreach (var lineItem in shipments.Where(s => s?.LineItems != null).SelectMany(s => s.LineItems))
            {
                var index = Array.IndexOf(SampleSkus, lineItem.Sku);
                if (index >= 0)
                {
                    var liAttr = CreateAttributes(lineItem.Sku, index);
                    MobileStoreFulfillmentExtensionsManager.SetAttributes(lineItem, liAttr);
                }
            }

            return Task.CompletedTask;
        }

        private static List<LabeledAttribute> CreateAttributes(string sku, int index)
        {
            return new List<LabeledAttribute>
            {
                new LabeledAttribute(Label("VPN", "NPV"), "VPN-" + sku),
                new LabeledAttribute(Label("Material", "Matériau"),
                    Text(Materials[index], MaterialsFr[index])),
                new LabeledAttribute(Label("Pack size", "Taille du paquet"), 6L * (index + 1)),
                new LabeledAttribute(Label("Weight (kg)", "Poids (kg)"), 0.5m * (index + 1)),
                new LabeledAttribute(Label("Deposit", "Dépôt"), 1.25m * (index + 1)) { Formatter = LabeledAttributeFormatter.Money },
                new LabeledAttribute(Label("Fragile", "Fragile"), index % 2 == 0),
                new LabeledAttribute(Label("Creation Date", "Date de création"), new DateTime(2026, 1, 15, 8, 30, 0, DateTimeKind.Utc).AddDays(30 * index).AddHours(3 * index).AddMinutes(7 * index).AddSeconds(13 * index + 5))
            };
        }

        private static LocalizedString Label(string en, string fr)
        {
            return Text(en, fr);
        }

        private static LocalizedString Text(string en, string fr)
        {
            return new LocalizedString(new Dictionary<string, string>
            {
                { "en-US", en }, { "en-CA", en }, { "fr-CA", fr }
            });
        }
    }
}
