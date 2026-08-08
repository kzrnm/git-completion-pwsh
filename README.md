# git-completion-pwsh

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/git-completion)](https://www.powershellgallery.com/packages/git-completion)

This is **a more powerful Git completion module for PowerShell** than [posh-git](https://github.com/dahlbyk/posh-git).

Give it a try and experience next-level Git productivity in PowerShell! 🚀

## Get Started

[PowerShell Gallery](https://www.powershellgallery.com/packages/git-completion).

Run the command below. This module works on both Windows PowerShell and the latest cross-platform PowerShell.

```powershell
Install-Module git-completion
```

In your `$PROFILE` add the following code:

```powershell
Register-ArgumentCompleter -CommandName gitk -Native -ScriptBlock {
    param($wordToComplete, $CommandAst, $CursorPosition)
    return (Complete-Gitk -CommandAst $CommandAst -CursorPosition $CursorPosition)
}
Register-ArgumentCompleter -CommandName git -Native -ScriptBlock {
    param($wordToComplete, $CommandAst, $CursorPosition)
    return (Complete-Git -CommandAst $CommandAst -CursorPosition $CursorPosition)
}
```

### ⚠ Notes for upgrading from git-completion v1 to v2

In git-completion v1, importing the module automatically enabled Git completion:

```powershell
Import-Module git-completion
```

Starting with v2, you must explicitly register the argument completer by calling `Register-ArgumentCompleter` yourself.

This change was made to improve performance.

### Setup Settings

Values defined in `$GitCompletionSettings` before `Import-Module` are respected.

```powershell
$env:GIT_COMPLETION_IGNORE_CASE = '1'
$GitCompletionSettings = @{ ExcludeCommands = @('send-email'); ShowAllCommand = 1 }
Import-Module git-completion
Write-Output $GitCompletionSettings
# ShowAllOptions     : False
# ShowAllCommand     : True
# IgnoreCase         : True
# CheckoutNoGuess    : False
# AdditionalCommands : {}
# ExcludeCommands    : {send-email}
```

However, note that `$GitCompletionSettings` is not defined before `Import-Module`.

```powershell
# Does not work
$GitCompletionSettings.ShowAllOptions = $true
Import-Module git-completion
```

## Usage

![image](https://github.com/user-attachments/assets/6d702fe0-5084-4dbf-8b62-3e7c99a6b087)

## Features

### Equivalent Completion to Bash

In Bash, completion works for all subcommands, including `ls-files`. Although posh-git covers many common commands, it doesn't handle all commands. Additionally, posh-git embeds option definitions within its script, making it difficult to keep up with Git updates. In contrast, Bash's completion leverages Git's built-in --git-completion-helper option, allowing it to adapt easily to changes. I have replicated this approach in PowerShell to create a more robust and future-proof module.

### Option Completion
While posh-git supports completion for short options, Bash does not, which can be inconvenient. Since memorizing options is cumbersome, this module provides completion for both short and long options to improve usability.
Additionally, like Bash, it dynamically adjusts completion suggestions based on option values, making the experience more intuitive.

### File Path Completion
Both Bash and posh-git provide file path completion based on Git's internal state. To maintain this behavior, git-completion-pwsh also intelligently suggests relevant files. For example, when using git add, only new or modified files appear as completion candidates, making file selection smarter and more efficient.

### Utilizing Tooltips
By default, tab completion does not display tooltips. However, when using MenuComplete mode, tooltips appear alongside the suggestions. The screenshot above demonstrates this behavior in MenuComplete mode.
To enable it, run the following command:

```powershell
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete
```

![log completion](https://github.com/user-attachments/assets/f8327f31-58f8-46cd-af75-97392a0f5cc9)

When selecting a branch, commit messages are displayed, and option descriptions are shown, allowing for more intuitive choices.

## Original

This module is a PowerShell port of [git-completion.bash Commit: ff7901eca30c308ef5a448ebd56eaf363b58a02e](https://github.com/git/git/blob/ff7901eca30c308ef5a448ebd56eaf363b58a02e/contrib/completion/git-completion.bash).

### Changes from **git-completion.bash**
- Add completion information in tooltips
- Include commit hash completion for some completions
- Completions
  - branch: `--column`
  - config: Add [value completions](src/Complete/SubCommand/Config.ps1#L316)
  - stash: Complete modified files
  - tag: `--column`
