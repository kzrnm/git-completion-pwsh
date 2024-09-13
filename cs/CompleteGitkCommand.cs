// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using Kzrnm.GitCompletion.Completion;
using Kzrnm.GitCompletion.Context;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using static Kzrnm.GitCompletion.Git.Constants;

namespace Kzrnm.GitCompletion;

[Cmdlet(VerbsLifecycle.Complete, "Gitk")]
[OutputType(typeof(CompletionResult[]))]
public class CompleteGitkCommand : CompleteGitCommandBase
{
    protected override IEnumerable<CompletionResult> Complete(CompletionContext context)
    {
        if (context.HasDoubledash) return Array.Empty<CompletionResult>();

        var current = context.CurrentWord;
        if (current.StartsWith("--"))
        {
            return StringCompleter.Create(current, CompletionResultType.ParameterName)
                .Complete(GitkOptions(context.GitPseudorefExists("MERGE_HEAD")));
        }

        return CompletionRefs.CompleteRevlist(context);
    }

    private static IEnumerable<string> GitkOptions(bool merge)
    {
        var result = LogCommonOptions.Concat(LogGitkOptions);
        if (merge)
        {
            result = result.Append("--merge");
        }
        return result;
    }
}
