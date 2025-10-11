# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;

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
    Describe '_' {
        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--verbose';
                        Right    = ' --';
                        Expected = '--verbose' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be verbose; must be placed before a subcommand'
                    },
                    @{
                        Left     = '--verbose';
                        Right    = ' -- --all';
                        Expected = '--verbose' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be verbose; must be placed before a subcommand'
                    }
                ) {
                    "git $Command $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
                }
            }

            It '<Line>' -ForEach @(
                @{
                    Line     = '-- -';
                    Expected = @()
                },
                @{
                    Line     = '-- --';
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
            $expected = @{
                ListItemText = '-v';
                ToolTip      = "be verbose; must be placed before a subcommand";
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
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--verbose';
                        ToolTip      = "be verbose; must be placed before a subcommand";
                    },
                    @{
                        ListItemText = '--no-verbose';
                        ToolTip      = "[NO] be verbose; must be placed before a subcommand";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--v';
                    Expected = '--verbose' | ConvertTo-Completion -ResultType ParameterName -ToolTip "be verbose; must be placed before a subcommand"
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Subcommands' {
            Context '<Line>' -ForEach @(
                @{
                    Line     = '';
                    Expected =
                    @{Subcommand = 'add'; Description = 'Add a remote'; },
                    @{Subcommand = 'rename'; Description = 'Rename the remote name'; },
                    @{Subcommand = 'remove'; Description = 'Remove the remote name'; },
                    @{Subcommand = 'set-head'; Description = 'Sets or deletes the default branch for the named remote'; },
                    @{Subcommand = 'set-branches'; Description = 'Changes the list of branches tracked by the named remote'; },
                    @{Subcommand = 'get-url'; Description = 'Retrieves the URLs for a remote'; },
                    @{Subcommand = 'set-url'; Description = 'Changes URLs for the remote'; },
                    @{Subcommand = 'show'; Description = 'Gives some information'; },
                    @{Subcommand = 'prune'; Description = 'Deletes stale references'; },
                    @{Subcommand = 'update'; Description = 'Fetch updates for remotes or remote groups'; } | ForEach-Object {
                        $_.Subcommand | ConvertTo-Completion -ResultType ParameterName -ToolTip $_.Description
                    }
                },
                @{
                    Line     = 'set-';
                    Expected =
                    @{Subcommand = 'set-head'; Description = 'Sets or deletes the default branch for the named remote'; },
                    @{Subcommand = 'set-branches'; Description = 'Changes the list of branches tracked by the named remote'; },
                    @{Subcommand = 'set-url'; Description = 'Changes URLs for the remote'; } |
                    ForEach-Object {
                        $_.Subcommand | ConvertTo-Completion -ResultType ParameterName -ToolTip $_.Description
                    }
                }
            ) {
                It '<_>' -ForEach @(
                    '',
                    '-v',
                    '--verbose',
                    '--no-verbose'
                ) {
                    "git $Command $_ $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }
    }

    Describe 'add' {
        BeforeAll {
            Set-Variable Subcommand 'add'
        }

        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--fetch';
                        Right    = ' --';
                        Expected = '--fetch' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'fetch the remote branches'
                    },
                    @{
                        Left     = '--fetch';
                        Right    = ' -- --all';
                        Expected = '--fetch' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'fetch the remote branches'
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
                }
            }

            It '<Line>' -ForEach @(
                @{
                    Line     = '-- -';
                    Expected = @()
                },
                @{
                    Line     = '-- --';
                    Expected = @()
                },
                @{
                    Line     = 'origin -- -';
                    Expected = @()
                },
                @{
                    Line     = 'origin -- --';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        It 'ShortOptions' {
            $expected = @{
                ListItemText = '-f';
                ToolTip      = "fetch the remote branches";
            },
            @{
                ListItemText = '-m';
                ToolTip      = "master branch";
            },
            @{
                ListItemText = '-t';
                ToolTip      = "branch(es) to track";
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
                    Line     = '--t';
                    Expected = @{
                        ListItemText = '--tags';
                        ToolTip      = "import all tags and associated objects when fetching";
                    },
                    @{
                        ListItemText = '--track=';
                        ToolTip      = "branch(es) to track";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-t';
                    Expected = @{
                        ListItemText = '--no-tags';
                        ToolTip      = "[NO] import all tags and associated objects when fetching";
                    },
                    @{
                        ListItemText = '--no-track';
                        ToolTip      = "[NO] branch(es) to track";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--n';
                    Expected = @{
                        ListItemText = '--no-fetch';
                        ToolTip      = "[NO] fetch the remote branches";
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

        Describe 'None' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '.. ';
                    Expected = @()
                },
                @{
                    Line     = '--fetch ';
                    Expected = @()
                },
                @{
                    Line     = '';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'prune' {
        BeforeAll {
            Set-Variable Subcommand 'prune'
        }

        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--dry-run';
                        Right    = ' --';
                        Expected = '--dry-run' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'dry run'
                    },
                    @{
                        Left     = '--dry-run';
                        Right    = ' -- --all';
                        Expected = '--dry-run' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'dry run'
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
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
                    Expected =
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '-- ';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        It 'ShortOptions' {
            $expected = @{
                ListItemText = '-n';
                ToolTip      = "dry run";
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
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--dry-run';
                        ToolTip      = "dry run";
                    },
                    @{
                        ListItemText = '--no-dry-run';
                        ToolTip      = "[NO] dry run";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = '--no-dry-run' | ConvertTo-Completion -ResultType ParameterName -ToolTip "[NO] dry run"
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Remotes' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'o';
                    Expected =
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'remove' {
        BeforeAll {
            Set-Variable Subcommand 'remove'
        }

        Describe 'DoubleDash' {
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
                    Line     = '-- ';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'src -- ';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        It 'ShortOptions' {
            $expected = '-h' | ConvertTo-Completion -ResultType ParameterName -ToolTip "show help"
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

        Describe 'Remotes' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'o';
                    Expected =
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'rename' {
        BeforeAll {
            Set-Variable Subcommand 'rename'
        }

        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--progress';
                        Right    = ' --';
                        Expected = '--progress' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'force progress reporting'
                    },
                    @{
                        Left     = '--progress';
                        Right    = ' -- --all';
                        Expected = '--progress' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'force progress reporting'
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
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
                    Line     = '-- ';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'src -- ';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        It 'ShortOptions' {
            $expected = '-h' | ConvertTo-Completion -ResultType ParameterName -ToolTip "show help"
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--progress';
                        ToolTip      = "force progress reporting";
                    },
                    @{
                        ListItemText = '--no-progress';
                        ToolTip      = "[NO] force progress reporting";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--p';
                    Expected = '--progress' | ConvertTo-Completion -ResultType ParameterName -ToolTip "force progress reporting"
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Remotes' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'o';
                    Expected =
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'set-head' {
        BeforeAll {
            Set-Variable Subcommand 'set-head'
        }

        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--delete';
                        Right    = ' --';
                        Expected = '--delete' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'delete refs/remotes/<name>/HEAD'
                    },
                    @{
                        Left     = '--delete';
                        Right    = ' -- --all';
                        Expected = '--delete' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'delete refs/remotes/<name>/HEAD'
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
                }
            }

            It '<Line>' -ForEach @(
                @{
                    Line     = '-- -';
                    Expected = @()
                },
                @{
                    Line     = '-- --';
                    Expected = @()
                },
                @{
                    Line     = 'origin -- -';
                    Expected = @()
                },
                @{
                    Line     = 'origin -- --';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        It 'ShortOptions' {
            $expected = @{
                ListItemText = '-a';
                ToolTip      = "set refs/remotes/<name>/HEAD according to remote";
            },
            @{
                ListItemText = '-d';
                ToolTip      = "delete refs/remotes/<name>/HEAD";
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
                    Line     = '--d';
                    Expected = '--delete' | ConvertTo-Completion -ResultType ParameterName -ToolTip "delete refs/remotes/<name>/HEAD"
                },
                @{
                    Line     = '--no-d';
                    Expected = '--no-delete' | ConvertTo-Completion -ResultType ParameterName -ToolTip "[NO] delete refs/remotes/<name>/HEAD"
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-auto';
                        ToolTip      = "[NO] set refs/remotes/<name>/HEAD according to remote"
                    }, @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text'
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'RemoteOrRefspec' {
            Describe '<Line>' -ForEach @(
                @{
                    Line     = 'origin ';
                    Expected = 'HEAD', 'develop' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'origin d';
                    Expected = 'develop' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'origin +';
                    Expected = 'HEAD', 'develop' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "+$_" }
                },
                @{
                    Line     = 'origin +d';
                    Expected = 'develop' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "+$_" }
                },
                @{
                    Line     = 'origin left:';
                    Expected =
                    'HEAD',
                    'FETCH_HEAD',
                    'main',
                    'grm/HEAD',
                    'grm/develop',
                    'ordinary/HEAD',
                    'ordinary/develop',
                    'origin/HEAD',
                    'origin/develop',
                    'initial',
                    'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "left:$_" }
                },
                @{
                    Line     = 'origin left:m';
                    Expected = 'main' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "left:$_" }
                },
                @{
                    Line     = 'or';
                    Expected =
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                Describe 'DoubleDash' {
                    It '<DoubleDash>' -ForEach @('--', '--quiet --' | ForEach-Object { @{DoubleDash = $_; } }) {
                        "git $Command $Subcommand $DoubleDash $Line" | Complete-FromLine | Should -BeCompletion $expected
                    }
                }
    
                It '_' {
                    "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }
    }

    Describe 'set-branches' {
        BeforeAll {
            Set-Variable Subcommand 'set-branches'
        }

        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--add';
                        Right    = ' --';
                        Expected = '--add' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'add branch'
                    },
                    @{
                        Left     = '--add';
                        Right    = ' -- --all';
                        Expected = '--add' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'add branch'
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
                }
            }

            It '<Line>' -ForEach @(
                @{
                    Line     = '-- -';
                    Expected = @()
                },
                @{
                    Line     = '-- --';
                    Expected = @()
                },
                @{
                    Line     = 'origin -- -';
                    Expected = @()
                },
                @{
                    Line     = 'origin -- --';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        It 'ShortOptions' {
            $expected = '-h' | ConvertTo-Completion -ResultType ParameterName -ToolTip "show help"
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--add';
                        ToolTip      = "add branch";
                    },
                    @{
                        ListItemText = '--no-add';
                        ToolTip      = "[NO] add branch";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--a';
                    Expected = '--add' | ConvertTo-Completion -ResultType ParameterName -ToolTip "add branch"
                },
                @{
                    Line     = '--no';
                    Expected = '--no-add' | ConvertTo-Completion -ResultType ParameterName -ToolTip "[NO] add branch"
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'RemoteOrRefspec' {
            Describe '<Line>' -ForEach @(
                @{
                    Line     = 'origin ';
                    Expected = 'HEAD', 'develop' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'origin d';
                    Expected = 'develop' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'origin +';
                    Expected = 'HEAD', 'develop' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "+$_" }
                },
                @{
                    Line     = 'origin +d';
                    Expected = 'develop' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "+$_" }
                },
                @{
                    Line     = 'origin left:';
                    Expected =
                    'HEAD',
                    'FETCH_HEAD',
                    'main',
                    'grm/HEAD',
                    'grm/develop',
                    'ordinary/HEAD',
                    'ordinary/develop',
                    'origin/HEAD',
                    'origin/develop',
                    'initial',
                    'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "left:$_" }
                },
                @{
                    Line     = 'origin left:m';
                    Expected = 'main' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "left:$_" }
                },
                @{
                    Line     = 'or';
                    Expected =
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                Describe 'DoubleDash' {
                    It '<DoubleDash>' -ForEach @('--', '--quiet --' | ForEach-Object { @{DoubleDash = $_; } }) {
                        "git $Command $Subcommand $DoubleDash $Line" | Complete-FromLine | Should -BeCompletion $expected
                    }
                }
    
                It '_' {
                    "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }
    }

    Describe 'get-url' {
        BeforeAll {
            Set-Variable Subcommand 'get-url'
        }

        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--all';
                        Right    = ' --';
                        Expected = '--all' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'return all URLs'
                    },
                    @{
                        Left     = '--all';
                        Right    = ' -- --all';
                        Expected = '--all' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'return all URLs'
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
                }
            }

            It '<Line>' -ForEach @(
                @{
                    Line     = '-- -';
                    Expected = @()
                },
                @{
                    Line     = '-- --';
                    Expected = @()
                },
                @{
                    Line     = 'origin -- -';
                    Expected = @()
                },
                @{
                    Line     = 'origin -- --';
                    Expected = @()
                },
                @{
                    Line     = '-- ';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        It 'ShortOptions' {
            $expected = '-h' | ConvertTo-Completion -ResultType ParameterName -ToolTip "show help"
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--a';
                    Expected = '--all' | ConvertTo-Completion -ResultType ParameterName -ToolTip "return all URLs"
                },
                @{
                    Line     = '--no-a';
                    Expected = '--no-all' | ConvertTo-Completion -ResultType ParameterName -ToolTip "[NO] return all URLs"
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-push';
                        ToolTip      = "[NO] query push URLs rather than fetch URLs";
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

        Describe 'Remotes' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'o';
                    Expected =
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'set-url' {
        BeforeAll {
            Set-Variable Subcommand 'set-url'
        }

        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--add';
                        Right    = ' --';
                        Expected = '--add' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'add URL'
                    },
                    @{
                        Left     = '--add';
                        Right    = ' -- --all';
                        Expected = '--add' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'add URL'
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
                }
            }

            It '<Line>' -ForEach @(
                @{
                    Line     = '-- -';
                    Expected = @()
                },
                @{
                    Line     = '-- --';
                    Expected = @()
                },
                @{
                    Line     = 'origin -- -';
                    Expected = @()
                },
                @{
                    Line     = 'origin -- --';
                    Expected = @()
                },
                @{
                    Line     = '-- ';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        It 'ShortOptions' {
            $expected = '-h' | ConvertTo-Completion -ResultType ParameterName -ToolTip "show help"
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--a';
                    Expected = '--add' | ConvertTo-Completion -ResultType ParameterName -ToolTip "add URL"
                },
                @{
                    Line     = '--no-a';
                    Expected = '--no-add' | ConvertTo-Completion -ResultType ParameterName -ToolTip "[NO] add URL"
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-push';
                        ToolTip      = "[NO] manipulate push URLs";
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

        Describe 'Remotes' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'o';
                    Expected =
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'show' {
        BeforeAll {
            Set-Variable Subcommand 'show'
        }

        Describe 'DoubleDash' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '-- -';
                    Expected = @()
                },
                @{
                    Line     = '-- --';
                    Expected = @()
                },
                @{
                    Line     = 'origin -- -';
                    Expected = @()
                },
                @{
                    Line     = 'origin -- --';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        It 'ShortOptions' {
            $expected = @{
                ListItemText = '-n';
                ToolTip      = "do not query remotes";
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
                    Line     = '--';
                    Expected = @()
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Remotes' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'o';
                    Expected =
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'update' {
        BeforeAll {
            Set-Variable Subcommand 'update'
        }

        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--prune';
                        Right    = ' --';
                        Expected = '--prune' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'prune remotes after fetching'
                    },
                    @{
                        Left     = '--prune';
                        Right    = ' -- --all';
                        Expected = '--prune' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'prune remotes after fetching'
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
                }
            }

            It '<Line>' -ForEach @(
                @{
                    Line     = '-- -';
                    Expected = @()
                },
                @{
                    Line     = '-- --';
                    Expected = @()
                },
                @{
                    Line     = 'origin -- -';
                    Expected = @()
                },
                @{
                    Line     = 'origin -- --';
                    Expected = @()
                },
                @{
                    Line     = '-- ';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin',
                    @{
                        ListItemText = 'default';
                        Tooltip      = 'origin grm';
                    },
                    @{
                        ListItemText = 'ors';
                        Tooltip      = 'origin ordinary';
                    } | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        It 'ShortOptions' {
            $expected = @{
                ListItemText = '-p';
                ToolTip      = "prune remotes after fetching";
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
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--prune';
                        ToolTip      = "prune remotes after fetching";
                    },
                    @{
                        ListItemText = '--no-prune';
                        ToolTip      = "[NO] prune remotes after fetching";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--p';
                    Expected = '--prune' | ConvertTo-Completion -ResultType ParameterName -ToolTip "prune remotes after fetching"
                },
                @{
                    Line     = '--no';
                    Expected = '--no-prune' | ConvertTo-Completion -ResultType ParameterName -ToolTip "[NO] prune remotes after fetching"
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'RemoteOrGroup' {
            It '<Line>' -ForEach @(
                @{
                    Line     = 'origin d';
                    Expected = @{
                        ListItemText = 'default';
                        Tooltip      = 'origin grm';
                    } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'or or';
                    Expected =
                    'ordinary',
                    'origin',
                    @{
                        ListItemText = 'ors';
                        Tooltip      = 'origin ordinary';
                    } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'or';
                    Expected =
                    'ordinary',
                    'origin',
                    @{
                        ListItemText = 'ors';
                        Tooltip      = 'origin ordinary';
                    } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '';
                    Expected =
                    'grm',
                    'ordinary',
                    'origin',
                    @{
                        ListItemText = 'default';
                        Tooltip      = 'origin grm';
                    },
                    @{
                        ListItemText = 'ors';
                        Tooltip      = 'origin ordinary';
                    } | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}
