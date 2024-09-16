// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace Kzrnm.GitCompletion.Context;
public partial class CompletionContext
{
    static readonly Regex aliasRegex = new(@"^alias\.(\S+) (.*)", RegexOptions.CultureInvariant);
    public IEnumerable<(string Name, string Value)> GitListAliases()
    {
        using var p = Git(@"config --get-regexp ""^alias\.""");
        while (p.StandardOutput.ReadLine() is string line)
        {
            if (aliasRegex.Match(line) is { Success: true, Groups: var m })
            {
                yield return (m[1].Value, m[2].Value);
            }
        }
    }

    public string[] ListCommands()
    {
        string[] cmds = Settings.ShowAllCommand
            ? ["builtins", "list-mainporcelain", "others", "nohelpers", "alias", "list-complete", "config"]
            : ["list-mainporcelain", "others", "nohelpers", "alias", "list-complete", "config"];

        var commands = new HashSet<string>(GitAllCommands(cmds));
        commands.UnionWith(Settings.AdditionalCommands ?? []);
        commands.ExceptWith(Settings.ExcludeCommands ?? []);

        var result = commands.ToArray();
        Array.Sort(result, StringComparer.Ordinal);
        return result;
    }
}
