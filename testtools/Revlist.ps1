using namespace System.IO;

[CmdletBinding(DefaultParameterSetName = 'All')]
param(
    [string]$Prefix = '',
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

if ($Ref) {
    Describe 'Ref' {
        It '<Line>' -ForEach @(
            @{
                Line     = "${Prefix}";
                Expected = @(
                    'HEAD',
                    'FETCH_HEAD',
                    'main',
                    'grm/main',
                    'ordinary/main',
                    'origin/main',
                    'initial'
                ) | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = "${Prefix}o";
                Expected = @(
                    'ordinary/main',
                    'origin/main'
                ) | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = "${Prefix}^";
                Expected = @(
                    'HEAD',
                    'FETCH_HEAD',
                    'main',
                    'grm/main',
                    'ordinary/main',
                    'origin/main',
                    'initial'
                ) | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = "${Prefix}^o";
                Expected = @(
                    'ordinary/main',
                    'origin/main'
                ) | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}

if ($Refspec) {
    Describe 'Refspec' {
        It '<Line>' -ForEach @(
            @{
                Line     = "${Prefix}HEAD...";
                Expected = @(
                    'HEAD',
                    'FETCH_HEAD',
                    'main',
                    'grm/main',
                    'ordinary/main',
                    'origin/main',
                    'initial'
                ) | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "HEAD...$_"
                }
            },
            @{
                Line     = "${Prefix}HEAD...o";
                Expected = @(
                    'ordinary/main',
                    'origin/main'
                ) | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "HEAD...$_"
                }
            },
            @{
                Line     = "${Prefix}HEAD..";
                Expected = @(
                    'HEAD',
                    'FETCH_HEAD',
                    'main',
                    'grm/main',
                    'ordinary/main',
                    'origin/main',
                    'initial'
                ) | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "HEAD..$_"
                }
            },
            @{
                Line     = "${Prefix}HEAD..o";
                Expected = @(
                    'ordinary/main',
                    'origin/main'
                ) | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "HEAD..$_"
                }
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}

if ($File) {
    Describe 'File' {
        It '<Line>' -ForEach @(
            @{
                Line     = "${Prefix}brn..main:";
                Expected = @(
                    'Pwsh/', '.gitignore', 'hello.sh', 'initial.txt' | ForEach-Object {
                        @{
                            File           = $_
                            CompletionText = "brn..main:$_";
                            ListItemText   = "$_";
                            ResultType     = 'ProviderItem';
                        }
                    })
            },
            @{
                Line     = "${Prefix}brn..main:Pwsh/";
                Expected = @(
                    @{
                        File           = 'Pwsh/ignored'
                        CompletionText = "brn..main:Pwsh/ignored";
                        ListItemText   = "ignored";
                        ResultType     = 'ProviderItem';
                    },
                    @{
                        File           = 'Pwsh/world.ps1'
                        CompletionText = "brn..main:Pwsh/world.ps1";
                        ListItemText   = "world.ps1";
                        ResultType     = 'ProviderItem';
                    }
                )
            },
            @{
                Line     = "${Prefix}main:";
                Expected = '.gitignore', 'Pwsh/', 'hello.sh', 'initial.txt' | ForEach-Object { 
                    @{
                        File           = $_
                        CompletionText = "main:$_";
                        ListItemText   = "$_";
                        ResultType     = 'ProviderItem';
                    }
                }
            },
            @{
                Line     = "${Prefix}main:Pws";
                Expected = 'Pwsh/' | ForEach-Object { 
                    @{
                        File           = $_
                        CompletionText = "main:$_";
                        ListItemText   = "$_";
                        ResultType     = 'ProviderItem';
                    }
                }
            },
            @{
                Line     = "${Prefix}main:Pwsh/";
                Expected = @(
                    @{
                        File           = 'Pwsh/world.ps1'
                        CompletionText = "main:Pwsh/world.ps1";
                        ListItemText   = "world.ps1";
                        ResultType     = 'ProviderItem';
                    }
                )
            },
            @{
                Line     = "${Prefix}main:Pwsh/wo";
                Expected = @(
                    @{
                        File           = 'Pwsh/world.ps1'
                        CompletionText = "main:Pwsh/world.ps1";
                        ListItemText   = "world.ps1";
                        ResultType     = 'ProviderItem';
                    }
                )
            },
            @{
                Line     = "${Prefix}main:./Pwsh/";
                Expected = @(
                    @{
                        File           = 'Pwsh/ignored'
                        CompletionText = "main:./Pwsh/ignored";
                        ListItemText   = "ignored";
                        ResultType     = 'ProviderItem';
                    },
                    @{
                        File           = 'Pwsh/world.ps1'
                        CompletionText = "main:./Pwsh/world.ps1";
                        ListItemText   = "world.ps1";
                        ResultType     = 'ProviderItem';
                    }
                )
            },
            @{
                Line     = "${Prefix}main:./Pwsh/wo";
                Expected = @(
                    @{
                        File           = 'Pwsh/world.ps1'
                        CompletionText = "main:./Pwsh/world.ps1";
                        ListItemText   = "world.ps1";
                        ResultType     = 'ProviderItem';
                    }
                )
            }
        ) {
            foreach ($e in $expected) {
                $e.ToolTip = (Resolve-Path $e.File).Path.TrimEnd([Path]::AltDirectorySeparatorChar, [Path]::DirectorySeparatorChar)
            }
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}