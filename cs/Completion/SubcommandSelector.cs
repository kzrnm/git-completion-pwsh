using Kzrnm.GitCompletion.Context;
using System.Collections.Generic;
using System.Management.Automation;

namespace Kzrnm.GitCompletion.Completion;
internal static partial class SubcommandSelector
{
    public static IEnumerable<CompletionResult> CompleteSubcommand(CompletionContext context)
    {
        return CompleteSubcommandImpl(context);
    }

    private static partial IEnumerable<CompletionResult> CompleteSubcommandImpl(CompletionContext context);

    public static IEnumerable<CompletionResult> CompleteSubcommandCommon(CompletionContext context)
    {
        return [];
    }
}
