// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Management.Automation;
using System.Text;
using System.Threading;

namespace Kzrnm.GitCompletion.Context;

public partial class CompletionContext
{
    private readonly PSCmdlet cmdlet;
    public SessionState SessionState => cmdlet.SessionState;
    public CommandInvocationIntrinsics InvokeCommand => cmdlet.InvokeCommand;
    public ProviderIntrinsics InvokeProvider => cmdlet.InvokeProvider;

    public GitCompletionSettings Settings { get; }

    private string[] words;

    public string Word(int index) => words[index];
    public int WordCount => words.Length;
    public int CurrentIndex { get; private set; }
    public int CommandIndex { get; private set; } = -1;
    public int SubcommandLikeIndex { get; private set; } = -1;
    public int DoubledashIndex { get; private set; } = -1;

    public string CurrentWord
    {
        get
        {
            int ix = CurrentIndex;
            Debug.Assert((uint)ix < (uint)words.Length);
            return words[ix];
        }
    }
    public string? PreviousWord
    {
        get
        {
            int ix = CurrentIndex - 1;
            if ((uint)ix < (uint)words.Length)
            {
                return words[ix];
            }
            return null;
        }
    }

    public string? Command
    {
        get
        {
            int ix = CommandIndex;
            if ((uint)ix < (uint)words.Length)
            {
                return words[ix];
            }
            return null;
        }
    }

    public string? Subcommand
    {
        get
        {
            int ix = SubcommandLikeIndex;
            if ((uint)ix < (uint)words.Length)
            {
                return words[ix];
            }
            return null;
        }
    }

    public string? SubcommandWithoutGlobalOption
    {
        get
        {
            int ix = SubcommandLikeIndex;
            if ((uint)ix < (uint)words.Length && ix == CommandIndex + 1)
            {
                return words[ix];
            }
            return null;
        }
    }

    // __git_has_doubledash
    public bool HasDoubledash => DoubledashIndex < CurrentIndex;

    private string? gitDir = null;
    private string gitCArgs = "";

    public CompletionContext(PSCmdlet psCmdlet, GitCompletionSettings? settings, string[] words, int currentIndex)
    {
        cmdlet = psCmdlet;
        Settings = settings ?? GitCompletionSettings.Default;
        if ((uint)currentIndex >= words.Length)
        {
            Throw();
        }
        CurrentIndex = currentIndex;
        this.words = words;
        InitWords(1);

        static void Throw()
        {
            throw new ArgumentOutOfRangeException(nameof(currentIndex));
        }
    }

    private void InitWords(int start)
    {
        var cArgsBuilder = new StringBuilder();
        if (gitCArgs.Length > 0)
        {
            cArgsBuilder.Append(gitCArgs);
        }
        int i = start;
        for (; i < words.Length; i++)
        {
            if (i == CurrentIndex) continue;
            var s = words[i];
            if (s is "--")
            {
                DoubledashIndex = i++;
                break;
            }
            else if (CommandIndex < 0)
            {
                if (s is "--git-dir")
                {
                    if (++i < words.Length && i != CurrentIndex)
                    {
                        var sb = new StringBuilder(s.Length);
                        sb.AppendArgument(s);
                        gitDir = sb.ToString();
                    }
                }
                else if (s.StartsWith("--git-dir="))
                {
                    var sb = new StringBuilder(s.Length);
                    sb.AppendArgument(s, 10);
                    gitDir = sb.ToString();
                }
                else if (s is "--bare")
                {
                    gitDir = ".";
                }
                else if (s is "--help")
                {
                    if (i < CurrentIndex)
                    {
                        words[i] = "help";
                        CommandIndex = i;
                    }
                    ++i;
                    break;
                }
                else if (s is "--work-tree" or "--namespace") { ++i; }
                else if (s is "-c" or "-C")
                {
                    if (i == CurrentIndex) continue;
                    else if (++i < words.Length && i != CurrentIndex)
                    {
                        var t = words[i];
                        if (cArgsBuilder.Length > 0)
                            cArgsBuilder.Append(' ');
                        cArgsBuilder.Append(s);
                        cArgsBuilder.Append(' ');
                        cArgsBuilder.AppendArgument(t);
                    }
                }
                else if (s.StartsWith("-")) { }
                else
                {
                    if (i < CurrentIndex)
                    {
                        CommandIndex = i;
                    }
                    ++i;
                    break;
                }
            }
        }

        gitCArgs = cArgsBuilder.ToString();

        if (DoubledashIndex >= 0) return;
        if (CommandIndex < 0)
        {
            DoubledashIndex = words.Length;
            return;
        }

        for (; i < CurrentIndex; i++)
        {
            var s = words[i];
            if (s is "--")
            {
                DoubledashIndex = i++;
                break;
            }
            else if (s.StartsWith("-")) { }
            else
            {
                SubcommandLikeIndex = i++;
                break;
            }
        }

        if (DoubledashIndex >= 0) return;

        for (; i < words.Length; i++)
        {
            var s = words[i];
            if (i == CurrentIndex) continue;
            if (s is "--")
            {
                DoubledashIndex = i;
                break;
            }
        }

        if (DoubledashIndex < 0)
        {
            DoubledashIndex = words.Length;
        }
    }

    public void AppendGitArguments(StringBuilder stringBuilder, string? overrideGitDir = null)
    {
        var gitDir = overrideGitDir ?? this.gitDir;
        if (gitDir != null)
        {
            stringBuilder.Append("--git-dir ");
            stringBuilder.AppendArgument(gitDir);
            stringBuilder.Append(' ');
        }
        if (gitCArgs.Length > 0)
        {
            stringBuilder.Append(gitCArgs);
            stringBuilder.Append(' ');
        }
    }

    public void ResolveAlias()
    {
        // Avoid infinite loop
        for (int i = 0; Command != null && i < 20; i++)
        {
            string alias;
            using (var p = Git($"config --get {"alias." + Command}"))
            {
                if (p.ExitCode != 0) return;
                alias = p.StandardOutput.ReadToEnd();
            }
            if (alias.Length == 0) return;

            using (var p = GitRaw($"-c {"alias.cmp-shell-args=!printf '%s\\n' " + alias.Replace('\n', ' ')} cmp-shell-args"))
            {
                if (p.ExitCode != 0) return;

                var list = new List<string>();
                while (p.StandardOutput.ReadLine() is string line)
                {
                    list.Add(line);
                }
                ReplaceCommand(list);
            }
        }
    }

    internal void ReplaceCommand(IList<string> newCommand)
    {
        int ix = CommandIndex;
        Debug.Assert((uint)ix < (uint)words.Length);

        int additionalSize = newCommand.Count - 1;
        if (newCommand.Count == 1)
        {
            words[ix] = newCommand[0];
            return;
        }

        var newWords = new string[words.Length + additionalSize];
        Array.Copy(words, 0, newWords, 0, ix);
        newCommand.CopyTo(newWords, ix);
        Array.Copy(words, ix + 1, newWords, ix + newCommand.Count, words.Length - ix - 1);

        words = newWords;
        CurrentIndex += additionalSize;
        CommandIndex = -1;
        SubcommandLikeIndex = -1;
        DoubledashIndex = -1;
        InitWords(ix);
    }

    public string GetUnresolvedProviderPathFromPSPath(string path)
        => SessionState.Path.GetUnresolvedProviderPathFromPSPath(path);
}
