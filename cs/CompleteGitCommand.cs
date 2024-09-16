// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using Kzrnm.GitCompletion.Completion;
using Kzrnm.GitCompletion.Context;
using System.Collections.Generic;
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
        /*
        if ($Current -eq '-') {
            $gitGlobalOptions | ForEach-Object { $_.ToShortCompletion() } | Where-Object { $_ }
            return
        }
        elseif ($Current -like '--*') {
            $gitGlobalOptions | ForEach-Object { $_.ToLongCompletion($Current) } | Where-Object { $_ }
            return
        }

        $aliases = @{}
        foreach ($a in (gitListAliases)) {
            $aliases[$a.Name] = "[alias] $($a.Value)"
        }

        listCommands | completeList -Current $Current -DescriptionBuilder {
            $a = $aliases[$_]
            if ($a) {
                $a
            }
            else {
                Get-GitCommandDescription $_ 
            }
        } -ResultType Text  
         */
        return [];

        //for (int i = 0; i < context.WordCount; i++)
        //{
        //    if (context.Word(i) is { Length: > 0 } s)
        //        yield return new(s);
        //}
    }

}
