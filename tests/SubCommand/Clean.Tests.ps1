using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag File {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        Initialize-FilesRepo $rootPath
        Push-Location $rootPath
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor)<Right>' -ForEach @(
                @{
                    Left     = '--quiet';
                    Right    = ' --';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'do not print names of files removed'
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --quiet';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'do not print names of files removed'
                }
            ) {
                "git $Command $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
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
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $Expected = @{
            ListItemText = '-d';
            ToolTip      = "remove whole directories";
        },
        @{
            ListItemText = '-e';
            ToolTip      = "add <pattern> to ignore rules";
        },
        @{
            ListItemText = '-f';
            ToolTip      = "force";
        },
        @{
            ListItemText = '-i';
            ToolTip      = "interactive cleaning";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "dry run";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "do not print names of files removed";
        },
        @{
            ListItemText = '-x';
            ToolTip      = "remove ignored files, too";
        },
        @{
            ListItemText = '-X';
            ToolTip      = "remove only ignored files";
        },
        @{
            ListItemText = '-h';
            ToolTip      = "show help";
        } | ConvertTo-Completion -ResultType ParameterName
        "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--i';
                Expected = @{
                    ListItemText = '--interactive';
                    ToolTip      = "interactive cleaning";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-d';
                Expected = @{
                    ListItemText = '--no-dry-run';
                    ToolTip      = "[NO] dry run";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-quiet';
                    ToolTip      = "[NO] do not print names of files removed"
                },
                @{
                    CompletionText = '--no-';
                    ListItemText   = '--no-...';
                    ResultType     = 'Text'
                } | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'File' {
        It '<Line>' -ForEach @(
            @{
                Line     = ' ';
                Expected = (
                    ('Gepada', 'Gepard' |
                    ForEach-Object {
                        @{
                            CompletionText = "Aquarion`` Evol/$_";
                            ListItemText   = "Aquarion Evol/$_"
                        }
                    }) + @(
                        'Deava',
                        'Pwsh/L1/',
                        'Pwsh/OptionLike/',
                        'test.config',
                        @{
                            CompletionText = '漢```''帝`　国`''';
                            ListItemText   = '漢`''帝　国''';
                        },
                        '漢字/'
                    )
                ) | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = '-X Pwsh/i';
                Expected = 'Pwsh/ignored' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = '-X Pwsh/j';
                Expected = @()
            },
            @{
                Line     = 'D';
                Expected = 'Deava' | ConvertTo-Completion -ResultType ProviderItem
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}