// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using Kzrnm.GitCompletion.Completion.Completer;
using Kzrnm.GitCompletion.Context;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text.RegularExpressions;

namespace Kzrnm.GitCompletion.Completion;
internal static class SubcommandCompletion
{
    public static Regex EqualsOptionRegex = new(@"^(--[^=]+)=(.*)$", RegexOptions.CultureInvariant | RegexOptions.Compiled);
    public static Regex ShortOptionRegex = new(@"^(-([^-]*))(?!-)$", RegexOptions.CultureInvariant | RegexOptions.Compiled);

    public static CompletionResult ShortHelpOption = new("-h", "-h", CompletionResultType.ParameterName, "show help");

    public static ICollection<CompletionResult> ShortOptions(CompletionContext context, string current, string command, string subcommand = "")
    {
        List<CompletionResult> result = [];
        if (ShortOptionRegex.Match(current) is { Success: true, Groups: var m })
        {
            var prev = m[1].Value;
            var exists = m[2].Value;
            if (context.GitHelp(command) is { } gh)
            {
                result.AddRange(gh.ShortOptions(subcommand).Where(s => exists.IndexOf(s.Key) < 0)
                    .Select(s => new CompletionResult($"{prev}{s.Key}", $"-{s.Key}", CompletionResultType.ParameterName, s.Description)));
            }
            if (current == "-")
            {
                result.Add(ShortHelpOption);
            }
        }
        return result.ToArray();
    }

    public static IEnumerable<CompletionResult> CompleteResolveBuiltins(
        CompletionContext context,
        string current,
        string command,
        string? subcommand = null,
        string[]? include = null,
        HashSet<string>? exclude = null,
        bool check = false)
    {
        IEnumerable<string> options;
        if (include == null)
        {
            options = context.GitResolveBuiltins(command, subcommand, check: check);
        }
        else
        {
            options = include.Concat(context.GitResolveBuiltins(command, subcommand, check: check));
        }

        if (exclude != null)
        {
            options = options.Where(s => !exclude.Contains(s));
        }

        return GitOptionsCompleter.Create(current, context, command, subcommand ?? "")
            .Complete(options);
    }
}

