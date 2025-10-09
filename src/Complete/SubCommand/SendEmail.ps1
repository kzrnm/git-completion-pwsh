# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-send-email {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Current = $Context.CurrentWord()
    if (!$Context.HasDoubledash()) {
        $shortOpts = Get-GitShortOptions $Context.Command -Current $Current
        if ($shortOpts) { return $shortOpts }

        $prevCandidates = switch -CaseSensitive -Regex ($Context.PreviousWord()) {
            '^--(to|cc|bcc|from)$' { @(__git send-email --dump-aliases) }
            '^--smtp-encryption$' { 'ssl', 'tls' }
            '^--suppress-cc$' { $gitSendEmailSuppressccOptions | completeList -Current $Current -ResultType ParameterValue; return }
            '^--confirm$' { $gitSendEmailConfirmOptions | completeList -Current $Current -ResultType ParameterValue; return }
        }

        if ($prevCandidates) {
            $prevCandidates | completeList -Current $Current -ResultType ParameterValue
            return
        }

        if ($Current -cmatch '(--[^=]+)=(.*)') {
            $key = $Matches[1]
            $value = $Matches[2]
            $candidates = switch -CaseSensitive -Regex ($key) {
                '^--thread$' { 'deep', 'shallow' }
                '^--(to|cc|bcc|from)$' { @(__git send-email --dump-aliases) }
                '^--smtp-encryption$' { 'ssl', 'tls' }
                '^--suppress-cc$' { $gitSendEmailSuppressccOptions | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue; return }
                '^--confirm$' { $gitSendEmailConfirmOptions | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue; return }
            }

            if ($candidates) {
                $candidates | completeList -Current $value -Prefix "$key=" -ResultType ParameterValue
                return
            }
        }

        if ($Current.StartsWith('--')) {
            $gitFormatPatchExtraOptions | completeList -Current $Current -DescriptionBuilder { 
                Get-GitOptionsDescription $_ 'send-email'
            }
            @(gitResolveBuiltins $Context.Command) | completeList -Current $Current -DescriptionBuilder {
                Get-GitOptionsDescription $_ 'send-email'
            }
            return
        }
    }

    gitCompleteRevlist $Current
}
