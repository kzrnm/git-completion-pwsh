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
        [switch]$Refspec,
        [Parameter(ParameterSetName = 'Separate')]
        [switch]$File,
        [Parameter(ParameterSetName = 'All')]
        [switch]$All
    )

    switch ($PsCmdlet.ParameterSetName) {
        'All' {
            $Ref =
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
                        Expected = @(
                            'HEAD',
                            'FETCH_HEAD',
                            'main',
                            'grm/develop',
                            'ordinary/develop',
                            'origin/develop',
                            'initial',
                            'zeta'
                        ) | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}$_" }
                    },
                    @{
                        Line     = "o";
                        Expected = @(
                            'ordinary/develop',
                            'origin/develop'
                        ) | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}$_" }
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

        if ($Refspec) {
            Describe 'Refspec' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = "HEAD...";
                        Expected = @(
                            'HEAD',
                            'FETCH_HEAD',
                            'main',
                            'grm/develop',
                            'ordinary/develop',
                            'origin/develop',
                            'initial',
                            'zeta'
                        ) | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}HEAD...$_" }
                    },
                    @{
                        Line     = "HEAD...o";
                        Expected = @(
                            'ordinary/develop',
                            'origin/develop'
                        ) | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}HEAD...$_" }
                    },
                    @{
                        Line     = "HEAD..";
                        Expected = @(
                            'HEAD',
                            'FETCH_HEAD',
                            'main',
                            'grm/develop',
                            'ordinary/develop',
                            'origin/develop',
                            'initial',
                            'zeta'
                        ) | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}HEAD..$_" }
                    },
                    @{
                        Line     = "HEAD..o";
                        Expected = @(
                            'ordinary/develop',
                            'origin/develop'
                        ) | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "${CompletionPrefix}HEAD..$_" }
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