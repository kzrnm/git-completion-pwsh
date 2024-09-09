using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag Remote, File {
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
                    Left     = '--tags';
                    Right    = ' --';
                    Expected = '--tags' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--tags'
                },
                @{
                    Left     = '--tags';
                    Right    = ' -- --all';
                    Expected = '--tags' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--tags'
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

        Describe 'Revlist' {
            . "${RepoRoot}testtools/Revlist.ps1" -Ref -Prefix 'show -- '
        }
    }

    Describe '<Description>' -ForEach @(
        @{
            Subcommand  = 'show';
            Description = 'show';
        },
        @{
            Subcommand  = '';
            Description = '[show]';
        }
    ) {
        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--bi';
                    Expected = '--bisect' | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-m';
                    Expected = '--no-merges', '--no-min-parents' , '--no-max-parents' | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'SubcommandOrShow' {
            It '<Line>' -ForEach @(
                @{
                    Line     = ' ';
                    Expected = @(
                        @{
                            ListItemText = 'show';
                            ToolTip      = "shows the log of the reference (default)";
                            IsSubcommand = $true;
                        },
                        @{
                            ListItemText = 'list';
                            ToolTip      = "lists all refs";
                            IsSubcommand = $true;
                        },
                        @{
                            ListItemText = 'expire';
                            ToolTip      = "prunes older reflog entries";
                            IsSubcommand = $true;
                        },
                        @{
                            ListItemText = 'delete';
                            ToolTip      = "deletes single entries";
                            IsSubcommand = $true;
                        },
                        @{
                            ListItemText = 'exists';
                            ToolTip      = "checks whether a ref has a reflog";
                            IsSubcommand = $true;
                        } | ConvertTo-Completion -ResultType ParameterName
                    ) + @(
                        'HEAD',
                        'FETCH_HEAD',
                        'main',
                        'grm/develop',
                        'ordinary/develop',
                        'origin/develop',
                        'initial',
                        'zeta' | ConvertTo-Completion -ResultType ParameterValue
                    )
                },
                @{
                    Line     = ' e';
                    Expected = @(
                        @{
                            ListItemText = 'expire';
                            ToolTip      = "prunes older reflog entries";
                            IsSubcommand = $true;
                        },
                        @{
                            ListItemText = 'exists';
                            ToolTip      = "checks whether a ref has a reflog";
                            IsSubcommand = $true;
                        } | ConvertTo-Completion -ResultType ParameterName
                    )
                },
                @{
                    Line     = ' o';
                    Expected = @(
                        'ordinary/develop',
                        'origin/develop' | ConvertTo-Completion -ResultType ParameterValue
                    )
                }
            ) {
                if ($Subcommand -eq 'show') {
                    $Expected = $Expected | Where-Object { !$_.IsSubcommand }
                }
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $Expected
            }
        }
    }

    Describe 'Root' {
        It '<Line>' -ForEach @(
            @{
                Line     = "o";
                Expected = @(
                    'ordinary/develop',
                    'origin/develop'
                ) | ConvertTo-Completion -ResultType ParameterValue
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
                ) | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = "^o";
                Expected = @(
                    'ordinary/develop',
                    'origin/develop'
                ) | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'list' {
        BeforeAll {
            Set-Variable Subcommand 'list'
        }

        Describe 'Revlist' {
            . "${RepoRoot}testtools/Revlist.ps1" -Ref -Prefix 'list '
        }

        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'expire' {
        BeforeAll {
            Set-Variable Subcommand 'expire'
        }

        Describe 'Revlist' {
            . "${RepoRoot}testtools/Revlist.ps1" -Ref -Prefix 'expire '
        }

        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-n';
                ToolTip      = "do not actually prune any entries";
            },
            @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--al';
                    Expected = @{
                        ListItemText = '--all';
                        ToolTip      = "process the reflogs of all references";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-al';
                    Expected = @{
                        ListItemText = '--no-all';
                        ToolTip      = "[NO] process the reflogs of all references";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-dry-run';
                        ToolTip      = "[NO] do not actually prune any entries"
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text'
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'delete' {
        BeforeAll {
            Set-Variable Subcommand 'delete'
        }

        Describe 'Revlist' {
            . "${RepoRoot}testtools/Revlist.ps1" -Ref -Prefix 'delete '
        }

        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-n';
                ToolTip      = "do not actually prune any entries";
            },
            @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--dry-r';
                    Expected = @{
                        ListItemText = '--dry-run';
                        ToolTip      = "do not actually prune any entries";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-ve';
                    Expected = @{
                        ListItemText = '--no-verbose';
                        ToolTip      = "[NO] print extra information on screen";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-dry-run';
                        ToolTip      = "[NO] do not actually prune any entries"
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text'
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'exists' {
        BeforeAll {
            Set-Variable Subcommand 'exists'
        }

        Describe 'Revlist' {
            . "${RepoRoot}testtools/Revlist.ps1" -Ref -Prefix 'exists '
        }

        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

}