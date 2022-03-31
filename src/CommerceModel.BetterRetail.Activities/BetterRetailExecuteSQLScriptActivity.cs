using Orckestra.Data.PetaPoco;
using Orckestra.Overture.DurableTask;
using Orckestra.Overture.DurableTask.Model;
using System;
using System.Activities;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace CommerceModel.BetterRetail.Activities
{
    /// <summary>
    /// Custom implementation of ExecuteSQLScriptActivity for BetterRetail
    /// that is required to run before QueueProductCatalogsImportsActivity
    /// to set MaxNumberOfVariantAttributes and MaxNumberOfProductAttributes in product database
    /// </summary>
#pragma warning disable S101 // Types should be named in PascalCase
    public class BetterRetailExecuteSQLScriptActivity : TaskActivity
#pragma warning restore S101 // Types should be named in PascalCase
    {
        [RequiredArgument]
        public InArgument<string> CommerceModelName { get; set; }

        protected override async Task ExecuteAsync(TaskActivityContext context, CancellationToken cancellationToken)
        {
            context.TaskExecutionLogger.Log(LogEntryLevel.Info, "Starting ExecutePreProductsCatalogSQLScriptActivity");

            try
            {
                var rootPath = Path.Combine(
                    Path.GetDirectoryName(System.Reflection.Assembly.GetEntryAssembly().Location),
                    context.GetValue(CommerceModelName),
                    GetType().Name);

                if (Directory.Exists(rootPath))
                {
                    var dbFactory = context.DependencyResolver.Resolve<IAsyncDatabaseFactory>();

                    var directories = Directory.GetDirectories(rootPath).Select(d => new DirectoryInfo(d));

                    // Each directory should represent the database to target i.e Foundation,Membership, etc.
                    foreach (var directory in directories)
                    {
                        using (var database = dbFactory.CreateNew($"Orckestra.Overture.{directory.Name}"))
                        {
                            var scriptsFiles = Directory.GetFiles(directory.FullName)
                                .Select(f => new FileInfo(f))
                                .OrderBy(f => f.Name);

                            foreach (var file in scriptsFiles)
                            {
                                string script = File.ReadAllText(file.FullName);
                                await database.ExecuteAsyncWithRetry(script).ConfigureAwaitWithCulture(false);
                            }
                        }
                    }
                }
                else
                {
                    context.TaskExecutionLogger.Log(LogEntryLevel.Warning, "The root folder {RootPath} for the scripts does not exist.", rootPath);
                }
            }
            catch (Exception ex)
            {
                context.TaskExecutionLogger.Log(LogEntryLevel.Error, "An error occurred. Exception {Message}", ex.Message);
            }

            context.TaskExecutionLogger.Log(LogEntryLevel.Info, "Complete ExecutePreProductsCatalogSQLScriptActivity");
        }
    }
}
