function completeList {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]
        $Candidates
    )
    $Candidates |
    Where-Object {
        if (-not $script:CurrentWord) {
            return $true
        }
        elseif ($_ -is [System.Management.Automation.CompletionResult]) {
            $name = $_.ListItemText
        }
        else {
            $name = $_
        }
        $name.StartsWith($script:CurrentWord)
    } |
    ForEach-Object { 
        [System.Management.Automation.CompletionResult]::new(
            "$_",
            "$_",
            "ParameterName",
            "$_"
        )
    }
}

# Generates completion reply, appending a space to possible completion words,
# if necessary.
# It accepts 1 to 4 arguments:
# 1: List of possible completion words.
# 2: A prefix to be added to each possible completion word (optional).
# 3: Generate possible completion matches for this word (optional).
# 4: A suffix to be appended to each possible completion word (optional).
function __gitcomp {
    [OutputType([System.Management.Automation.CompletionResult[]])]
    param(
        [string]$Current = $null,
        [string]$Prefix = '',
        [string]$Suffix = '',
        [Parameter(ValueFromRemainingArguments)]
        [string[]]
        $Candidates
    )

    if (-not $Current) {
        $Current = $script:CurrentWord
    }

    $gitOptionsDecriptionTable[$command]

    switch -Wildcard ($Current) {
        '*=' {  
            return @()
        }
        '--no-*' {

        }
    }
    
    # case "$cur_" in
    # *=)
    # 	;;
    # --no-*)
    # 	local c i=0 IFS=$' \t\n'
    # 	for c in $1; do
    # 		if [[ $c == "--" ]]; then
    # 			continue
    # 		fi
    # 		c="$c${4-}"
    # 		if [[ $c == "$cur_"* ]]; then
    # 			case $c in
    # 			--*=|*.) ;;
    # 			*) c="$c " ;;
    # 			esac
    # 			COMPREPLY[i++]="${2-}$c"
    # 		fi
    # 	done
    # 	;;
    # *)
    # 	local c i=0 IFS=$' \t\n'
    # 	for c in $1; do
    # 		if [[ $c == "--" ]]; then
    # 			c="--no-...${4-}"
    # 			if [[ $c == "$cur_"* ]]; then
    # 				COMPREPLY[i++]="${2-}$c "
    # 			fi
    # 			break
    # 		fi
    # 		c="$c${4-}"
    # 		if [[ $c == "$cur_"* ]]; then
    # 			case $c in
    # 			*=|*.) ;;
    # 			*) c="$c " ;;
    # 			esac
    # 			COMPREPLY[i++]="${2-}$c"
    # 		fi
    # 	done
    # 	;;
    # esac
}