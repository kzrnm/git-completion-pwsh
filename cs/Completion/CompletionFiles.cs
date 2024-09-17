// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using Kzrnm.GitCompletion.Context;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Text.RegularExpressions;

namespace Kzrnm.GitCompletion.Completion;
public static class CompletionFiles
{
    static readonly Regex specialCharRegex = new(@"[""'`\s]", RegexOptions.CultureInvariant);
    public static string EscapeSpecialChar(this string text)
        => specialCharRegex.Replace(text, "`$1");
    public static IEnumerable<CompletionResult> CompleteCurrentDirectory(ProviderIntrinsics invokeProvider, string current, string prefix = "")
    {
        var lx = current.LastIndexOfAny([Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar]);
        var left = current.Substring(0, lx + 1).EscapeSpecialChar();

        return invokeProvider.ChildItem.Get($"{current}*", false)
            .Select(p => p.BaseObject)
            .OfType<FileSystemInfo>()
            .Select(p =>
            {
                var suffix = (p is DirectoryInfo) ? "/" : "";
                return new CompletionResult(
                    $"{prefix}{left}{p.Name.EscapeSpecialChar()}{suffix}",
                    $"{p.Name}{suffix}",
                    CompletionResultType.ProviderItem,
                    p.FullName);
            });
    }

    /// <summary>
    /// complete index files by ls-file.
    /// __git_complete_index_file
    /// </summary>
    /// <param name="context"></param>
    /// <param name="current"></param>
    /// <param name="options"></param>
    /// <param name="exclude"></param>
    /// <param name="leadingDash"></param>
    /// <returns></returns>
    public static IEnumerable<CompletionResult> CompleteIndexFile(
        CompletionContext context,
        string current,
        IndexFilesOptions options,
        IEnumerable<string>? exclude = null,
        bool leadingDash = false)
    {
        string baseDir;
        if (current.LastIndexOfAny([Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar]) is >= 0 and var ix)
        {
            baseDir = current.Substring(0, ix + 1);
            current = current.Substring(ix + 1);
        }
        else
        {
            baseDir = "";
        }

        var filter = new HashSet<string>(exclude.Select(context.GetUnresolvedProviderPathFromPSPath));
        string? prev = null;
        var list = new List<CompletionResult>();
        foreach (var path in context.GitIndexFiles(current, baseDir, options))
        {
            if (filter.Contains(context.GetUnresolvedProviderPathFromPSPath(path))) continue;
            if (prev == null)
            {
                prev = path;
            }
            else
            {
                var commonPrefixLength = baseDir.Length;
                for (int i = commonPrefixLength; i < prev.Length; i++)
                {
                    if (path[i] != prev[i])
                    {
                        if (commonPrefixLength > baseDir.Length)
                        {
                            prev = prev.Substring(0, commonPrefixLength);
                        }
                        else
                        {
                            var completion = (!leadingDash && prev.StartsWith("-")) ? $"./{prev}" : prev;
                            list.Add(new(completion.EscapeSpecialChar(), prev, CompletionResultType.ProviderItem, prev));
                            prev = path;
                        }
                        break;
                    }
                    else if (path[i] == Path.DirectorySeparatorChar || path[i] == Path.AltDirectorySeparatorChar)
                    {
                        commonPrefixLength = i + 1;
                    }
                }
            }
        }

        if (prev != null)
        {
            var completion = (!leadingDash && prev.StartsWith("-")) ? $"./{prev}" : prev;
            list.Add(new(completion.EscapeSpecialChar(), prev, CompletionResultType.ProviderItem, prev));
        }

        return list;
    }
}