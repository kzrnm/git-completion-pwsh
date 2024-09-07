using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag File, Remote {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")
        Initialize-FilesRepo $rootPath $remotePath
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
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'suppress progress reporting'
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --quiet';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'suppress progress reporting'
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
            ListItemText = '-2';
            ToolTip      = "checkout our version for unmerged files";
        },
        @{
            ListItemText = '-3';
            ToolTip      = "checkout their version for unmerged files";
        },
        @{
            ListItemText = '-m';
            ToolTip      = "perform a 3-way merge with the new branch";
        },
        @{
            ListItemText = '-p';
            ToolTip      = "select hunks interactively";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "suppress progress reporting";
        },
        @{
            ListItemText = '-s';
            ToolTip      = "which tree-ish to checkout from";
        },
        @{
            ListItemText = '-S';
            ToolTip      = "restore the index";
        },
        @{
            ListItemText = '-W';
            ToolTip      = "restore the working tree (default)";
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
                Line     = '--o';
                Expected = @{
                    ListItemText = '--overlay';
                    ToolTip      = "use overlay mode";
                },
                @{
                    ListItemText = '--ours';
                    ToolTip      = "checkout our version for unmerged files";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-q';
                Expected = @{
                    ListItemText = '--no-quiet';
                    ToolTip      = "[NO] suppress progress reporting";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-source';
                    ToolTip      = "[NO] which tree-ish to checkout from"
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

    Describe 'OptionValue' {
        It '<Line>' -ForEach @(
            @{
                Line     = '-s ';
                Expected = 
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/main',
                'ordinary/main',
                'origin/main',
                'initial' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-s ^o';
                Expected = 
                '^ordinary/main',
                '^origin/main' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--source ';
                Expected = 
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/main',
                'ordinary/main',
                'origin/main',
                'initial' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--source ^m';
                Expected = 
                '^main' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--source=';
                Expected =
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/main',
                'ordinary/main',
                'origin/main',
                'initial' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--source=$_" }
            },
            @{
                Line     = '--source=m';
                Expected =
                'main' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--source=$_" }
            },
            @{
                Line     = '--conflict ';
                Expected = 
                'diff3', 'merge', 'zdiff3' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--conflict z';
                Expected = 
                'zdiff3' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--conflict=';
                Expected =
                'diff3', 'merge', 'zdiff3' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--conflict=$_" }
            },
            @{
                Line     = '--conflict=z';
                Expected =
                'zdiff3' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--conflict=$_" }
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'File' {
        It '<Line>' -ForEach @(
            @{
                Line     = ' ';
                Expected = @{
                    CompletionText = "Aquarion`` Evol/Evol";
                    ListItemText   = "Aquarion Evol/Evol"
                },
                'Dr.Wily', 'Pwsh/OptionLike/-foo.ps1' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = 'D';
                Expected = 'Dr.Wily' | ConvertTo-Completion -ResultType ProviderItem
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}