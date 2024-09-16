// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using System;
using System.Diagnostics;

namespace Kzrnm.GitCompletion.Completion;

[Conditional("COMPILE_ONLY")]
internal sealed class GitSubcommandAttribute(params string[] subcommands) : Attribute
{
    public string[] Subcommands { get; } = subcommands;
}
