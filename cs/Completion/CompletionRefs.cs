// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using Kzrnm.GitCompletion.Completion.Completer;
using Kzrnm.GitCompletion.Context;
using System.Collections.Generic;
using System.Management.Automation;
using System.Text.RegularExpressions;

namespace Kzrnm.GitCompletion.Completion;
public static class CompletionRefs
{
    static readonly Regex prefixRevlistRegex = new(@"^(?<prefix>.*\.{2,3}.*:)(?<file>.*)", RegexOptions.CultureInvariant);
    static readonly Regex prefixRefRegex = new(@"^(?<ref>[^:]+):(?<file>.*)", RegexOptions.CultureInvariant);
    static readonly Regex revlistRegex = new(@"^(?<prefix>.*\.{2,3})(?<current>.*)", RegexOptions.CultureInvariant);
    static readonly Regex filepathRegex = new(@"^(?<prefix>.+)/(?<current>[^/]*)", RegexOptions.CultureInvariant);

    // __git_complete_revlist
    // __git_complete_file
    // __git_complete_revlist_file
    public static IEnumerable<CompletionResult> CompleteRevlist(CompletionContext context)
    {
        var current = context.CurrentWord;
        if (prefixRevlistRegex.Match(current) is { Success: true, Groups: var m1 })
        {
            return CompletionFiles.CompleteCurrentDirectory(context.InvokeProvider, m1["file"].Value, m1["prefix"].Value);
        }

        string prefix;
        if (prefixRefRegex.Match(current) is { Success: true, Groups: var m2 })
        {
            var @ref = m2["ref"].Value;
            var currentFile = m2["file"].Value;
            var baseDir = "";
            string ls;
            if (currentFile.StartsWith("."))
            {
                return CompletionFiles.CompleteCurrentDirectory(context.InvokeProvider, currentFile, $"{@ref}:");
            }
            if (filepathRegex.Match(currentFile) is { Success: true, Groups: var m2f })
            {
                currentFile = m2f["current"].Value;
                baseDir = m2f["prefix"].Value;
                ls = $"{@ref}:{baseDir}";
                prefix = $"{ls}/";
            }
            else
            {
                ls = @ref;
                prefix = $"{@ref}:";
            }

            return new LocalFileCompleter(context.SessionState, currentFile, Prefix: prefix, BaseDir: baseDir, RemovePrefix: true)
                .Complete(context.LsTreeFiles(ls));
        }

        if (revlistRegex.Match(current) is { Success: true, Groups: var m3 })
        {
            current = m3["current"].Value;
            prefix = m3["prefix"].Value;
        }
        else
        {
            prefix = "";
        }

        return StringCompleter.Create(current, CompletionResultType.ParameterValue, prefix)
            .Complete(context.GitRefs(current));
    }
}