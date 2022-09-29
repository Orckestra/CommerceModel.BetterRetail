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
    public class CustomExecuteSQLScriptActivity : TaskActivity
    {
        [RequiredArgument]
        public InArgument<string> CommerceModelName { get; set; }

        public InArgument<string[]> FilesToExecute { get; set; }

        protected override async Task ExecuteAsync(TaskActivityContext context, CancellationToken cancellationToken)
        {
            context.TaskExecutionLogger.Log(LogEntryLevel.Info, $"Starting {nameof(CustomExecuteSQLScriptActivity)}");

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
                    var filesToExecute = context.GetValue(FilesToExecute);
                    // Each directory should represent the database to target i.e Foundation,Membership, etc.
                    foreach (var directory in directories)
                    {
                        using (var database = dbFactory.CreateNew($"Orckestra.Overture.{directory.Name}"))
                        {
                            var scriptsFiles = Directory.GetFiles(directory.FullName)
                                .Select(f => new FileInfo(f));

                            var fileToExecutes = scriptsFiles.Where(item => filesToExecute.Contains(item.Name));
                            foreach (var fileToExecute in fileToExecutes)
                            {
                                string script = File.ReadAllText(fileToExecute.FullName);
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

            context.TaskExecutionLogger.Log(LogEntryLevel.Info, "Complete CustomExecuteSQLScriptActivity");
        }
    }
}
