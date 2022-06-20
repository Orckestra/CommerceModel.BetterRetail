using System;
using System.Activities;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using Orckestra.Overture.DataExchange;
using Orckestra.Overture.DurableTask;
using Orckestra.Overture.DurableTask.Model;
using Orckestra.Overture.ServiceModel.Requests.SearchQueries;

namespace CommerceModel.BetterRetail.Activities
{
    public sealed class AddOrUpdateSearchQueryActivity : TaskActivity
    {
        [RequiredArgument]
        public InArgument<string> CommerceModelName { get; set; }

        protected override async Task ExecuteAsync(TaskActivityContext context, CancellationToken cancellationToken)
        {
            var importFolderPath = Path.Combine(context.GetValue(CommerceModelName), GetType().Name);
            var businessModelPath = Path.Combine(Environment.CurrentDirectory, $"{importFolderPath}");
            context.TaskExecutionLogger.Log($"Getting files to import located under {businessModelPath}");

            var filesToImport = Directory.GetFiles(businessModelPath, "*.json", SearchOption.AllDirectories);

            var serializer = context.DependencyResolver.Resolve<ISerializer>();
            foreach (var file in filesToImport)
            {
                context.TaskExecutionLogger.Log(LogEntryLevel.Info, $"Loading search queries from the file \"{file}\"");
                var jsonContent = File.ReadAllText(file, Encoding.UTF8);
                var searchQueryiesList = serializer.DeserializeFromJson<List<CreateSearchQueryRequest>>(jsonContent);

                var currentScope = Path.GetFileNameWithoutExtension(file);

                var existingSearchQueriesRequest = new FindSearchQueriesRequest
                {
                    ScopeId = currentScope
                };
                var existingSearchQueries = await context.RequestExecutor.ExecuteAsync(existingSearchQueriesRequest).ConfigureAwaitWithCulture(false);

                context.TaskExecutionLogger.Log(LogEntryLevel.Info, $"Amount of search queries in the scope  \"{currentScope}\" to be loaded: {searchQueryiesList.Count}");
                context.TaskExecutionLogger.Log(LogEntryLevel.Info, $"Amount of the current search queries in the scope  \"{currentScope}\": {existingSearchQueries.Count}");

                foreach (var el in searchQueryiesList)
                {
                    if (existingSearchQueries?.SearchQueries != null &&
                        existingSearchQueries.SearchQueries.Any(x => x.Name == el.Name && x.QueryType == el.QueryType))
                    {
                        var updateRequest = new UpdateSearchQueryRequest
                        {
                            QueryData = el.QueryData,
                            QueryType = el.QueryType,
                            Category = el.Category,
                            Name = el.Name,
                            ScopeId = el.ScopeId
                        };
                        try
                        {
                            await context.RequestExecutor.ExecuteAsync(updateRequest).ConfigureAwaitWithCulture(false);
                        }
                        catch (Exception ex)
                        {
                            context.TaskExecutionLogger.Log(LogEntryLevel.Error, $"Cannot update searchquery for the scope  \"{currentScope}\" with a name {el.Name}, reason: \"{ex}\"");
                        }
                    }
                    else
                    {
                        try
                        {
                            await context.RequestExecutor.ExecuteAsync(el).ConfigureAwaitWithCulture(false);
                        }
                        catch (Exception ex)
                        {
                            context.TaskExecutionLogger.Log(LogEntryLevel.Error, $"Cannot create searchquery for the scope  \"{currentScope}\" with a name {el.Name}, reason: \"{ex}\"");
                        }
                    }
                }
            }
        }
    }
}
