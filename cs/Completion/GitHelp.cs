// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using Kzrnm.GitCompletion.Context;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace Kzrnm.GitCompletion.Completion;

internal static class GitHelpBuilder
{
    private static readonly Dictionary<string, GitHelp> _cache = new();
    public static GitHelp GitHelp(this CompletionContext context, string command)
    {
        if (_cache.TryGetValue(command, out var result)) return result;
        var options = new List<GitHelpOptions>();

        {
            GitHelpOptions opt;
            using (var p = context.GitRawAll($"{command} -h"))
                opt = ParseHelpOptions(p.StandardOutput, p.StandardError, command);

            options.Add(opt);
        }

        string[] subcommands;
        using (var p = context.Git($"{command} --git-completion-helper-all"))
        {
            subcommands = p.StandardOutput.ReadToEnd().SplitEmpty();
        }

        foreach (var subcommand in subcommands)
        {
            if (subcommand.StartsWith("-")) continue;

            GitHelpOptions opt;
            using (var p = context.GitRawAll($"{command} {subcommand} -h"))
                opt = ParseHelpOptions(p.StandardOutput, p.StandardError, command, subcommand);

            options.Add(opt);
        }

        return _cache[command] = new(options.ToArray());
    }

    static readonly Regex parseHelpOptionRegex = new(@"^(\s+)(-.*)", RegexOptions.CultureInvariant);
    static readonly Regex shortAndLongOptionRegex = new(@"^(-([^-])(,?\s*))?(--\S+)(.*)", RegexOptions.CultureInvariant);
    static readonly Regex shortValueOptionRegex = new(@"^-(\S)(=?\[[^\]]+\])?(.*)", RegexOptions.CultureInvariant);
    static readonly Regex bracketOptionRegex = new(@"^(\(?[\w-]+(\|[\w-]+)+\))(.*)", RegexOptions.CultureInvariant);
    private static GitHelpOptions ParseHelpOptions(StreamReader reader1, StreamReader reader2, string command, string subcommand = "")
    {
        Dictionary<string, string> longDescriptions = new();
        Dictionary<char, string> shortDescriptions = new();

        Parse(reader1);
        Parse(reader2);

        if (command == "grep")
        {
            if (longDescriptions.TryGetValue("--and", out var v))
            {
                longDescriptions["--or"] = longDescriptions["--not"] = v;
            }
        }

        return new GitHelpOptions(subcommand, longDescriptions, shortDescriptions);

        void Parse(StreamReader reader)
        {
            bool prev = false;
            string? longOpt = null;
            string? shortOpt = null;

            while (reader.ReadLine() is string line)
            {
                if (prev)
                {
                    AddDescription(line.Trim(), longOpt, shortOpt);
                    prev = false;
                    Debug.WriteLine($"\x1b[32m{line}\x1b[0m");
                }
                else if (parseHelpOptionRegex.Match(line) is { Success: true, Groups: var m })
                {
                    Debug.Write(m[1].Value);
                    line = m[2].Value;
                    longOpt = null;
                    shortOpt = null;
                    string remaining;
                    if (shortAndLongOptionRegex.Match(line) is { Success: true, Groups: var lsm })
                    {
                        shortOpt = lsm[2].Value;
                        Debug.WriteIf(!string.IsNullOrEmpty(shortOpt), $"\x1b[35m-{shortOpt}\x1b[0m{lsm[3].Value}");

#if DEBUG
                        (longOpt, var coloredLong) = TrimBracket(lsm[4].Value);
                        Debug.Write($"\x1b[36m{coloredLong}\x1b[0m");
#else
                        longOpt = TrimBracket(lsm[4].Value);
#endif

                        remaining = lsm[5].Value;
                    }
                    else if (line.StartsWith("-NUM"))
                    {
                        shortOpt = "-NUM";
                        remaining = line.Substring(4);
                        Debug.Write($"\x1b[35m-NUM\x1b[0m");
                    }
                    else if (shortValueOptionRegex.Match(line) is { Success: true, Groups: var svm })
                    {
                        shortOpt = svm[1].Value;
                        var value = svm[2].Value;
                        remaining = svm[3].Value;

                        Debug.Write($"\x1b[35m{shortOpt}");
                        Debug.WriteIf(!string.IsNullOrEmpty(value), $"\x1b[43m{value}\x1b[40m");
                        Debug.Write($"\x1b[0m");
                    }
                    else
                    {
                        Debug.WriteLine($"\x1b[31m{line}\x1b[0m");
                        continue;
                    }

                    var (prms, desc) = SplitDescription(remaining);
                    Debug.Write(prms);

                    if (string.IsNullOrEmpty(desc))
                    {
                        Debug.WriteLine("");
                        prev = true;
                    }
                    else
                    {
                        Debug.WriteLine($"\x1b[32m{desc}\x1b[0m");
                        AddDescription(desc, longOpt, shortOpt);
                    }
                }
                else
                {
                    Debug.WriteLine(line);
                }
            }
        }

#if DEBUG
        (string Removed, string Colored) TrimBracket(string text)
        {
            var removed = new StringBuilder(text.Length);
            var colored = new StringBuilder(text.Length);
            int cnt = 0;
            for (int i = 0; i < text.Length; i++)
            {
                var c = text[i];
                if (c == '[')
                {
                    if (cnt == 0) { colored.Append("\x1b[43m"); }
                    ++cnt;
                }

                if (cnt == 0)
                {
                    removed.Append(c);
                }
                colored.Append(c);

                if (c == ']')
                {
                    --cnt;
                    if (cnt == 0) { colored.Append("\x1b[40m"); }
                }
            }

            return (removed.ToString(), colored.ToString());
        }
#else
        string TrimBracket(string text)
        {
            var removed = new StringBuilder(text.Length);
            int cnt = 0;
            for (int i = 0; i < text.Length; i++)
            {
                var c = text[i];
                if (c == '[')
                {
                    ++cnt;
                }

                if (cnt == 0)
                {
                    removed.Append(c);
                }

                if (c == ']')
                {
                    --cnt;
                }
            }

            return removed.ToString();
        }
#endif

#if false
        else { break }
#endif

        static (string Removed, string Remaining) SplitDescription(string text)
        {
            var removed = new StringBuilder(text.Length);
            while (text.Length > 0)
            {
                // leadingSpace
                int leadingSpace = -1;
                for (int i = 0; i < text.Length; i++)
                {
                    if (!char.IsWhiteSpace(text[i])) break;
                    leadingSpace = i;
                }
                if (++leadingSpace > 0)
                {
                    removed.Append(text, 0, leadingSpace);
                    text = text.Substring(leadingSpace);
                }
                else if (text.StartsWith("<"))
                {
                    text = RemoveLeadingBracket(text, removed, '<', '>');
                    if (text.Length <= 1)
                    {
                        removed.Append(text);
                        text = "";
                    }
                }
                else if (text.StartsWith("["))
                {
                    text = RemoveLeadingBracket(text, removed, '[', ']');
                }
                else if (text.StartsWith("(+|-)x"))
                {
                    removed.Append("(+|-)x");
                    text = text.Substring("(+|-)x".Length);
                }
                else if (text == "...")
                {
                    removed.Append("...");
                    text = "";
                }
                else if (bracketOptionRegex.Match(text) is { Success: true, Groups: var bm })
                {
                    removed.Append(bm[1].Value);
                    text = bm[3].Value;
                }
                else break;
            }
            return (removed.ToString(), text);
        }

        static string RemoveLeadingBracket(string text, StringBuilder removed, char begin, char end)
        {
            int cnt = 0;
            int i;
            for (i = 0; i < text.Length; i++)
            {
                var c = text[i];
                if (c == begin) ++cnt;
                if (cnt == 0) break;
                removed.Append(c);
                if (c == end) --cnt;
            }

            return text.Substring(i);
        }

        void AddDescription(string description, string? longOpt, string? shortOpt)
        {
            if (!string.IsNullOrEmpty(longOpt))
            {
                longDescriptions[longOpt!] = description;
            }
            if (!string.IsNullOrEmpty(shortOpt))
            {
                if (shortOpt == "-NUM")
                {
                    for (int i = 0; i < 10; i++)
                    {
                        shortDescriptions[(char)(i + '0')] = description.Replace("NUM", $"{i}");
                    }
                }
                else
                {
                    shortDescriptions[shortOpt![0]] = description;
                }
            }
        }
    }
}

internal readonly record struct GitHelpShortOption(char Key, string Description);
internal class GitHelpOptions(string subcommand, Dictionary<string, string> longOption, Dictionary<char, string> shortOption)
{
    public string Subcommand { get; } = subcommand;
    private readonly Dictionary<string, string> longOption = longOption;
    private readonly Dictionary<char, string> shortOption = shortOption;

    private GitHelpShortOption[]? _ShortOptions;
    public GitHelpShortOption[] ShortOptions => _ShortOptions ??= ListShortOptions();
    private GitHelpShortOption[] ListShortOptions()
    {
        var result = shortOption
            .Select(t => new GitHelpShortOption(t.Key, t.Value))
            .OrderBy(t => t.Key)
            .ToArray();
        return result;
    }

    public string? Description(string key)
    {
        longOption.TryGetValue(key, out var result);
        return result;
    }
}
internal class GitHelp
{
    private readonly Dictionary<string, GitHelpOptions> options;
    public GitHelp(GitHelpOptions[] options)
    {
        this.options = new(options.Length);
        foreach (var option in options)
        {
            this.options[option.Subcommand] = option;
        }
    }

    public GitHelpShortOption[] ShortOptions(string subcommand)
    {
        if (!options.TryGetValue(subcommand, out var option))
        {
            options.TryGetValue("", out option);
        }
        return option?.ShortOptions ?? [];
    }

    public string? Description(string subcommand, string longOption)
    {
        if (options.TryGetValue(subcommand, out var option))
        {
            if (option.Description(longOption) is string description)
                return description;
        }
        if (options.TryGetValue("", out option))
            return option.Description(longOption);
        return null;
    }
}