[System.Management.Automation.CompletionResult[]]
function CompleteSubCommands {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)][string] $Command
	)

	switch ($Command) {
		Default {
			if (" $(git --list-cmds=parseopt) ".Contains(" $Command ")) {
				CompleteSubCommandCommon $Command
				return
			}
		}
	}

	CompleteSubCommands (Resolve-GitAlias $Command -ActualCommand)
	return
}

[System.Management.Automation.CompletionResult[]]
function CompleteSubCommandCommon {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)][string] $Command
	)

	switch -Wildcard ($CurrentWord) {
		'--*' {
			$params = [string[]]@(gitResolveBuiltins $Command)
			gitcomp @params
		}
	}
}

$script:gitResolveBuiltinsCache = @{}
function gitResolveBuiltins {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory, Position = 0)][string] $Command
	)
	
	if ($script:gitResolveBuiltinsCache[$Command]) {
		return $script:gitResolveBuiltinsCache[$Command]
	}

	return $script:gitResolveBuiltinsCache[$Command] = ((__git $Command --git-completion-helper-all) -split '[ \t\n]' | Where-Object { $_ })
}