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

This module is a PowerShell port of [git-completion.bash Commit: 8b6f19ccfc3aefbd0f22f6b7d56ad6a3fc5e4f37](https://github.com/git/git/blob/8b6f19ccfc3aefbd0f22f6b7d56ad6a3fc5e4f37/contrib/completion/git-completion.bash).

### Changes from **git-completion.bash**
- Add completion information in tooltips
- Include commit hash completion for some completions
- Limit completion in `git stash` to files that have been modified
- Use `git shortlog --committer` instead of `git shortlog --committer=`
- Add completions to [config](src/Complete/SubCommand/Config.ps1#L316)
