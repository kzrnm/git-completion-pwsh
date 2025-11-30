# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Management.Automation;

function Complete-GitSubCommand-sparse-checkout {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([CompletionResult[]])]
    param(
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    [string] $Subcommand = $Context.SubcommandWithoutGlobalOption()
    [string] $Current = $Context.CurrentWord()

    $subcommands = gitResolveBuiltins $Context.Command

    if (!$subcommand) {
        if (!$Context.HasDoubledash()) {
            if ($Current -eq '-') {
                $script:__helpCompletion
            }
            else {
                $subcommands | gitcomp -Current $Current -DescriptionBuilder { 
                    switch ($_) {
                        'list' { 'describe the directories or patterns' }
                        'init' { 'like set with no specified paths (deprecated)' }
                        'set' { 'enable the necessary sparse-checkout config settings' }
                        'add' { 'update the sparse-checkout file to include additional directories' }
                        'reapply' { 'reapply the sparsity pattern rules to paths in the working tree' }
                        'disable' { 'disable the core.sparseCheckout config setting' }
                        'check-rules' { 'check whether sparsity rules match one or more paths' }
                        'clean' { 'opportunistically remove files outside of the sparse-checkout definition' }
                    }
                }
            }
        }
        return
    }

    if (!$Context.HasDoubledash()) {
        $shortOpts = Get-GitShortOptions $Context.Command  $Subcommand -Current $Current
        if ($shortOpts) { return $shortOpts }

        if ($Current.StartsWith('--')) {
            gitCompleteResolveBuiltins $Context.Command $Subcommand -Current $Current
            return
        }
    }

    if ($Subcommand -cin 'add', 'set') {
        if (usingCone $Context) {
            sparseCheckoutDirectories $Current
        }
        else {
            sparseCheckoutSlashLeadingPaths $Current
        }
    }
}

# __gitcomp_directories
function sparseCheckoutDirectories {
    [CmdletBinding()]
    [OutputType([CompletionResult[]])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [AllowEmptyString()]
        [string]
        $Current
    )

    if ($Current -cmatch '^.*/') {
        $dir = $Matches[0]
    }
    else {
        $dir = './'
    }

    foreach ($line in (@(__git ls-tree -z '-d' --name-only HEAD "$dir") -split '\0')) {
        if ($line -and "$line".StartsWith($Current)) {
            [CompletionResult]::new(
                (escapeSpecialChar "$line/"),
                "$line/",
                'ProviderItem',
                "$line/"
            )
        }
    }
}

# __gitcomp_slash_leading_paths
function sparseCheckoutSlashLeadingPaths {
    [CmdletBinding()]
    [OutputType([CompletionResult[]])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [AllowEmptyString()]
        [string]
        $Current
    )

    # Since we are dealing with a sparse-checkout, subdirectories may not
    # exist in the local working copy.  Therefore, we want to run all
    # ls-files commands relative to the repository toplevel.
    $toplevel = "$(__git rev-parse --show-toplevel)/"

    # If the paths provided by the user already start with '/', then
    # they are considered relative to the toplevel of the repository
    # already.  If they do not start with /, then we need to adjust
    # them to start with the appropriate prefix.
    if ($Current.StartsWith('/')) {
        $Current = $Current.Substring(1)
        $Prefix = ''
    }
    else {
        [string]$Prefix = (__git rev-parse --show-prefix)
    }

    # Since sparse-index is limited to cone-mode, in non-cone-mode the
    # list of valid paths is precisely the cached files in the index.
    #
    # NEEDSWORK:
    #   1) We probably need to take care of cases where ls-files
    #      responds with special quoting.
    #   2) We probably need to take care of cases where ${cur} has
    #      some kind of special quoting.
    #   3) On top of any quoting from 1 & 2, we have to provide an extra
    #      level of quoting for any paths that contain a '*', '?', '\',
    #      '[', ']', or leading '#' or '!' since those will be
    #      interpreted by sparse-checkout as something other than a
    #      literal path character.
    # Since there are two types of quoting here, this might get really
    # complex.  For now, just punt on all of this...
    foreach ($line in (@(__git -C "$toplevel" ls-files -z --cached -- "${Prefix}${Current}*") -split '\0')) {
        if ($line) {
            [CompletionResult]::new(
                (escapeSpecialChar "/$line"),
                "/$line",
                'ProviderItem',
                "/$line"
            )
        }
    }
}

function usingCone {
    [OutputType([bool])]
    param (
        [CommandLineContext]
        [Parameter(Position = 0, Mandatory)]$Context
    )

    $hasConeOption = $false
    for ($i = $Context.DoubledashIndex - 1; $i -gt $Context.CommandIndex; $i--) {
        if ($Context.Words[$i] -ceq '--no-cone') {
            return $false
        }
        if ($Context.Words[$i] -ceq '--cone') {
            $hasConeOption = $true
        }
    }

    if (
        ((__git config get core.sparseCheckout) -ceq 'true') -and ((__git config core.sparseCheckoutCone) -ceq 'false') -and !$hasConeOption
    ) {
        return $false
    }

    return $true
}