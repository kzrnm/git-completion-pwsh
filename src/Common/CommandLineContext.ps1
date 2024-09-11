# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.IO;

class CommandLineContext {
    [string[]] $Words
    [DirectoryInfo] $gitDir
    [string] $Command
    [int] $CommandIndex
    [string[]] $gitCArgs

    [int] $CurrentIndex = -1
    [int] $SubcommandLikeIndex = -1
    [int] $DoubledashIndex = -1

    CommandLineContext (
        [string[]] $Words,
        [int] $CurrentIndex
    ) {
        $this.CurrentIndex = $CurrentIndex

        $this.gitDir = $null
        $this.gitCArgs = @()
        $this.Command = ''
        $this.InitWords($Words, 1)
    }

    hidden InitWords([string[]]$wds, [int]$start) {
        $this.Words = $wds
        :globalflag for ($i = $start; $i -lt $wds.Length; $i++) {
            if ($i -eq $this.CurrentIndex) { continue }
            $s = $wds[$i]
            switch -Wildcard -CaseSensitive ($s) {
                '--' {
                    $this.DoubledashIndex = $i
                    break globalflag
                }
                '--git-dir=*' {
                    $this.gitDir = [DirectoryInfo]::new($s.Substring('--git-dir='.Length))
                    continue
                }
                '--git-dir' {
                    ++$i
                    if (($i -lt $this.Words.Count) -and ($i -ne $this.CurrentIndex)) {
                        $this.gitDir = [DirectoryInfo]::new($this.Words[$i])
                    }
                    continue
                }
                '--bare' {
                    $this.gitDir = [DirectoryInfo]::new('.')
                    continue
                }
                '--help' {
                    if ($i -lt $this.CurrentIndex) {
                        $this.Command = 'help'
                        $this.CommandIndex = $i
                    }
                    break globalflag
                }
                { $_ -cin @('-c', '--work-tree', '--namespace') } {
                    ++$i
                    continue
                }
                '-C' {
                    $this.gitCArgs += @('-C', $this.Words[++$i])
                    continue
                }
                '-*' {
                    continue
                }
                default {
                    if ($i -lt $this.CurrentIndex) {
                        $this.Command = $s
                        $this.CommandIndex = $i
                    }
                    break globalflag
                }
            }
        }

        if ($this.DoubledashIndex -ge 0) { return }
        if ($this.CommandIndex -lt 0) { return }

        :subcommand for ($i++; $i -lt $this.CurrentIndex; $i++) {
            $s = $wds[$i]
            switch -Wildcard -CaseSensitive ($s) {
                '--' {
                    $this.DoubledashIndex = $i
                    break subcommand
                }
                '-*' { continue }
                default {
                    $this.SubcommandLikeIndex = $i
                    break subcommand
                }
            }
        }

        if ($this.DoubledashIndex -ge 0) { return }
        for ($i++; $i -lt $wds.Length; $i++) {
            if ($i -eq $this.CurrentIndex) { continue }
            if ($wds[$i] -eq '--') {
                $this.DoubledashIndex = $i
                break
            }
        }

        if ($this.DoubledashIndex -ge 0) { return }
        $this.DoubledashIndex = $wds.Length
    }

    [string] Subcommand() {
        if ($this.SubcommandLikeIndex -lt 0) { 
            return $null
        }
        return $this.Words[$this.SubcommandLikeIndex]
    }

    [string] SubcommandWithoutGlobalOption() {
        if ($this.SubcommandLikeIndex -ne $this.CommandIndex + 1) { 
            return $null
        }
        return $this.Words[$this.SubcommandLikeIndex]
    }

    [string] CurrentWord() { return $this.Words[$this.CurrentIndex] }
    [string] PreviousWord() { return $this.Words[$this.CurrentIndex - 1] }

    # __git_has_doubledash
    [bool] HasDoubledash() {
        return $this.DoubledashIndex -lt $this.CurrentIndex
    }

    [bool] ReplaceCommand([string[]]$NewCommand) {
        if ($this.CommandIndex -le 0) { return $false }
        $additionalSize = $NewCommand.Length - 1

        $wds = New-Object string[] ($this.Words.Length + $additionalSize)
        [array]::Copy(
            $this.Words,
            0,
            $wds,
            0,
            $this.CommandIndex) | Out-Null
        [array]::Copy($NewCommand,
            0,
            $wds,
            $this.CommandIndex,
            $NewCommand.Length) | Out-Null
        [array]::Copy(
            $this.Words,
            $this.CommandIndex + 1,
            $wds,
            $this.CommandIndex + $NewCommand.Length,
            $this.Words.Length - $this.CommandIndex - 1) | Out-Null

        $this.CurrentIndex += $additionalSize
        $this.SubcommandLikeIndex = -1
        $this.DoubledashIndex = -1
        $this.InitWords($wds, $this.CommandIndex)
        return $true
    }
}