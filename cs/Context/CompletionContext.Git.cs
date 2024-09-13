// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using Kzrnm.GitCompletion.Context.GitCommand;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Runtime.CompilerServices;
using System.Text;

namespace Kzrnm.GitCompletion.Context;
public partial class CompletionContext
{
    const int gitCommandWaitMilliseconds = 1000;

    [System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE0044")]
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Style", "IDE0251")]
    [InterpolatedStringHandler]
    //[DebuggerStepThrough]
    internal struct CommandLineHandler
    {
        StringBuilder sb;

        public CommandLineHandler(int literalLength, int formattedCount)
        {
            sb = new StringBuilder(literalLength + formattedCount);
        }

        public CommandLineHandler(int literalLength, int formattedCount, CompletionContext context)
        {
            sb = new StringBuilder(literalLength + formattedCount);
            if (context.gitDir != null)
            {
                sb.Append("--git-dir ");
                sb.AppendArgument(context.gitDir);
                sb.Append(' ');
                sb.Append(context.gitCArgs);
                sb.Append(' ');
            }
            else if (context.gitCArgs.Length > 0)
            {
                sb.Append(context.gitCArgs);
                sb.Append(' ');
            }
        }

        public CommandLineHandler(int literalLength, int formattedCount, CompletionContext context, string overrideGitDir)
        {
            sb = new StringBuilder(literalLength + formattedCount);
            sb.Append("--git-dir ");
            sb.AppendArgument(overrideGitDir);
            sb.Append(' ');
            sb.Append(context.gitCArgs);
            sb.Append(' ');
        }
        public void AppendLiteral(string s) => sb.Append(s);
        public void AppendFormatted(string? x)
        {
            if (x == null) return;
            sb.AppendArgument(x);
            sb.Append(' ');
        }
        public void AppendFormatted(string[]? args)
        {
            if (args == null) return;
            foreach (var arg in args)
            {
                AppendFormatted(arg);
            }
        }
        public void AppendFormatted(IEnumerable<string>? args)
        {
            if (args == null) return;
            foreach (var arg in args)
            {
                AppendFormatted(arg);
            }
        }
        public void AppendFormatted<T>(T x)
        {
            if (x == null) return;
            sb.AppendArgument(x.ToString());
            sb.Append(' ');
        }

        public override string ToString()
        {
            return sb.ToString();
        }
    }

    internal Process GitRaw(string args, bool stderr)
    {
        var pi = new ProcessStartInfo
        {
            CreateNoWindow = true,
            WorkingDirectory = cmdlet.SessionState.Path.CurrentLocation.Path,
            FileName = "git",
            Arguments = args,
        };

        if (stderr)
        {
            pi.RedirectStandardError = true;
            pi.StandardErrorEncoding = Encoding.UTF8;
        }
        else
        {
            pi.RedirectStandardOutput = true;
            pi.StandardOutputEncoding = Encoding.UTF8;
        }

        var p = Process.Start(pi);
        p.WaitForExit(gitCommandWaitMilliseconds);

        return p;
    }
    internal Process Git(string args, bool stderr = false)
    {
        return GitRaw(args, stderr: stderr);
    }


    internal Process Git(
        [InterpolatedStringHandlerArgument("")]
        CommandLineHandler args,
        bool stderr = false)
    {
        return GitRaw(args.ToString(), stderr: stderr);
    }
    internal Process Git(
#pragma warning disable IDE0060
        string overrideGitDir,
#pragma warning restore IDE0060
        [InterpolatedStringHandlerArgument("", "overrideGitDir")]
        CommandLineHandler args,
        bool stderr = false)
    {
        return GitRaw(args.ToString(), stderr: stderr);
    }

    private string FindGitRepoPath()
    {
        if (gitCArgs != null)
        {
            using var p = Git("rev-parse --absolute-git-dir", stderr: false);
            return p.StandardOutput.ReadLine();
        }
        else if (gitDir != null)
        {
            return gitDir;
        }
        else if (Environment.GetEnvironmentVariable("GIT_DIR") is { Length: > 0 } envGitDir)
        {
            return envGitDir;
        }
        else if (Directory.Exists(".git"))
        {
            return ".git";
        }
        else
        {
            using var p = Git("rev-parse --git-dir", stderr: true);
            return p.StandardError.ReadLine();
        }
    }

    private string? _repoPath;
    public string RepoPath => _repoPath ??= FindGitRepoPath();
}
