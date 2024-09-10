using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag Remote, File {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")
        Initialize-FilesRepo $rootPath $remotePath
        Push-Location $rootPath
        git config set trailer.sigob.key "signed-off-by: "
        git config set trailer.helpb.key "Helped-by: "
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
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'suppress summary after successful commit'
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --all';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'suppress summary after successful commit'
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
            ListItemText = '-a';
            ToolTip      = "commit all changed files";
        },
        @{
            ListItemText = '-c';
            ToolTip      = "reuse and edit message from specified commit";
        },
        @{
            ListItemText = '-C';
            ToolTip      = "reuse message from specified commit";
        },
        @{
            ListItemText = '-e';
            ToolTip      = "force edit of commit";
        },
        @{
            ListItemText = '-F';
            ToolTip      = "read message from file";
        },
        @{
            ListItemText = '-i';
            ToolTip      = "add specified files to index for commit";
        },
        @{
            ListItemText = '-m';
            ToolTip      = "commit message";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "bypass pre-commit and commit-msg hooks";
        },
        @{
            ListItemText = '-o';
            ToolTip      = "commit only specified files";
        },
        @{
            ListItemText = '-p';
            ToolTip      = "interactively add changes";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "suppress summary after successful commit";
        },
        @{
            ListItemText = '-s';
            ToolTip      = "add a signed-off-by trailer";
        },
        @{
            ListItemText = '-S';
            ToolTip      = "GPG sign commit";
        },
        @{
            ListItemText = '-t';
            ToolTip      = "use specified template file";
        },
        @{
            ListItemText = '-u';
            ToolTip      = "show untracked files, optional modes: all, normal, no. (Default: all)";
        },
        @{
            ListItemText = '-v';
            ToolTip      = "show diff in commit message template";
        },
        @{
            ListItemText = '-z';
            ToolTip      = "terminate entries with NUL";
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
                Line     = '--c';
                Expected = @{
                    ListItemText = '--cleanup=';
                    ToolTip      = "how to strip spaces and #comments from message";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--m';
                Expected = @{
                    ListItemText = '--message=';
                    ToolTip      = "commit message";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--v';
                Expected = @{
                    ListItemText = '--verbose';
                    ToolTip      = "show diff in commit message template";
                },
                @{
                    ListItemText = '--verify';
                    ToolTip      = "opposite of --no-verify";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-v';
                Expected = @{
                    ListItemText = '--no-verify';
                    ToolTip      = "bypass pre-commit and commit-msg hooks";
                },
                @{
                    ListItemText = '--no-verbose';
                    ToolTip      = "[NO] show diff in commit message template";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-verify';
                    ToolTip      = "bypass pre-commit and commit-msg hooks";
                },
                @{
                    ListItemText = '--no-post-rewrite';
                    ToolTip      = "bypass post-rewrite hook";
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
        Describe 'Revlist:<_>' -ForEach @('-C',
            '-c',
            '--reuse-message',
            '--reedit-message',
            '--fixup',
            '--squash') {
            BeforeDiscovery {
                $option = $_
                Set-Variable 'Data' @(
                    @{
                        Line     = "$option ";
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
                        Line     = "$option o";
                        Expected = 
                        'ordinary/develop',
                        'origin/develop' | ConvertTo-Completion -ResultType ParameterValue
                    },
                    @{
                        Line     = "$option ^";
                        Expected =
                        'HEAD',
                        'FETCH_HEAD',
                        'main',
                        'grm/develop',
                        'ordinary/develop',
                        'origin/develop',
                        'initial',
                        'zeta' | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue
                    },
                    @{
                        Line     = "$option ^o";
                        Expected = 
                        '^ordinary/develop',
                        '^origin/develop' | ConvertTo-Completion -ResultType ParameterValue
                    }
                )

                if ($option.StartsWith('--')) {
                    $Data += @(
                        @{
                            Line     = "$option=";
                            Expected =
                            'HEAD',
                            'FETCH_HEAD',
                            'main',
                            'grm/develop',
                            'ordinary/develop',
                            'origin/develop',
                            'initial',
                            'zeta' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "$option=$_" }
                        },
                        @{
                            Line     = "$option=o";
                            Expected = 
                            'ordinary/develop',
                            'origin/develop' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "$option=$_" }
                        },
                        @{
                            Line     = "$option=^";
                            Expected =
                            'HEAD',
                            'FETCH_HEAD',
                            'main',
                            'grm/develop',
                            'ordinary/develop',
                            'origin/develop',
                            'initial',
                            'zeta' | ForEach-Object { "^$_" } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "$option=$_" }
                        },
                        @{
                            Line     = "$option=^o";
                            Expected = 
                            '^ordinary/develop',
                            '^origin/develop' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "$option=$_" }
                        }
                    )
                }
            }

            It '<Line>' -ForEach $Data {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
        It '<Line>' -ForEach @(
            @{
                Line     = '--cleanup ';
                Expected = 
                'default', 'scissors', 'strip', 'verbatim', 'whitespace' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--cleanup s';
                Expected = 
                'scissors', 'strip' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--cleanup=';
                Expected =
                'default', 'scissors', 'strip', 'verbatim', 'whitespace' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--cleanup=$_" }
            },
            @{
                Line     = '--cleanup=s';
                Expected =
                'scissors', 'strip' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--cleanup=$_" }
            },
            @{
                Line     = '--untracked-files ';
                Expected = 
                'all', 'no', 'normal' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--untracked-files n';
                Expected = 
                'no', 'normal' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--untracked-files=';
                Expected =
                'all', 'no', 'normal' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--untracked-files=$_" }
            },
            @{
                Line     = '--untracked-files=n';
                Expected =
                'no', 'normal' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--untracked-files=$_" }
            },
            @{
                Line     = '--trailer ';
                Expected = 
                'sigob', 'helpb' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--trailer s';
                Expected = 
                'sigob' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--trailer=';
                Expected =
                'sigob', 'helpb' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--trailer=$_" }
            },
            @{
                Line     = '--trailer=s';
                Expected =
                'sigob' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--trailer=$_" }
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
            },
            @{
                Line     = '-- ';
                Expected = @{
                    CompletionText = "Aquarion`` Evol/Evol";
                    ListItemText   = "Aquarion Evol/Evol"
                },
                'Dr.Wily', 'Pwsh/OptionLike/-foo.ps1' | ConvertTo-Completion -ResultType ProviderItem
            },
            @{
                Line     = '-- D';
                Expected = 'Dr.Wily' | ConvertTo-Completion -ResultType ProviderItem
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'InitialCommit' {
            BeforeAll {
                mkdir ($initialPath = "$TestDrive/gitRoot/Initial")
                Push-Location $initialPath
                git init --initial-branch=trunk
                New-Item "$TestDrive/gitRoot/Initial/Evol" -ItemType File
                New-Item "$TestDrive/gitRoot/Initial/Ancient" -ItemType Directory
                New-Item "$TestDrive/gitRoot/Initial/Ancient/Soler" -ItemType File
                New-Item "$TestDrive/gitRoot/Initial/Gepard" -ItemType File
                New-Item "$TestDrive/gitRoot/Initial/Gepada" -ItemType File

                git add Evol Ancient
            }

            AfterAll {
                Pop-Location
            }

            It '<Line>' -ForEach @(
                @{
                    Line     = ' ';
                    Expected = 
                    'Ancient/Soler',
                    'Evol' | ConvertTo-Completion -ResultType ProviderItem
                },
                @{
                    Line     = 'E';
                    Expected = 'Evol' | ConvertTo-Completion -ResultType ProviderItem
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}