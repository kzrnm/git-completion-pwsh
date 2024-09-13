// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using Kzrnm.GitCompletion.Context;
using System.Collections.Generic;
using System.Management.Automation;

namespace Kzrnm.GitCompletion;

[Cmdlet(VerbsLifecycle.Complete, "Git")]
[OutputType(typeof(CompletionResult[]))]
public class CompleteGitCommand : CompleteGitCommandBase
{
    protected override IEnumerable<CompletionResult> Complete(CompletionContext context)
    {
        for (int i = 0; i < context.WordCount; i++)
        {
            if (context.Word(i) is { Length: > 0 } s)
                yield return new(s);
        }
    }
}
