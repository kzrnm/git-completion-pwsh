# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
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
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'suppress progress reporting'
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --all';
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
            },
            @{
                Line     = '-- ';
                Expected = @()
            },
            @{
                Line     = 'src -- ';
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
            ListItemText = '-b';
            ToolTip      = "create and checkout a new branch";
        },
        @{
            ListItemText = '-B';
            ToolTip      = "create/reset and checkout a branch";
        },
        @{
            ListItemText = '-d';
            ToolTip      = "detach HEAD at named commit";
        },
        @{
            ListItemText = '-f';
            ToolTip      = "force checkout (throw away local modifications)";
        },
        @{
            ListItemText = '-l';
            ToolTip      = "create reflog for new branch";
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
            ListItemText = '-t';
            ToolTip      = "set branch tracking configuration";
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
                    ToolTip      = "use overlay mode (default)";
                },
                @{
                    ListItemText = '--orphan=';
                    ToolTip      = "new unborn branch";
                },
                @{
                    ListItemText = '--ours';
                    ToolTip      = "checkout our version for unmerged files";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--q';
                Expected = @{
                    ListItemText = '--quiet';
                    ToolTip      = "suppress progress reporting";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-o';
                Expected = @{
                    ListItemText = '--no-overlay';
                    ToolTip      = "[NO] use overlay mode (default)";
                },
                @{
                    ListItemText = '--no-orphan';
                    ToolTip      = "[NO] new unborn branch";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-g';
                Expected = @{
                    ListItemText = '--no-guess';
                    ToolTip      = "[NO] second guess 'git checkout <no-such-branch>' (default)";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-guess';
                    ToolTip      = "[NO] second guess 'git checkout <no-such-branch>' (default)";
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

    Describe 'OptionValue' {
        It '<Line>' -ForEach @(
            @{
                Line     = '-b ';
                Expected = 'main', 'develop' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-b m';
                Expected = 'main' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-B ';
                Expected = 'main', 'develop' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-B m';
                Expected = 'main' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--orphan ';
                Expected = 'main', 'develop' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--orphan m';
                Expected = 'main' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--orphan=';
                Expected = 'main', 'develop' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--orphan=$_" }
            },
            @{
                Line     = '--orphan=m';
                Expected = 'main' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--orphan=$_" }
            },
            @{
                Line     = '--conflict ';
                Expected = 'diff3', 'merge', 'zdiff3' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--conflict m';
                Expected = 'merge' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--conflict=';
                Expected = 'diff3', 'merge', 'zdiff3' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--conflict=$_" }
            },
            @{
                Line     = '--conflict=m';
                Expected = 'merge' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--conflict=$_" }
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'Ordinary' {
        Describe 'Default:<Option>' -ForEach @(
            '--patch',
            '' | ForEach-Object { @{Option = $_; } }
        ) {
            It '<Line>' -ForEach @(
                @{
                    Line     = '';
                    Expected =
                    'HEAD',
                    'FETCH_HEAD',
                    'main',
                    'grm/develop',
                    'ordinary/develop',
                    'origin/develop',
                    'initial',
                    'zeta',
                    'develop' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'm';
                    Expected = 'main' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Option $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Refs:<Option>' -ForEach @(
            '--detach',
            '--orphan -2',
            '-d',
            '--guess -b main',
            '--guess -B main',
            '-t --detach',
            '-t --orphan -2',
            '-t -d',
            '-t --guess -b main',
            '-t --guess -B main' | ForEach-Object { @{Option = $_; } }
        ) {
            It '<Line>' -ForEach @(
                @{
                    Line     = '';
                    Expected =
                    'HEAD',
                    'FETCH_HEAD',
                    'main',
                    'grm/develop',
                    'ordinary/develop',
                    'origin/develop',
                    'initial',
                    'zeta' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'm';
                    Expected = 'main' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Option $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Remote:<Option>' -ForEach @(
            '-t',
            '--track' | ForEach-Object { @{Option = $_; } }
        ) {
            It '<Line>' -ForEach @(
                @{
                    Line     = '';
                    Expected =
                    'grm/develop',
                    'ordinary/develop',
                    'origin/develop' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'o';
                    Expected = 'ordinary/develop', 'origin/develop'  | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Option $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'Dwim' {
        BeforeAll {
            Set-Variable guessCase (
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/develop',
                'ordinary/develop',
                'origin/develop',
                'initial',
                'zeta',
                'develop' | ConvertTo-Completion -ResultType ParameterValue
            )
            Set-Variable noGuessCase (
                'HEAD',
                'FETCH_HEAD',
                'main',
                'grm/develop',
                'ordinary/develop',
                'origin/develop',
                'initial',
                'zeta' | ConvertTo-Completion -ResultType ParameterValue
            )
        }
        Describe 'CheckoutNoGuess' {
            BeforeAll {
                $GitCompletionSettings.CheckoutNoGuess = 1
            }
            AfterAll {
                $GitCompletionSettings.CheckoutNoGuess = $false
            }

            It '_' {
                "git $Command " | Complete-FromLine | Should -BeCompletion $noGuessCase
            }

            It 'Config:false' {
                "git -c checkout.guess=false $Command " | Complete-FromLine | Should -BeCompletion $noGuessCase
            }

            It '--no-track' {
                "git $Command --no-track -2 " | Complete-FromLine | Should -BeCompletion $noGuessCase
            }

            It '--no-guess' {
                "git $Command --no-guess -2 " | Complete-FromLine | Should -BeCompletion $noGuessCase
            }

            It '--guess' {
                "git $Command --guess -2 " | Complete-FromLine | Should -BeCompletion $guessCase
            }
        }

        Describe 'Config:false' {
            BeforeAll {
                $GitCompletionSettings.CheckoutNoGuess = 1
            }
            AfterAll {
                $GitCompletionSettings.CheckoutNoGuess = $false
            }

            It '_' {
                "git -c checkout.guess=false $Command " | Complete-FromLine | Should -BeCompletion $noGuessCase
            }

            It '--no-track' {
                "git -c checkout.guess=false $Command --no-track -2 " | Complete-FromLine | Should -BeCompletion $noGuessCase
            }

            It '--no-guess' {
                "git -c checkout.guess=false $Command --no-guess -2 " | Complete-FromLine | Should -BeCompletion $noGuessCase
            }

            It '--guess' {
                "git -c checkout.guess=false $Command --guess -2 " | Complete-FromLine | Should -BeCompletion $guessCase
            }
        }

        Describe '--no-track' {
            BeforeAll {
                $GitCompletionSettings.CheckoutNoGuess = 1
            }
            AfterAll {
                $GitCompletionSettings.CheckoutNoGuess = $false
            }

            It '_' {
                "git $Command --no-track " | Complete-FromLine | Should -BeCompletion $noGuessCase
            }

            It '--no-track' {
                "git $Command --no-track -2 " | Complete-FromLine | Should -BeCompletion $noGuessCase
            }

            It '--no-guess' {
                "git $Command --no-track --no-guess -2 " | Complete-FromLine | Should -BeCompletion $noGuessCase
            }

            It '--guess' {
                "git $Command --no-track --guess -2 " | Complete-FromLine | Should -BeCompletion $guessCase
            }
        }

        Describe 'Guess' {
            BeforeAll {
                $GitCompletionSettings.CheckoutNoGuess = 1
            }
            AfterAll {
                $GitCompletionSettings.CheckoutNoGuess = $false
            }

            It '--no-guess' {
                "git $Command --no-guess -2 " | Complete-FromLine | Should -BeCompletion $noGuessCase
            }

            It '--guess' {
                "git $Command --guess -2 " | Complete-FromLine | Should -BeCompletion $guessCase
            }

            It '--guess:force' {
                "git -c checkout.guess=false $Command --no-track --guess -2 " | Complete-FromLine | Should -BeCompletion $guessCase
            }
        }
    }
}