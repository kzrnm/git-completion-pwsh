# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
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
        git config set pretty.changelog "format:* %H %s"
        1..10 | ForEach-Object { git commit -m "cm$_" --allow-empty }

        $headCommit = git show -s HEAD --oneline --no-decorate
        function replace-Tooltip {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '')]
            param ([Parameter(ValueFromPipeline)] $Object)

            process {
                if ($Object.ListItemText -in 'HEAD', 'main') {
                    $Object.ToolTip = $headCommit
                }
                $Object
            }
        }
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe 'NotInState' {
        It 'Subcommands' {
            $Expected = @{
                ListItemText = 'start';
                ToolTip      = "start bisection state";
            },
            @{
                ListItemText = 'replay';
                ToolTip      = "show what has been done so far from logfile";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command " | Complete-FromLine | Should -BeCompletion $Expected
        }

        Describe 'start' {
            BeforeAll {
                Set-Variable Subcommand 'start'
            }
    
            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--';
                        Expected =
                        '--first-parent',
                        '--no-checkout',
                        '--term-new',
                        '--term-bad',
                        '--term-old',
                        '--term-good' | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Line     = '--t';
                        Expected =
                        '--term-new',
                        '--term-bad',
                        '--term-old',
                        '--term-good' | ConvertTo-Completion -ResultType ParameterName
                    }
                ) {
                    "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        Describe '<Subcommand>' -ForEach @('start' | ForEach-Object { @{Subcommand = $_ } }) {
            Describe-Revlist -Ref {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion ($expected | replace-Tooltip)
            }
        }
    }

    Describe 'InState:Good=<Good>:Bad=<Bad>' -ForEach @(
        @{
            Good = 'good';
            Bad  = 'bad';
        },
        @{
            Good = 'deava';
            Bad  = 'nesta';
        }
    ) {
        BeforeEach {
            if (($Bad -eq 'bad') -and ($Good -eq 'good')) {
                git bisect start
            }
            else {
                git bisect start --term-bad "$Bad" --term-good "$Good"
            }
        }
        AfterEach {
            $ErrorActionPreference = 'SilentlyContinue'
            git bisect reset 2>$null
        }
        It 'Subcommands' -ForEach @{Good = $Good; Bad = $Bad } {
            $Expected = @{
                ListItemText = $Good;
                ToolTip      = "mark the commit as good";
            },
            @{
                ListItemText = $Bad;
                ToolTip      = "mark the commit as bad";
            },
            @{
                ListItemText = 'reset';
                ToolTip      = "clean up the bisection state";
            },
            @{
                ListItemText = 'terms';
                ToolTip      = "get a reminder of the currently used terms get a reminder of the currently used terms";
            },
            @{
                ListItemText = 'start';
                ToolTip      = "start bisection state";
            },
            'next',
            @{
                ListItemText = 'log';
                ToolTip      = "show what has been done so far";
            },
            @{
                ListItemText = 'replay';
                ToolTip      = "show what has been done so far from logfile";
            },
            @{
                ListItemText = 'skip';
                ToolTip      = "skip a commit adjacent";
            },
            @{
                ListItemText = 'visualize';
                ToolTip      = "see the currently remaining suspects in gitk";
            },
            @{
                ListItemText = 'view';
                ToolTip      = "see the currently remaining suspects in gitk";
            },
            @{
                ListItemText = 'run';
                ToolTip      = "bisect by issuing the command";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command " | Complete-FromLine | Should -BeCompletion ($expected | replace-Tooltip)
        }

        Describe '<Subcommand>' -ForEach @('start', $Bad, $Good, 'reset', 'skip' | ForEach-Object { @{Subcommand = $_ } }) {
            Describe-Revlist -Ref {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion ($expected | replace-Tooltip)
            }
        }

        Describe 'start' {
            BeforeAll {
                Set-Variable Subcommand 'start'
            }
    
            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--';
                        Expected =
                        '--first-parent',
                        '--no-checkout',
                        '--term-new',
                        '--term-bad',
                        '--term-old',
                        '--term-good' | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Line     = '--t';
                        Expected =
                        '--term-new',
                        '--term-bad',
                        '--term-old',
                        '--term-good' | ConvertTo-Completion -ResultType ParameterName
                    }
                ) {
                    "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        Describe 'terms' {
            BeforeAll {
                Set-Variable Subcommand 'terms'
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--';
                        Expected =
                        '--term-good',
                        '--term-old',
                        '--term-bad',
                        '--term-new' | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Line     = '--t';
                        Expected =
                        '--term-good',
                        '--term-old',
                        '--term-bad',
                        '--term-new' | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Line     = '--term-g';
                        Expected =
                        '--term-good' | ConvertTo-Completion -ResultType ParameterName
                    }
                ) {
                    "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }

        Describe '<Subcommand>' -ForEach @(
            'view', 'visualize' | ForEach-Object { @{Subcommand = $_ } }
        ) {
            Describe 'DoubleDash' {
                Describe 'InRight' {
                    It '<Left>(cursor)<Right>' -ForEach @(
                        @{
                            Left     = '--quiet';
                            Right    = ' --';
                            Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--quiet'
                        },
                        @{
                            Left     = '--quiet';
                            Right    = ' -- --all';
                            Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--quiet'
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
                        Line     = 'src -- ';
                        Expected = @()
                    },
                    @{
                        Line     = '-- ';
                        Expected = @()
                    }
                ) {
                    "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Describe 'Options' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--bi';
                        Expected = '--binary', '--bisect' | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Line     = '--no-p';
                        Expected = '--no-patch', '--no-prefix' | ConvertTo-Completion -ResultType ParameterName
                    }
                ) {
                    "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
    
            Describe 'OptionValue' {
                It '<Line>' -ForEach @(
                    @{
                        Line     = '--ws-error-highlight d';
                        Expected = @{
                            ListItemText = 'default';
                            Tooltip      = 'A synonym for new';                        
                        } | ConvertTo-Completion -ResultType ParameterValue
                    },
                    @{
                        Line     = '--ws-error-highlight ';
                        Expected = @{
                            ListItemText = 'all';
                            Tooltip      = 'A synonym for old,new,context';                        
                        },
                        @{
                            ListItemText = 'context';
                            Tooltip      = 'Highlight whitespace errors in the context';                        
                        },
                        @{
                            ListItemText = 'default';
                            Tooltip      = 'A synonym for new';                        
                        },
                        @{
                            ListItemText = 'new';
                            Tooltip      = 'Highlight whitespace errors in the new lines of the diff';                        
                        },
                        @{
                            ListItemText = 'old';
                            Tooltip      = 'Highlight whitespace errors in the old lines of the diff';                        
                        } | ConvertTo-Completion -ResultType ParameterValue
                    },
                    @{
                        Line     = '--ws-error-highlight=d';
                        Expected = @{
                            ListItemText = 'default';
                            Tooltip      = 'A synonym for new';                        
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--ws-error-highlight=$_" }
                    },
                    @{
                        Line     = '--ws-error-highlight=';
                        Expected = @{
                            ListItemText = 'all';
                            Tooltip      = 'A synonym for old,new,context';                        
                        },
                        @{
                            ListItemText = 'context';
                            Tooltip      = 'Highlight whitespace errors in the context';                        
                        },
                        @{
                            ListItemText = 'default';
                            Tooltip      = 'A synonym for new';                        
                        },
                        @{
                            ListItemText = 'new';
                            Tooltip      = 'Highlight whitespace errors in the new lines of the diff';                        
                        },
                        @{
                            ListItemText = 'old';
                            Tooltip      = 'Highlight whitespace errors in the old lines of the diff';                        
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--ws-error-highlight=$_" }
                    },
                    @{
                        Line     = '--no-walk=u';
                        Expected = 'unsorted' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--no-walk=$_" }
                    },
                    @{
                        Line     = '--no-walk=';
                        Expected = 'sorted', 'unsorted' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--no-walk=$_" }
                    },
                    @{
                        Line     = '--diff-merges o';
                        Expected = 'off', 'on' | ConvertTo-Completion -ResultType ParameterValue
                    },
                    @{
                        Line     = '--diff-merges ';
                        Expected = '1', 'c', 'cc', 'combined', 'dense-combined', 'first-parent', 'm', 'none', 'off', 'on', 'r', 'remerge', 'separate' | ConvertTo-Completion -ResultType ParameterValue
                    },
                    @{
                        Line     = '--diff-merges=o';
                        Expected = 'off', 'on' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--diff-merges=$_" }
                    },
                    @{
                        Line     = '--diff-merges=';
                        Expected = '1', 'c', 'cc', 'combined', 'dense-combined', 'first-parent', 'm', 'none', 'off', 'on', 'r', 'remerge', 'separate' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--diff-merges=$_" }
                    },
                    @{
                        Line     = '--submodule=d';
                        Expected = @{
                            ListItemText = 'diff';
                            Tooltip      = 'Shows an inline diff of the changed contents of the submodule';
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--submodule=$_" }
                    },
                    @{
                        Line     = '--submodule=';
                        Expected = @{
                            ListItemText = 'diff';
                            Tooltip      = 'Shows an inline diff of the changed contents of the submodule';
                        },
                        @{
                            ListItemText = 'log';
                            Tooltip      = 'Lists the commits in the range like "git submodule summary" does';
                        },
                        @{
                            ListItemText = 'short';
                            Tooltip      = '(default) Shows the names of the commits at the beginning and end of the range';
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--submodule=$_" }
                    },
                    @{
                        Line     = '--diff-algorithm m';
                        Expected = 
                        @{
                            ListItemText = 'minimal';
                            ToolTip      = 'Spend extra time to make sure the smallest possible diff is produced';
                        },
                        @{
                            ListItemText = 'myers';
                            ToolTip      = '(default) The basic greedy diff algorithm';
                        } | ConvertTo-Completion -ResultType ParameterValue
                    },
                    @{
                        Line     = '--diff-algorithm ';
                        Expected = @{
                            ListItemText = 'histogram';
                            ToolTip      = 'This algorithm extends the patience algorithm to "support low-occurrence common elements"';
                        },
                        @{
                            ListItemText = 'minimal';
                            ToolTip      = 'Spend extra time to make sure the smallest possible diff is produced';
                        },
                        @{
                            ListItemText = 'myers';
                            ToolTip      = '(default) The basic greedy diff algorithm';
                        },
                        @{
                            ListItemText = 'patience';
                            ToolTip      = 'Use "patience diff" algorithm when generating patches';
                        } | ConvertTo-Completion -ResultType ParameterValue
                    },
                    @{
                        Line     = '--diff-algorithm=m';
                        Expected = 
                        @{
                            CompletionText = "--diff-algorithm=minimal";
                            ListItemText   = 'minimal';
                            ToolTip        = 'Spend extra time to make sure the smallest possible diff is produced';
                        },
                        @{
                            CompletionText = "--diff-algorithm=myers";
                            ListItemText   = 'myers';
                            ToolTip        = '(default) The basic greedy diff algorithm';
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--diff-algorithm=$_" }
                    },
                    @{
                        Line     = '--diff-algorithm=';
                        Expected = @{
                            CompletionText = "--diff-algorithm=histogram";
                            ListItemText   = 'histogram';
                            ToolTip        = 'This algorithm extends the patience algorithm to "support low-occurrence common elements"';
                        },
                        @{
                            CompletionText = "--diff-algorithm=minimal";
                            ListItemText   = 'minimal';
                            ToolTip        = 'Spend extra time to make sure the smallest possible diff is produced';
                        },
                        @{
                            CompletionText = "--diff-algorithm=myers";
                            ListItemText   = 'myers';
                            ToolTip        = '(default) The basic greedy diff algorithm';
                        },
                        @{
                            CompletionText = "--diff-algorithm=patience";
                            ListItemText   = 'patience';
                            ToolTip        = 'Use "patience diff" algorithm when generating patches';
                        } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--diff-algorithm=$_" }
                    },
                    @{
                        Line     = '--decorate=f';
                        Expected = 'full' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--decorate=$_" }
                    },
                    @{
                        Line     = '--decorate=';
                        Expected = 'full', 'short', 'no' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--decorate=$_" }
                    },
                    @{
                        Line     = '--date iso';
                        Expected = 'iso8601', 'iso8601-strict' | ConvertTo-Completion -ResultType ParameterValue
                    },
                    @{
                        Line     = '--date ';
                        Expected = 'auto:', 'default', 'format:', 'human', 'iso8601', 'iso8601-strict', 'local', 'raw', 'relative', 'rfc2822', 'short', 'unix' | ConvertTo-Completion -ResultType ParameterValue
                    },
                    @{
                        Line     = '--date=iso';
                        Expected = 'iso8601', 'iso8601-strict' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--date=$_" }
                    },
                    @{
                        Line     = '--date=';
                        Expected = 'auto:', 'default', 'format:', 'human', 'iso8601', 'iso8601-strict', 'local', 'raw', 'relative', 'rfc2822', 'short', 'unix' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--date=$_" }
                    },
                    @{
                        Line     = '--format=m';
                        Expected = 'mboxrd', 'medium' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--format=$_" }
                    },
                    @{
                        Line     = '--format=';
                        Expected = @{
                            ListItemText = 'changelog';
                            Tooltip      = 'format:* %H %s';
                        },
                        'email', 'format:', 'full', 'fuller', 'mboxrd', 'medium',
                        'oneline', 'raw', 'reference', 'short', 'tformat:' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--format=$_" }
                    },
                    @{
                        Line     = '--pretty=f';
                        Expected = 'format:', 'full', 'fuller' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--pretty=$_" }
                    },
                    @{
                        Line     = '--pretty=';
                        Expected = @{
                            ListItemText = 'changelog';
                            Tooltip      = 'format:* %H %s';
                        },
                        'email', 'format:', 'full', 'fuller', 'mboxrd', 'medium',
                        'oneline', 'raw', 'reference', 'short', 'tformat:' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--pretty=$_" }
                    }
                ) {
                    "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }
    }
}