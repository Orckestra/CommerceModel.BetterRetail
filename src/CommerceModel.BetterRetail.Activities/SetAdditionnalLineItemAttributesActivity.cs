using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using Orckestra.Overture.Orders.Processing.Workflows.Activities;
using Orckestra.Overture.ServiceModel;

namespace CommerceModel.BetterRetail.Activities
{
    /// <summary>
    /// Set additional attributes for each line item of the cart.
    /// </summary>
    [DisplayName("Set additional line items attributes")]
    [Description("Set additional attributes for each line item of the cart.")]
    public sealed class SetAdditionnalLineItemAttributesActivity : AsyncOrderProcessingActivity
    {
        /// <summary>
        /// The AllowSelectionWithoutScan property bag key
        /// </summary>
        public const string AllowSelectionWithoutScanKey = "AllowSelectionWithoutScan";

        /// <summary>
        /// The ImageUrl property bag key
        /// </summary>
        public const string ImageUrlKey = "ImageUrl";

        /// <summary>
        /// The message id for cultureName not found.
        /// </summary>
        public const string CultureNotFoundMessageId = "CultureNotFoundMessage";

        /// <summary>
        /// The starting characters of LineItem attributes used for testing
        /// </summary>
        public const string LineItemTest = nameof(LineItemTest);

        /// <summary>
        ///     Loads the product details in the line items of the cart.
        /// </summary>
        /// <param name="context"> The order processing activity context. </param>
        protected override Task Process(AsyncOrderProcessingActivityContext context)
        {
            if (context.CurrentOrder == null || context.CurrentOrder.Cart == null || context.CurrentOrder.Cart.Shipments == null
                || context.CurrentOrder.Cart.Shipments.All(ship => ship == null || ship.LineItems == null))
            {
                context.ProcessingRecordTracker.TrackVerbose(EmptyCartMessageId, "The cart does not contain any shipment with line items");
                return Task.CompletedTask;
            }

            if (string.IsNullOrWhiteSpace(context.CurrentOrder.Cart.CultureName))
            {
                context.ProcessingRecordTracker.TrackError(
                    CultureNotFoundMessageId,
                    "The cultureName of the cart was not provided in context.CurrentOrder.Cart.CultureName. Product information will not be retrieved.",
                    new Dictionary<string, object> { { "CartId", context.CurrentOrder.Cart.Id } });
                return Task.CompletedTask;
            }

            //Get product and schema information for items requiring refresh
            var products = context.OrderProcessingOriginalContext.Products;

            foreach (var lineItem in context.CurrentOrder.Cart.Shipments.SelectMany(x => x.LineItems))
            {
                var product = products.SingleOrDefault(p => p.Id.Equals(lineItem.ProductId, StringComparison.InvariantCultureIgnoreCase));

                var allowSelectionWithoutScan = product?.PropertyBag?.GetOrDefault<bool>(AllowSelectionWithoutScanKey, false) ?? false;
                var imageUrl = product?.PropertyBag?.GetOrDefault<string>(ImageUrlKey, null);

                lineItem.PropertyBag = lineItem.PropertyBag ?? new Orckestra.Overture.ServiceModel.PropertyBag();
                lineItem.ProductSummary.AllowSelectionWithoutScan = allowSelectionWithoutScan;

                if (!string.IsNullOrWhiteSpace(imageUrl))
                    lineItem.PropertyBag[ImageUrlKey] = imageUrl;
                else
                {
                                    context.ProcessingRecordTracker.TrackError(
    imageUrl ?? CultureNotFoundMessageId,
    "The cultureName of the cart was not provided in context.CurrentOrder.Cart.CultureName. Product information will not be retrieved.    " + imageUrl + "-----",
    new Dictionary<string, object> { { "CartId", context.CurrentOrder.Cart.Id } });


                    lineItem.PropertyBag.Remove(ImageUrlKey);
                }

                var testProductPropertyBag = product?.PropertyBag?.Where(p => p.Key.Contains(LineItemTest));

                if (testProductPropertyBag != null && testProductPropertyBag.Any())
                {
                    foreach(var property in testProductPropertyBag)
                    {
                        var valueString = property.Value.ToString();
                        if (bool.TryParse(valueString, out bool valueAsBoolean))
                        {
                            lineItem.PropertyBag[property.Key] = valueAsBoolean;
                            continue;
                        }

                        if (int.TryParse(valueString, out int valueAsInt) && valueAsInt == int.Parse(valueString))
                        {
                            lineItem.PropertyBag[property.Key] = valueAsInt;
                            continue;
                        }
                        if (decimal.TryParse(valueString, out decimal valueAsDecimal) && valueAsDecimal == decimal.Parse(valueString))
                        {
                            lineItem.PropertyBag[property.Key] = valueAsDecimal;
                            continue;
                        }
                        if (DateTime.TryParse(valueString, out DateTime valueAsDateTime) && valueAsDateTime == DateTime.Parse(valueString))
                        {
                            lineItem.PropertyBag[property.Key] = valueAsDateTime;
                            continue;
                        }
                        lineItem.PropertyBag[property.Key] = valueString;
                    }
                }
            }

            return Task.CompletedTask;
        }


    }
}
;