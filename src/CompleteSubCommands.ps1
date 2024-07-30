[System.Management.Automation.CompletionResult[]]
function CompleteSubCommands {
    

	# __git_complete_command "$command" && return

	# local expansion=$(__git_aliased_command "$command")
	# if [ -n "$expansion" ]; then
	# 	words[1]=$expansion
	# 	__git_complete_command "$expansion"
	# fi
    return $null
}