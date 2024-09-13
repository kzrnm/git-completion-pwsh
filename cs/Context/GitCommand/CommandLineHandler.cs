// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using System.Text;

namespace Kzrnm.GitCompletion.Context.GitCommand;


[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE0044")]
[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE0251")]
[InterpolatedStringHandler]
internal struct CommandLineHandler
{
    StringBuilder sb;
    public CommandLineHandler(int literalLength, int formattedCount)
    {
        sb = new StringBuilder(literalLength + formattedCount);
    }
    public CommandLineHandler(int literalLength, int formattedCount, CompletionContext context)
    {
        sb = new StringBuilder(literalLength + formattedCount);
        context.AppendGitArguments(sb);
    }
    public CommandLineHandler(int literalLength, int formattedCount, CompletionContext context, string overrideGitDir)
    {
        sb = new StringBuilder(literalLength + formattedCount);
        context.AppendGitArguments(sb, overrideGitDir);
    }
    public void AppendLiteral(string s) => sb.Append(s).Append(' ');
    public void AppendFormatted(string? x)
    {
        if (x == null) return;
        sb.AppendArgument(x);
        sb.Append(' ');
    }
    public void AppendFormatted(string[]? args)
    {
        if (args == null) return;
        foreach (var arg in args)
        {
            AppendFormatted(arg);
        }
    }
    public void AppendFormatted(IEnumerable<string>? args)
    {
        if (args == null) return;
        foreach (var arg in args)
        {
            AppendFormatted(arg);
        }
    }
    public void AppendFormatted<T>(T x)
    {
        if (x == null) return;
        sb.AppendArgument(x.ToString());
        sb.Append(' ');
    }

    public override string ToString()
    {
        return sb.ToString();
    }
}
