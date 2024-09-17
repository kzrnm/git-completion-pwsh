// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using Kzrnm.GitCompletion.Completion;
using Kzrnm.GitCompletion.Completion.Completer;
using Kzrnm.GitCompletion.Context;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Management.Automation;

namespace Kzrnm.GitCompletion;

[Cmdlet(VerbsLifecycle.Complete, "Git")]
[OutputType(typeof(CompletionResult[]))]
public class CompleteGitCommand : CompleteGitCommandBase
{
    protected override IEnumerable<CompletionResult> Complete(CompletionContext context)
    {
        context.ResolveAlias();
        if (context.Command != null)
        {
            return SubcommandSelector.CompleteSubcommand(context);
        }

        switch (context.PreviousWord)
        {
            case "-C":
            case "--work-tree":
            case "--git-dir":
            case "--":
                // these need a path argument
                return [];
            case "--namespace":
                // we don't support completing these options' arguments
                return [];
            case "-c":
                return GitConfigVariable.CompleteConfigOptionVariableNameAndValue(context, context.CurrentWord);
            default:
                break;
        }

        if (context.CurrentWord == "-")
        {
            return GlobalOptions
                .Select(g => g.ToShortCompletion())
                .OfType<CompletionResult>()
                .Where(c => c.CompletionText.StartsWith(context.CurrentWord));
        }
        if (context.CurrentWord.StartsWith("--"))
        {
            return GlobalOptions
                .Select(g => g.ToLongCompletion())
                .OfType<CompletionResult>()
                .Where(c => c.CompletionText.StartsWith(context.CurrentWord));
        }

        var aliases = context.GitListAliases().ToDictionary(t => t.Name, t => $"[alias] {t.Value}");

        return StringCompleter.Create(context.CurrentWord, CompletionResultType.Text, DescriptionBuilder: new CommandDescriptionBuilder(context, aliases))
            .Complete(context.ListCommands());
    }

    readonly struct CommandDescriptionBuilder(CompletionContext Context, Dictionary<string, string> aliases) : IDescriptionBuilder
    {
        public Dictionary<string, string> Aliases { get; } = aliases;

        public string? Description(string candidate)
        {
            if (Aliases.TryGetValue(candidate, out var result))
            {
                return result;
            }
            return Context.GitCommandDescription(candidate);
        }
    }

    readonly record struct GlobalOption(string? Long = null, string? Short = null, string? Value = null, string? Description = null)
    {
        public CompletionResult? ToLongCompletion()
            => Long switch
            {
                { } p => new(
                    p,
                    p + Value switch
                    {
                        { } v => $" {v}",
                        _ => "",
                    },
                    CompletionResultType.ParameterName,
                    Description switch
                    {
                        { } d => d,
                        _ => p
                    }
                ),
                _ => null,
            };
        public CompletionResult? ToShortCompletion()
            => Short switch
            {
                { } p => new(
                    p,
                    p + Value switch
                    {
                        { } v => $" {v}",
                        _ => "",
                    },
                    CompletionResultType.ParameterName,
                    Description switch
                    {
                        { } d => d,
                        _ => p
                    }
                ),
                _ => null,
            };
    }

    static GlobalOption[] GlobalOptions => [
        new GlobalOption{
            Short ="-v",
            Long ="--version",
            Description= @"Prints the Git suite version",
        },
        new GlobalOption{
            Short = "-h",
            Long="--help" ,
            Description=@"Prints the helps. If --all is given then all available commands are printed"
        },
        new GlobalOption{
            Short = "-C",
            Value="<path>" ,
            Description=@"Run as if git was started in <path> instead of the current working directory"
        },
        new GlobalOption{
            Short = "-c",
            Value="<name>=<value>" ,
            Description=@"Pass a configuration parameter to the command"
        },
        new GlobalOption{
            Long="--config-env",
            Value="<name>=<envvar>" ,
            Description=@"Like -c <name>=<value>, give configuration variable <name> a value, where <envvar> is the name of an environment variable from which to retrieve the value"
        },
        new GlobalOption{
            Long="--exec-path",
            Value="<path>" ,
            Description=@"Path to wherever your core Git programs are installed"
        },
        new GlobalOption{
            Long="--html-path" ,
            Description=@"Print the path, without trailing slash, where Git’s HTML documentation is installed and exit"
        },
        new GlobalOption{
            Long="--man-path" ,
            Description=@"Print the manpath for the man pages for this version of Git and exit"
        },
        new GlobalOption{
            Long="--info-path" ,
            Description=@"Print the path where the Info files documenting this version of Git are installed and exit"
        },
        new GlobalOption{
            Short = "-p",
            Long="--paginate" ,
            Description=@"Pipe all output into less (or if set, $PAGER) if standard output is a terminal"
        },
        new GlobalOption{
            Short = "-P",
            Long="--no-pager" ,
            Description=@"Do not pipe Git output into a pager"
        },
        new GlobalOption{
            Long="--git-dir" ,
            Description=@"Set the path to the repository ("".git"" directory)"
        },
        new GlobalOption{
            Long="--work-tree",
            Value="<path>" ,
            Description=@"Set the path to the working tree"
        },
        new GlobalOption{
            Long="--namespace",
            Value="<path>" ,
            Description=@"Set the Git namespace"
        },
        new GlobalOption{
            Long="--bare" ,
            Description=@"Treat the repository as a bare repository"
        },
        new GlobalOption{
            Long="--no-replace-objects" ,
            Description=@"Do not use replacement refs to replace Git objects"
        },
        new GlobalOption{
            Long="--no-lazy-fetch" ,
            Description=@"Do not fetch missing objects from the promisor remote on demand"
        },
        new GlobalOption{
            Long="--literal-pathspecs" ,
            Description=@"Treat pathspecs literally (i.e. no globbing, no pathspec magic)"
        },
        new GlobalOption{
            Long="--glob-pathspecs" ,
            Description=@"Add ""glob"" magic to all pathspec"
        },
        new GlobalOption{
            Long="--noglob-pathspecs" ,
            Description=@"Add ""literal"" magic to all pathspec"
        },
        new GlobalOption{
            Long="--icase-pathspecs" ,
            Description=@"Add ""icase"" magic to all pathspec"
        },
        new GlobalOption{
            Long="--no-optional-locks" ,
            Description=@"Do not perform optional operations that require locks"
        },
        new GlobalOption{
            Long="--list-cmds",
            Value="<group>[,<group>…​]" ,
            Description=@"List commands by group"
        },
        new GlobalOption{
            Long="--no-replace-objects" ,
            Description=@"List commands by group"
        },
        new GlobalOption{
            Long ="--attr-source",
            Value="<tree-ish>" ,
            Description=@"Read gitattributes from <tree-ish> instead of the worktree"
        }
    ];
}
