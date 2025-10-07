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
                Expected = 
                'main',
                'HEAD',
                'develop' | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $Expected = @{
            ListItemText = '-c';
            ToolTip      = "create and switch to a new branch";
        },
        @{
            ListItemText = '-C';
            ToolTip      = "create/reset and switch to a branch";
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
            ListItemText = '-m';
            ToolTip      = "perform a 3-way merge with the new branch";
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
                    ListItemText = '--orphan=';
                    ToolTip      = "new unborn branch";
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
                    ListItemText = '--no-orphan';
                    ToolTip      = "[NO] new unborn branch";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-g';
                Expected = @{
                    ListItemText = '--no-guess';
                    ToolTip      = "[NO] second guess 'git switch <no-such-branch>'";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-create';
                    ToolTip      = "[NO] create and switch to a new branch";
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
                Line     = '-c ';
                Expected = 
                'main',
                'HEAD',
                'develop' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-c m';
                Expected = 'main' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-C ';
                Expected = 
                'main',
                'HEAD',
                'develop' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-C m';
                Expected = 'main' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--orphan ';
                Expected = 
                'main',
                'HEAD',
                'develop' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--orphan m';
                Expected = 'main' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--orphan=';
                Expected = 
                'main',
                'HEAD',
                'develop' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--orphan=$_" }
            },
            @{
                Line     = '--orphan=m';
                Expected = 'main' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--orphan=$_" }
            },
            @{
                Line     = '--conflict ';
                Expected = @{
                    ListItemText = 'diff3';
                    Tooltip      = "Adds the common ancestor's content, providing a three-way comparison";
                }, @{
                    ListItemText = 'merge';
                    Tooltip      = '(default) Showing only current changes and the incoming changes';
                }, @{
                    ListItemText = 'zdiff3';
                    Tooltip      = 'Similar to diff3 but minimizes the conflict markers by moving common surrounding lines outside the conflicted block';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--conflict m';
                Expected = @{
                    ListItemText = 'merge';
                    Tooltip      = '(default) Showing only current changes and the incoming changes';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--conflict=';
                Expected = @{
                    ListItemText = 'diff3';
                    Tooltip      = "Adds the common ancestor's content, providing a three-way comparison";
                }, @{
                    ListItemText = 'merge';
                    Tooltip      = '(default) Showing only current changes and the incoming changes';
                }, @{
                    ListItemText = 'zdiff3';
                    Tooltip      = 'Similar to diff3 but minimizes the conflict markers by moving common surrounding lines outside the conflicted block';
                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--conflict=$_" }
            },
            @{
                Line     = '--conflict=m';
                Expected = @{
                    ListItemText = 'merge';
                    Tooltip      = '(default) Showing only current changes and the incoming changes';
                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--conflict=$_" }
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
                    'main',
                    'HEAD',
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
            '-d',
            '--guess -c main',
            '--guess -C main',
            '-t --detach',
            '-t -d',
            '-t --guess -c main',
            '-t --guess -C main' | ForEach-Object { @{Option = $_; } }
        ) {
            It '<Line>' -ForEach @(
                @{
                    Line     = '';
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
                    'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'm';
                    Expected = 'main' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
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
                    'grm/HEAD',
                    'grm/develop',
                    'ordinary/HEAD',
                    'ordinary/develop',
                    'origin/HEAD',
                    'origin/develop' | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = 'o';
                    Expected =
                    'ordinary/HEAD',
                    'ordinary/develop',
                    'origin/HEAD',
                    'origin/develop' | ConvertTo-Completion -ResultType ParameterValue
                }
            ) {
                "git $Command $Option $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'Dwim' {
        BeforeAll {
            Set-Variable guessCase (
                'main',
                'HEAD',
                'develop' | ConvertTo-Completion -ResultType ParameterValue
            )
            Set-Variable noGuessCase (
                'main' | ConvertTo-Completion -ResultType ParameterValue
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