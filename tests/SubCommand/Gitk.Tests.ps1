using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
    BeforeAll {
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")
        Initialize-Remote $rootPath $remotePath
        Push-Location $rootPath
        git config set pretty.changelog "format:* %H %s"
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor)<Right>' -ForEach @(
                @{
                    Left     = @('gitk', '--left-o');
                    Right    = ' --';
                    Expected = '--left-only' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--left-only'
                },
                @{
                    Left     = @('gitk', '--left-o');
                    Right    = ' -- --all';
                    Expected = '--left-only' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--left-only'
                }
            ) {
                Complete-Gitk -Words ($Left + $Right) -CurrentIndex ($Left.Length - 1) | 
                Should -BeCompletion $expected
            }
        }

        It '<Line>' -ForEach @(
            @{
                Line     = 'src -- -';
                Expected = @()
            },
            @{
                Line     = 'src -- --';
                Expected = @()
            },
            @{
                Line     = 'src -- ';
                Expected = @()
            },
            @{
                Line     = '-- ';
                Expected = @()
            }
        ) {
            "gitk $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--bi';
                Expected = '--bisect' | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-n';
                Expected = '--no-notes' | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "gitk $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'Revlist' {
       
        Describe 'Ref' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '';
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
                    Line     = 'o';
                    Expected = @(
                        'ordinary/main',
                        'origin/main'
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '^';
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
                    Line     = '^o';
                    Expected = @(
                        'ordinary/main',
                        'origin/main'
                    ) | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "gitk $Prefix$Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Refspec' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'HEAD...';
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
                    Line     = 'HEAD...o';
                    Expected = @(
                        'ordinary/main',
                        'origin/main'
                    ) | ForEach-Object {
                        "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "HEAD...$_"
                    }
                },
                @{
                    Line     = 'HEAD..';
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
                    Line     = 'HEAD..o';
                    Expected = @(
                        'ordinary/main',
                        'origin/main'
                    ) | ForEach-Object {
                        "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "HEAD..$_"
                    }
                }
            ) {
                "gitk $Prefix$Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'File' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'brn..main:';
                    Expected = @(
                        'Pwsh/', 'hello.sh', 'initial.txt' | ForEach-Object {
                            @{
                                File           = $_
                                CompletionText = "brn..main:$_";
                                ListItemText   = "$_";
                                ResultType     = 'ProviderItem';
                            }
                        })
                },
                @{
                    Line     = 'brn..main:Pwsh/';
                    Expected = @(
                        @{
                            File           = 'Pwsh/world.ps1'
                            CompletionText = "brn..main:Pwsh/world.ps1";
                            ListItemText   = "world.ps1";
                            ResultType     = 'ProviderItem';
                        }
                    )
                },
                @{
                    Line     = 'main:';
                    Expected = 'Pwsh/', 'hello.sh', 'initial.txt' | ForEach-Object { 
                        @{
                            File           = $_
                            CompletionText = "main:$_";
                            ListItemText   = "$_";
                            ResultType     = 'ProviderItem';
                        }
                    }
                },
                @{
                    Line     = 'main:Pws';
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
                    Line     = 'main:Pwsh/';
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
                    Line     = 'main:Pwsh/wo';
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
                    Line     = 'main:./Pwsh/';
                    Expected = @(
                        @{
                            File           = 'Pwsh/world.ps1'
                            CompletionText = "main:./Pwsh/world.ps1";
                            ListItemText   = "world.ps1";
                            ResultType     = 'ProviderItem';
                        }
                    )
                },
                @{
                    Line     = 'main:./Pwsh/wo';
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
                "gitk $Prefix$Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}