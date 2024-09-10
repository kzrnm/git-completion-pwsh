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
                    Left     = '--long';
                    Right    = ' --';
                    Expected = '--long' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'include object size'
                },
                @{
                    Left     = '--long';
                    Right    = ' -- --long';
                    Expected = '--long' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'include object size'
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

        Describe-Revlist -Ref {
            "git $Command -- $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $Expected = @{
            ListItemText = '-d';
            ToolTip      = "only show trees";
        },
        @{
            ListItemText = '-l';
            ToolTip      = "include object size";
        },
        @{
            ListItemText = '-r';
            ToolTip      = "recurse into subtrees";
        },
        @{
            ListItemText = '-t';
            ToolTip      = "show trees when recursing";
        },
        @{
            ListItemText = '-z';
            ToolTip      = "terminate entries with NUL byte";
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
                Line     = '--a';
                Expected = @{
                    ListItemText = '--abbrev';
                    ToolTip      = "use <n> digits to display object names";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--f';
                Expected = @{
                    ListItemText = '--full-name';
                    ToolTip      = "use full path names";
                },
                @{
                    ListItemText = '--full-tree';
                    ToolTip      = "list entire tree; not just current directory (implies --full-name)";
                },
                @{
                    ListItemText = '--format=';
                    ToolTip      = "format to use for the output";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-a';
                Expected = @{
                    ListItemText = '--no-abbrev';
                    ToolTip      = "[NO] use <n> digits to display object names";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-f';
                Expected = @{
                    ListItemText = '--no-full-name';
                    ToolTip      = "[NO] use full path names";
                },
                @{
                    ListItemText = '--no-full-tree';
                    ToolTip      = "[NO] list entire tree; not just current directory (implies --full-name)";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-full-name';
                    ToolTip      = "[NO] use full path names";
                },
                @{
                    CompletionText = '--no-';
                    ListItemText   = '--no-...';
                    ResultType     = 'Text';
                } | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe-Revlist

    Describe 'HasRev' {
        It '<Line>' -ForEach @(
            @{
                Line     = 'HEAD ';
                Expected = @()
            },
            @{
                Line     = '-- HEAD ';
                Expected = @()
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}