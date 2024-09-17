// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using Kzrnm.GitCompletion.Context;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;

namespace Kzrnm.GitCompletion.Completion.Completer;

internal static class GitOptionsCompleter
{
    public static GitOptionsCompleter<GitOptionsDescriptionBuilder> Create(
        string Current,
        CompletionContext Context,
        string Command,
        string Subcommand = "",
        string Prefix = "",
        string Suffix = "")
        => new(
            Current,
            Prefix: Prefix,
            Suffix: Suffix,
            DescriptionBuilder: new(Context, Command, Subcommand));
}

internal readonly record struct GitOptionsDescriptionBuilder(CompletionContext Context, string Command, string Subcommand) : IDescriptionBuilder
{
    public string? Description(string candidate)
    {
        candidate = candidate.TrimEnd('=');
        var gh = Context.GitHelp(Command);
        if (gh?.Description(Subcommand, candidate) is string result) return result;

        if (candidate.StartsWith("--no-"))
        {
            if (Description("--" + candidate.Substring(5)) is string positive)
                return $"[NO] {positive}";
        }
        return null;
    }
}
internal readonly record struct GitOptionsCompleter<T>(
    string Current,
    CompletionResultType ResultType = CompletionResultType.ParameterName,
    string Prefix = "",
    string Suffix = "",
    T DescriptionBuilder = default)
        where T : struct, IDescriptionBuilder
{
    readonly record struct CompletionCandidate(string Candidate, string CandidateWithSuffix, string Completion);
    CompletionCandidate ToCompletionCandidate(string c)
        => new(c, $"{c}{Suffix}", $"{Prefix}{c}{Suffix}");
    bool Accept(CompletionCandidate c) => c.CandidateWithSuffix.StartsWith(Current);
    CompletionResult Build(CompletionCandidate c) => new(
        c.Completion,
        c.Completion,
        ResultType,
        DescriptionBuilder.Description(c.Candidate) ?? c.Completion);

    public IEnumerable<CompletionResult> Complete(IEnumerable<string> candidates)
    {
        if (Current.EndsWith("=")) return [];
        if (Current.StartsWith("--no-"))
        {
            return candidates
                .Select(ToCompletionCandidate)
                .Where(Accept)
                .Select(Build);
        }
        else
        {
            var list = new List<CompletionResult>();
            foreach (var candidate in candidates)
            {
                var c = ToCompletionCandidate(candidate);
                if (c.Candidate == "--")
                {
                    if ("--no-".StartsWith(candidate))
                    {
                        list.Add(new("--no-", $"--no-...{Suffix}", ResultType, $"--no-...{Suffix}"));
                    }
                    break;
                }
                else if (Accept(c))
                {
                    list.Add(Build(c));
                }
            }
            return list;
        }
    }
}
