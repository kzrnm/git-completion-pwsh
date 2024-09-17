// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using Kzrnm.GitCompletion.Completion.Completer;
using Kzrnm.GitCompletion.Context;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using static Kzrnm.GitCompletion.Completion.SubcommandCompletion;

namespace Kzrnm.GitCompletion.Completion.Subcommand;

[System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE0060", Justification = "Static classes cannot implement interfaces")]
[GitSubcommand("add", "stage")]
internal static class SubcommandAdd
{
    public static IEnumerable<CompletionResult> Complete(CompletionContext context)
    {
        var command = context.Command!;
        var current = context.CurrentWord;
        if (!context.HasDoubledash)
        {
            if (ShortOptions(context, current, command) is { Count: > 0 } shortOpts) return shortOpts;

            if (Options(context.PreviousWord, true) is { } prevCandidates)
            {
                return new DescriptionCompleter(current, CompletionResultType.ParameterValue)
                    .Complete(prevCandidates);
            }
            if (EqualsOptionRegex.Match(current) is { Success: true, Groups: var m }
                && m[1].Value is string key
                && m[2].Value is string value
                && Options(key, false) is { } candidates)
            {
                return new DescriptionCompleter(value, CompletionResultType.ParameterValue, Prefix: $"{key}=")
                    .Complete(candidates);
            }

            if (current.StartsWith("--"))
            {
                return CompleteResolveBuiltins(context, current, command);
            }
        }

        var completeOpt = IndexFilesOptions.Updated;
        var skipOptions = new HashSet<string>(
            context.GitResolveBuiltins(command, all: true).Where(p => p.EndsWith("=")));

        var usedPaths = new List<string>(context.WordCount);
        for (int i = context.CommandIndex + 1; i < context.WordCount; i++)
        {
            if (i == context.CurrentIndex) continue;
            var w = context.Word(i);
            if (w == "--update" || (w.Length >= 2 && w[0] == '-' && w.IndexOf('u') >= 0))
            {
                completeOpt = IndexFilesOptions.Modified;
            }
            else if (skipOptions.Contains(w))
            {
                ++i;
            }
            else if (!w.StartsWith("-") || i > context.DoubledashIndex)
            {
                usedPaths.Add(w);
            }
        }

        return CompletionFiles.CompleteIndexFile(context, current, completeOpt, exclude: usedPaths, leadingDash: context.HasDoubledash);
    }

    static IEnumerable<DescribedText>? Options(string? current, bool prev)
    {
        return current switch
        {
            "--chmod" => ["+x", "-x"],
            _ => null,
        };
    }
}