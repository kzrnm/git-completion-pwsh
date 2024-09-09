using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag Remote {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")
        Initialize-Remote $rootPath $remotePath
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
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be quiet, only report errors'
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --all';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be quiet, only report errors'
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
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        function expectedFunc {
            @{
                ListItemText = '-N';
                ToolTip      = "record only the fact that removed paths will be added later";
            }
            @{
                ListItemText = '-p';
                ToolTip      = "select hunks interactively";
            }
            @{
                ListItemText = '-q';
                ToolTip      = "be quiet, only report errors";
            }
            if ($IsWindows -or ($PSVersionTable.PSEdition -eq 'Desktop')) {
                @{
                    ListItemText = '-z';
                    ToolTip      = "DEPRECATED (use --pathspec-file-nul instead): paths are separated with NUL character";
                }
            }
            @{
                ListItemText = '-h';
                ToolTip      = "show help";
            }
        }
        $Expected = expectedFunc | ConvertTo-Completion -ResultType ParameterName
        "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--m';
                Expected = @{
                    ListItemText = '--mixed';
                    ToolTip      = "reset HEAD and index";
                },
                @{
                    ListItemText = '--merge';
                    ToolTip      = "reset HEAD, index and working tree";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--h';
                Expected = @{
                    ListItemText = '--hard';
                    ToolTip      = "reset HEAD, index and working tree";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--path';
                Expected = @{
                    ListItemText = '--pathspec-from-file=';
                    ToolTip      = "read pathspec from file";
                },
                @{
                    ListItemText = '--pathspec-file-nul';
                    ToolTip      = "with --pathspec-from-file, pathspec elements are separated with NUL character";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-path';
                Expected = @{
                    ListItemText = '--no-pathspec-from-file';
                    ToolTip      = "[NO] read pathspec from file";
                },
                @{
                    ListItemText = '--no-pathspec-file-nul';
                    ToolTip      = "[NO] with --pathspec-from-file, pathspec elements are separated with NUL character";
                } | ConvertTo-Completion -ResultType ParameterName
            }
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-refresh';
                    ToolTip      = "skip refreshing the index after reset";
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

    Describe-Revlist -Ref
}