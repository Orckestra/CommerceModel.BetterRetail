using CommerceModel.BetterRetail.DamProviders;
using Orckestra.Overture;
using Orckestra.Overture.Extensibility;

namespace CommerceModel.BetterRetail
{
    public class Plugin: IPlugin
    {
       public void Register(IOvertureHost host)
        {
            host.Providers.Register("BetterRetail", typeof(BetterRetailDamProvider), ComponentLifestyle.Transient);
        }
    }
}
