// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
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
}