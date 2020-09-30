using System.Reflection;

// General Information about an assembly is controlled through the following 
// set of attributes. Change these attribute values to modify the information
// associated with an assembly.

[assembly: AssemblyCompany("Orckestra Technologies Inc.")]
[assembly: AssemblyProduct("Orckestra Commerce")]
[assembly: AssemblyCopyright("Copyright © Orckestra Technologies Inc. 2020")]
[assembly: AssemblyTrademark("")]
[assembly: AssemblyCulture("")]

#if(DEBUG)
[assembly: AssemblyConfiguration("Debug")]
#else
[assembly: AssemblyConfiguration("Retail")]
#endif
