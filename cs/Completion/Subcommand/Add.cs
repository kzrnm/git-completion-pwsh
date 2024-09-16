// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using Kzrnm.GitCompletion.Context;
using System.Collections.Generic;
using System.Management.Automation;

namespace Kzrnm.GitCompletion.Completion.Subcommand;

[GitSubcommand]
internal static class SubcommandAdd
{
    public static IEnumerable<CompletionResult> Complete(CompletionContext context)
    {
        return [];
    }
}
