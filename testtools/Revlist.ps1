# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.IO;

function Describe-Revlist {
    [CmdletBinding(DefaultParameterSetName = 'All', PositionalBinding = $false)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Scope = 'Function')]
    param(
        [Parameter(Position = 0)]
        [scriptblock]$ScriptBlock = $null,
        [string]$CompletionPrefix = '',
        [Parameter(ParameterSetName = 'Separate')]
        [switch]$Ref,
        [Parameter(ParameterSetName = 'Separate')]
        [switch]$RefPrevious,
        [Parameter(ParameterSetName = 'Separate')]
        [switch]$Refspec,
        [Parameter(ParameterSetName = 'Separate')]
        [switch]$File,
        [Parameter(ParameterSetName = 'All')]
        [switch]$All
    )

    switch ($PsCmdlet.ParameterSetName) {
        'All' {
            $Ref =
            $RefPrevious =
            $Refspec =
            $File = $true
        }
    }

    if (!$ScriptBlock) {
        [scriptblock]$ScriptBlock = {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'Revlist' {
        if ($Ref) {
            Describe 'Ref' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = "";
                        Expected =
                        'HEAD',
                        'FETCH_HEAD',
                        'main',
                        'grm/develop',
                        'ordinary/develop',
                        'origin/develop',
                        'initial',
                        'zeta' | ForEach-Object { $RemoteCommits[$_] }  | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}$_" }
                    },
                    @{
                        Line     = "o";
                        Expected =
                        'ordinary/develop',
                        'origin/develop' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}$_" }
                    },
                    @{
                        Line     = "^";
                        Expected = @(
                            'HEAD',
                            'FETCH_HEAD',
                            'main',
                            'grm/develop',
                            'ordinary/develop',
                            'origin/develop',
                            'initial',
                            'zeta'
                        ) | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}$_" }
                    },
                    @{
                        Line     = "^o";
                        Expected = @(
                            'ordinary/develop',
                            'origin/develop'
                        ) | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}$_" }
                    }
                ) -Test $ScriptBlock
            }
        }

        if ($RefPrevious) {
            Describe 'RefPrevious' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = "HEAD";
                        Expected =
                        $RemoteCommits['HEAD'],
                        @{
                            ListItemText = 'HEAD~';
                            ToolTip      = 'd19340a initial';
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}$_" }
                    },
                    @{
                        Line     = "zeta";
                        Expected =
                        $RemoteCommits['zeta'],
                        @{
                            ListItemText = 'zeta~';
                            ToolTip      = 'e946fd9 ' + [char]0x395;
                        },
                        @{
                            ListItemText = 'zeta~~';
                            ToolTip      = '20cc0b9 ' + [char]0x394;
                        },
                        @{
                            ListItemText = 'zeta~~~';
                            ToolTip      = '059ae39 ' + [char]0x393;
                        },
                        @{
                            ListItemText = 'zeta~~~~';
                            ToolTip      = 'd3054a8 ' + [char]0x392;
                        },
                        @{
                            ListItemText = 'zeta~~~~~';
                            ToolTip      = '881ffe7 ' + [char]0x391;
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}$_" }
                    },
                    @{
                        Line     = "zeta~";
                        Expected =
                        @{
                            ListItemText = 'zeta~';
                            ToolTip      = 'e946fd9 ' + [char]0x395;
                        },
                        @{
                            ListItemText = 'zeta~~';
                            ToolTip      = '20cc0b9 ' + [char]0x394;
                        },
                        @{
                            ListItemText = 'zeta~~~';
                            ToolTip      = '059ae39 ' + [char]0x393;
                        },
                        @{
                            ListItemText = 'zeta~~~~';
                            ToolTip      = 'd3054a8 ' + [char]0x392;
                        },
                        @{
                            ListItemText = 'zeta~~~~~';
                            ToolTip      = '881ffe7 ' + [char]0x391;
                        },
                        @{
                            ListItemText = 'zeta~~~~~~';
                            ToolTip      = "d19340a initial";
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}$_" }
                    },
                    @{
                        Line     = "e946fd9";
                        Expected =
                        @{
                            ListItemText = 'e946fd9';
                            ToolTip      = 'e946fd9 ' + [char]0x395;
                        },
                        @{
                            ListItemText = 'e946fd9~';
                            ToolTip      = '20cc0b9 ' + [char]0x394;
                        },
                        @{
                            ListItemText = 'e946fd9~~';
                            ToolTip      = '059ae39 ' + [char]0x393;
                        },
                        @{
                            ListItemText = 'e946fd9~~~';
                            ToolTip      = 'd3054a8 ' + [char]0x392;
                        },
                        @{
                            ListItemText = 'e946fd9~~~~';
                            ToolTip      = '881ffe7 ' + [char]0x391;
                        },
                        @{
                            ListItemText = 'e946fd9~~~~~';
                            ToolTip      = "d19340a initial";
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}$_" }
                    }
                ) -Test $ScriptBlock
            }
        }

        if ($Refspec) {
            Describe 'Refspec' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = "HEAD...";
                        Expected =
                        'HEAD',
                        'FETCH_HEAD',
                        'main',
                        'grm/develop',
                        'ordinary/develop',
                        'origin/develop',
                        'initial',
                        'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}HEAD...$_" }
                    },
                    @{
                        Line     = "HEAD...o";
                        Expected =
                        'ordinary/develop',
                        'origin/develop' | ForEach-Object { $RemoteCommits[$_] }  | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}HEAD...$_" }
                    },
                    @{
                        Line     = "HEAD..";
                        Expected =
                        'HEAD',
                        'FETCH_HEAD',
                        'main',
                        'grm/develop',
                        'ordinary/develop',
                        'origin/develop',
                        'initial',
                        'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}HEAD..$_" }
                    },
                    @{
                        Line     = "HEAD..o";
                        Expected =
                        'ordinary/develop',
                        'origin/develop' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}HEAD..$_" }
                    }
                ) -Test $ScriptBlock
            }
        }

        if ($File) {
            Describe 'File' {
                BeforeEach {
                    foreach ($e in $Expected) {
                        $e.ToolTip = (Resolve-Path $e.File).Path.TrimEnd([Path]::AltDirectorySeparatorChar, [Path]::DirectorySeparatorChar)
                    }
                }
                It '<Line>' -ForEach @(
                    @{
                        Line     = "brn..main:";
                        Expected = if ($IsWindows -or ($PSVersionTable.PSEdition -eq 'Desktop')) {
                            'Pwsh/', '.gitignore', 'hello.sh', 'initial.txt' | ForEach-Object {
                                @{
                                    File           = $_
                                    CompletionText = "${CompletionPrefix}brn..main:$_";
                                    ListItemText   = "$_";
                                    ResultType     = 'ProviderItem';
                                }
                            }
                        }
                        else {
                            'Pwsh/', 'hello.sh', 'initial.txt' | ForEach-Object {
                                @{
                                    File           = $_
                                    CompletionText = "${CompletionPrefix}brn..main:$_";
                                    ListItemText   = "$_";
                                    ResultType     = 'ProviderItem';
                                }
                            }
                        }
                    },
                    @{
                        Line     = "brn..main:Pwsh/";
                        Expected = @(
                            @{
                                File           = 'Pwsh/ignored'
                                CompletionText = "${CompletionPrefix}brn..main:Pwsh/ignored";
                                ListItemText   = "ignored";
                                ResultType     = 'ProviderItem';
                            },
                            @{
                                File           = 'Pwsh/world.ps1'
                                CompletionText = "${CompletionPrefix}brn..main:Pwsh/world.ps1";
                                ListItemText   = "world.ps1";
                                ResultType     = 'ProviderItem';
                            }
                        )
                    },
                    @{
                        Line     = "main:";
                        Expected = '.gitignore', 'Pwsh/', 'hello.sh', 'initial.txt' | ForEach-Object { 
                            @{
                                File           = $_
                                CompletionText = "${CompletionPrefix}main:$_";
                                ListItemText   = "$_";
                                ResultType     = 'ProviderItem';
                            }
                        }
                    },
                    @{
                        Line     = "main:Pws";
                        Expected = 'Pwsh/' | ForEach-Object { 
                            @{
                                File           = $_
                                CompletionText = "${CompletionPrefix}main:$_";
                                ListItemText   = "$_";
                                ResultType     = 'ProviderItem';
                            }
                        }
                    },
                    @{
                        Line     = "main:Pwsh/";
                        Expected = @(
                            @{
                                File           = 'Pwsh/world.ps1'
                                CompletionText = "${CompletionPrefix}main:Pwsh/world.ps1";
                                ListItemText   = "world.ps1";
                                ResultType     = 'ProviderItem';
                            }
                        )
                    },
                    @{
                        Line     = "main:Pwsh/wo";
                        Expected = @(
                            @{
                                File           = 'Pwsh/world.ps1'
                                CompletionText = "${CompletionPrefix}main:Pwsh/world.ps1";
                                ListItemText   = "world.ps1";
                                ResultType     = 'ProviderItem';
                            }
                        )
                    },
                    @{
                        Line     = "main:./Pwsh/";
                        Expected = @(
                            @{
                                File           = 'Pwsh/ignored'
                                CompletionText = "${CompletionPrefix}main:./Pwsh/ignored";
                                ListItemText   = "ignored";
                                ResultType     = 'ProviderItem';
                            },
                            @{
                                File           = 'Pwsh/world.ps1'
                                CompletionText = "${CompletionPrefix}main:./Pwsh/world.ps1";
                                ListItemText   = "world.ps1";
                                ResultType     = 'ProviderItem';
                            }
                        )
                    },
                    @{
                        Line     = "main:./Pwsh/wo";
                        Expected = @(
                            @{
                                File           = 'Pwsh/world.ps1'
                                CompletionText = "${CompletionPrefix}main:./Pwsh/world.ps1";
                                ListItemText   = "world.ps1";
                                ResultType     = 'ProviderItem';
                            }
                        )
                    }
                ) $ScriptBlock
            }
        }
    }
}