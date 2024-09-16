// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using Kzrnm.GitCompletion.Completion.Completer;
using Kzrnm.GitCompletion.Context;
using System.Collections.Generic;
using System.Management.Automation;
using System.Text.RegularExpressions;

namespace Kzrnm.GitCompletion.Completion;

internal static partial class GitConfigVariable
{
    static readonly Regex configVariableRegex = new(@"^([^=]*)=(.*)", RegexOptions.CultureInvariant);
    public static IEnumerable<CompletionResult> CompleteConfigOptionVariableNameAndValue(CompletionContext context, string current, string prefix = "")
    {
        if (configVariableRegex.Match(current) is { Success: true, Groups: var m })
        {
            var varName = m[1].Value;
            var value = m[2].Value;
            return CompleteConfigVariableValue(context, varName, value, prefix: prefix);
        }
        else
        {
            var (first, second, third) = Split3VarName(current);
            return new ConfigVariableCompleter(context, first, second, third, Prefix: prefix, Suffix: "=").Complete();
        }
    }

    static (string, string?, string?) Split3VarName(string varName)
    {
        var dot1 = varName.IndexOf('.');
        if (dot1 < 0)
        {
            return (varName, null, null);
        }
        else
        {
            var dot2 = varName.LastIndexOf('.');
            var first = varName.Substring(0, dot1);
            if (dot1 == dot2)
            {
                return (first, varName.Substring(dot1 + 1), null);
            }
            else
            {
                return (first, varName.Substring(dot1 + 1, dot2 - dot1 - 1), varName.Substring(dot2 + 1));
            }
        }
    }

    static readonly Regex spaceSplitterRegex = new(@"^(\S+)\s+(\S+)", RegexOptions.CultureInvariant);
    public static IEnumerable<CompletionResult> CompleteConfigVariableValue(CompletionContext context, string varName, string current, string prefix)
    {
        var (first, second, third) = Split3VarName(varName);

        DescribedText[]? describedTexts = null;
        switch ((first, second, third))
        {
            case ("diff", "algorithm", null):
                describedTexts = new DescribedText[]{
                    new(
                        "default",
                        @"The basic greedy diff algorithm"
                    ),
                    new(
                        "myers",
                        @"The basic greedy diff algorithm. Currently, this is the default"
                    ),
                    new(
                        "minimal",
                        @"Spend extra time to make sure the smallest possible diff is produced"
                    ),
                    new(
                        "patience",
                        @"Use ""patience diff"" algorithm when generating patches"
                    ),
                    new(
                        "histogram",
                        @"This algorithm extends the patience algorithm to ""support low-occurrence common elements"""
                    )
                };
                break;
            case ("http", "proxyAuthMethod", null):
                describedTexts = new DescribedText[]{
                    new(
                        "anyauth",
                        @"Automatically pick a suitable authentication method"
                    ),
                    new(
                        "basic",
                        @"HTTP Basic authentication"
                    ),
                    new(
                        "digest",
                        @"HTTP Digest authentication; this prevents the password from being transmitted to the proxy in clear text"
                    ),
                    new(
                        "negotiate",
                        @"GSS-Negotiate authentication (compare the --negotiate option of curl)"
                    ),
                    new(
                        "ntlm",
                        @"NTLM authentication (compare the --ntlm option of curl)"
                    )
                };
                break;
        }


        if (describedTexts != null)
        {
            return new DescriptionCompleter(current, CompletionResultType.ParameterValue, Prefix: prefix)
                .Complete(describedTexts);
        }


        return StringCompleter.Create(current, CompletionResultType.ParameterValue, Prefix: $"{prefix}{varName}=")
            .Complete(Candidates(context, current, first, second, third));

        static IEnumerable<string> Candidates(CompletionContext context, string current, string first, string? second, string? third)
        {
            switch ((first, second, third))
            {
                case ("branch", _, "remote"):
                case ("branch", _, "pushremote"):
                case ("branch", _, "pushdefault"):
                case ("remote", "pushdefault", null):
                    return context.GitRemote();
                case ("branch", _, "merge"):
                    return context.GitRefs(current);
                case ("branch", _, "rebase"):
                    return ["false", "true", "merges", "interactive"];
                case ("remote", _, "fetch"):
                    if (current == "")
                    {
                        return ["refs/heads"];
                    }
                    else
                    {
                        var results = new List<string>();
                        var remote = second;
                        using var p = context.Git($"ls-remote {remote} refs/heads/*");
                        while (p.StandardOutput.ReadLine() is { Length: > 0 } line)
                        {
                            if (spaceSplitterRegex.Match(line) is { Success: true, Groups: var m })
                            {
                                var @ref = m[2].Value;
                                var result = $"{@ref}:refs/remotes/{remote}/{(@ref.StartsWith("^refs/heads/") ? @ref.Substring("^refs/heads/".Length) : @ref)}";
                                results.Add(result);
                            }
                        }
                        return results;
                    }
                case ("remote", _, "push"):
                    {
                        var results = new List<string>();
                        using var p = context.Git($"for-each-ref --format=%(refname):%(refname) refs/heads");
                        while (p.StandardOutput.ReadLine() is { Length: > 0 } line)
                        {
                            results.Add(line);
                        }

                        return results;
                    }
                case ("pull", "twohead" or "octopus", null):
                case ("color", "pager", null):
                    return ["false", "true"];
                case ("color", { }, { }):
                    return ["normal", "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white", "bold", "dim", "ul", "blink", "reverse"];
                case ("color", { }, null):
                    return ["false", "true", "always", "never", "auto"];
                case ("diff", "submodule" or "algorithm", null):
                    return GitConstants.DiffSubmoduleFormats;
                case ("help", "format", null):
                    return ["man", "info", "web", "html"];
                case ("log", "date", null):
                    return GitConstants.LogDateFormats;
                case ("sendemail", "aliasfiletype", null):
                    return ["mutt", "mailrc", "pine", "elm", "gnus"];
                case ("sendemail", "confirm", null):
                    return GitConstants.SendEmailConfirmOptions;
                case ("sendemail", "suppresscc", null):
                    return GitConstants.SendEmailSuppressccOptions;
                case ("sendemail", "transferencoding", null):
                    return ["7bit", "8bit", "quoted-printable", "base64"];
                default:
                    return [];
            }
        }
    }
}
