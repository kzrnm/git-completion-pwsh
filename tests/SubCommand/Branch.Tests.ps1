using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
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

    It 'ShortOptions' {
        $expected = @{
            ListItemText = '-a';
            ToolTip      = "list both remote-tracking and local branches";
        },
        @{
            ListItemText = '-c';
            ToolTip      = "copy a branch and its reflog";
        },
        @{
            ListItemText = '-C';
            ToolTip      = "copy a branch, even if target exists";
        },
        @{
            ListItemText = '-d';
            ToolTip      = "delete fully merged branch";
        },
        @{
            ListItemText = '-D';
            ToolTip      = "delete branch (even if not merged)";
        },
        @{
            ListItemText = '-f';
            ToolTip      = "force creation, move/rename, deletion";
        },
        @{
            ListItemText = '-i';
            ToolTip      = "sorting and filtering are case insensitive";
        },
        @{
            ListItemText = '-l';
            ToolTip      = "list branch names";
        },
        @{
            ListItemText = '-m';
            ToolTip      = "move/rename a branch and its reflog";
        },
        @{
            ListItemText = '-M';
            ToolTip      = "move/rename a branch, even if target exists";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "suppress informational messages";
        },
        @{
            ListItemText = '-r';
            ToolTip      = "act on remote-tracking branches";
        },
        @{
            ListItemText = '-t';
            ToolTip      = "set branch tracking configuration";
        },
        @{
            ListItemText = '-u';
            ToolTip      = "change the upstream info";
        },
        @{
            ListItemText = '-v';
            ToolTip      = "show hash and subject, give twice for upstream branch";
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
                Line     = '--v';
                Expected = '--verbose' | ConvertTo-Completion -ResultType ParameterName -ToolTip "show hash and subject, give twice for upstream branch"
            },
            @{
                Line     = '--m';
                Expected = 
                @{
                    ListItemText = '--move';
                    ToolTip      = "move/rename a branch and its reflog"
                },
                @{
                    ListItemText = '--merged';
                    ToolTip      = "print only branches that are merged"
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-m';
                Expected = 
                @{
                    ListItemText = '--no-merged';
                    ToolTip      = "print only branches that are not merged"
                },
                @{
                    ListItemText = '--no-move';
                    ToolTip      = "[NO] move/rename a branch and its reflog"
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-contains';
                    ToolTip      = "print only branches that don't contain the commit"
                },
                @{
                    ListItemText = '--no-merged';
                    ToolTip      = "print only branches that are not merged"
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
                Line     = '--set-upstream-to=';
                Expected =
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/main',
                'ordinary/main',
                'origin/main',
                'initial' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--set-upstream-to=$_"
                }
            },
            @{
                Line     = '--set-upstream-to=o';
                Expected =
                'ordinary/main',
                'origin/main' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--set-upstream-to=$_"
                }
            },
            @{
                Line     = '--set-upstream-to=^';
                Expected =
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/main',
                'ordinary/main',
                'origin/main',
                'initial' | ForEach-Object {
                    "^$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--set-upstream-to=^$_"
                }
            },
            @{
                Line     = '--set-upstream-to=^o';
                Expected =
                'ordinary/main',
                'origin/main' | ForEach-Object {
                    "^$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--set-upstream-to=^$_"
                }
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe '--set-upstream-to ' {
            . "${RepoRoot}testtools/Revlist.ps1" -Ref -Prefix '--set-upstream-to '
        }
    }

    Describe 'Revlist' {
        . "${RepoRoot}testtools/Revlist.ps1" -Ref
    }

    Describe 'OnlyLocalRef' {
        Describe '<Option>' -ForEach @(
            '-d', '-D', '--delete', '-m', '-M', '--move', '-c', '-C', '--copy' | ForEach-Object { @{Option = "$_"; } }
        ) {
            It 'Left' {
                $Expected = 'main' | ConvertTo-Completion -ResultType ParameterValue
                "git $Command $Option " | Complete-FromLine | Should -BeCompletion $expected
            }

            It 'Right' {
                $Expected = 'main' | ConvertTo-Completion -ResultType ParameterValue
                "git $Command " | Complete-FromLine -Right @($Option) | Should -BeCompletion $expected
            }
        }
    }
}