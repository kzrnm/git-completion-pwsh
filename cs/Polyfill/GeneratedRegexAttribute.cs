// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
#pragma warning disable IDE0130
using System.Threading;

namespace System.Text.RegularExpressions;
#pragma warning restore IDE0130

/// <summary>Initializes a new instance of the <see cref="GeneratedRegexAttribute"/> with the specified pattern and options.</summary>
/// <param name="pattern">The regular expression pattern to match.</param>
/// <param name="options">A bitwise combination of the enumeration values that modify the regular expression.</param>
[AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = false)]
internal sealed class GeneratedRegexAttribute(string pattern, RegexOptions options) : Attribute
{
    /// <summary>Initializes a new instance of the <see cref="GeneratedRegexAttribute"/> with the specified pattern.</summary>
    /// <param name="pattern">The regular expression pattern to match.</param>
    public GeneratedRegexAttribute(string pattern) : this(pattern, RegexOptions.None)
    {
    }

    public string Pattern { get; } = pattern;
    public RegexOptions Options { get; } = options;
    public int MatchTimeoutMilliseconds => Timeout.Infinite;
    public string CultureName => "";
}
