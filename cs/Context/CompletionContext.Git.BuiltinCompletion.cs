// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using System.Collections.Generic;

namespace Kzrnm.GitCompletion.Context;
public partial class CompletionContext
{
    // __git_resolve_builtins
    public string[] GitResolveBuiltins(string command, string? subcommand = null, bool? all = null, bool check = false)
    {
        if (check || GitSupportParseoptHelper(command))
        {
            return GitResolveBuiltinsImpl(command, subcommand, all ?? Settings.ShowAllOptions);
        }
        return [];
    }

    private Dictionary<string, string[]> _GitResolveBuiltinsImpl = new();
    // __git_resolve_builtins
    private string[] GitResolveBuiltinsImpl(string command, string? subcommand, bool all)
    {
        var key = $"{command}\0{subcommand}\0{(all ? '1' : '0')}";
        if (_GitResolveBuiltinsImpl.TryGetValue(key, out var result)) return result;
        var completionHelper = all ? "--git-completion-helper-all" : "--git-completion-helper";
        using var p = GitRaw($"{command} {subcommand} {completionHelper}");
        return _GitResolveBuiltinsImpl[key] = p.StandardOutput.ReadToEnd().SplitEmpty();
    }

    private static HashSet<string>? _GitSupportParseoptHelper;
    // __git_support_parseopt_helper
    private bool GitSupportParseoptHelper(string command)
    {
        if (_GitSupportParseoptHelper == null)
        {
            using var p = GitRaw("--list-cmds=parseopt", stderr: false);
            _GitSupportParseoptHelper = new(p.StandardOutput.ReadToEnd().SplitEmpty());
        }
        return _GitSupportParseoptHelper!.Contains(command);
    }
}