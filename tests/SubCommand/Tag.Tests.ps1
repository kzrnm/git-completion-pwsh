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
                    Left     = '--verify';
                    Right    = ' --';
                    Expected = '--verify' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'verify tags'
                },
                @{
                    Left     = '--verify';
                    Right    = ' -- --all';
                    Expected = '--verify' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'verify tags'
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
            ListItemText = '-a';
            ToolTip      = "annotated tag, needs a message";
        },
        @{
            ListItemText = '-d';
            ToolTip      = "delete tags";
        },
        @{
            ListItemText = '-e';
            ToolTip      = "force edit of tag message";
        },
        @{
            ListItemText = '-f';
            ToolTip      = "replace the tag if exists";
        },
        @{
            ListItemText = '-F';
            ToolTip      = "read message from file";
        },
        @{
            ListItemText = '-i';
            ToolTip      = "sorting and filtering are case insensitive";
        },
        @{
            ListItemText = '-l';
            ToolTip      = "list tag names";
        },
        @{
            ListItemText = '-m';
            ToolTip      = "tag message";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "print <n> lines of each tag message";
        },
        @{
            ListItemText = '-s';
            ToolTip      = "annotated and GPG-signed tag";
        },
        @{
            ListItemText = '-u';
            ToolTip      = "use another key to sign the tag";
        },
        @{
            ListItemText = '-v';
            ToolTip      = "verify tags";
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
                },
                @{
                    ListItemText = '--create-reflog';
                    ToolTip      = "create a reflog";
                },
                @{
                    ListItemText = '--column';
                    ToolTip      = "show tag list in columns";
                },
                @{
                    ListItemText = '--contains';
                    ToolTip      = "print only tags that contain the commit";
                },
                @{
                    ListItemText = '--color';
                    ToolTip      = "respect format colors";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--v';
                Expected = '--verify' | ConvertTo-Completion -ResultType ParameterName -ToolTip "verify tags"
            },
            @{
                Line     = '--m';
                Expected = @{
                    ListItemText = '--message=';
                    ToolTip      = "tag message";
                },
                @{
                    ListItemText = '--merged';
                    ToolTip      = "print only tags that are merged";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-c';
                Expected = @{
                    ListItemText = '--no-contains';
                    ToolTip      = "print only tags that don't contain the commit";
                },
                @{
                    ListItemText = '--no-cleanup';
                    ToolTip      = "[NO] how to strip spaces and #comments from message";
                },
                @{
                    ListItemText = '--no-create-reflog';
                    ToolTip      = "[NO] create a reflog";
                },
                @{
                    ListItemText = '--no-column';
                    ToolTip      = "[NO] show tag list in columns";
                },
                @{
                    ListItemText = '--no-color';
                    ToolTip      = "[NO] respect format colors";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-m';
                Expected = @{
                    ListItemText = '--no-merged';
                    ToolTip      = "print only tags that are not merged";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-contains';
                    ToolTip      = "print only tags that don't contain the commit";
                },
                @{
                    ListItemText = '--no-merged';
                    ToolTip      = "print only tags that are not merged";
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

    Describe 'ExistingTags' {
        It '<Line>' -ForEach @(
            @{
                Line     = '-d ';
                Expected = 'initial', 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-d z';
                Expected = 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-d -- ';
                Expected = 'initial', 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-d -- z';
                Expected = 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-d zeta -- ';
                Expected = 'initial' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-d -- zeta ';
                Expected = 'initial' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--delete ';
                Expected = 'initial', 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--delete z';
                Expected = 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--delete -- ';
                Expected = 'initial', 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--delete -- z';
                Expected = 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--delete zeta -- ';
                Expected = 'initial' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--delete -- zeta ';
                Expected = 'initial' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-v ';
                Expected = 'initial', 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-v z';
                Expected = 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-v -- ';
                Expected = 'initial', 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-v -- z';
                Expected = 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-v zeta -- ';
                Expected = 'initial' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-v -- zeta ';
                Expected = 'initial' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--verify ';
                Expected = 'initial', 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--verify z';
                Expected = 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--verify -- ';
                Expected = 'initial', 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--verify -- z';
                Expected = 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--verify zeta -- ';
                Expected = 'initial' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--verify -- zeta ';
                Expected = 'initial' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },

            @{
                Line     = '-f ';
                Expected = 'initial', 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '-f -- z';
                Expected = 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--force ';
                Expected = 'initial', 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--force -- z';
                Expected = 'zeta' | ForEach-Object { $RemoteCommits[$_] } | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $Expected
        }
    }

    Describe 'OptionValue' {
        It '<Line>' -ForEach @(
            @{
                Line     = '-F ';
                Expected = @()
            },
            @{
                Line     = '--file ';
                Expected = @()
            },
            @{
                Line     = '--message ';
                Expected = @()
            },
            @{
                Line     = '-m ';
                Expected = @()
            },
            @{
                Line     = '--column=';
                Expected = @{
                    ListItemText = 'always';
                    Tooltip      = 'always show in columns'; 
                },
                @{
                    ListItemText = 'never';
                    Tooltip      = 'never show in columns'; 
                },
                @{
                    ListItemText = 'auto';
                    Tooltip      = 'show in columns if the output is to the terminal'; 
                },
                @{
                    ListItemText = 'column';
                    Tooltip      = 'fill columns before rows'; 
                },
                @{
                    ListItemText = 'row';
                    Tooltip      = 'fill rows before columns'; 
                },
                @{
                    ListItemText = 'plain';
                    Tooltip      = 'show in one column'; 
                },
                @{
                    ListItemText = 'dense';
                    Tooltip      = 'make unequal size columns to utilize more space'; 
                },
                @{
                    ListItemText = 'nodense';
                    Tooltip      = 'make equal size columns'; 
                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--column=$_" }
            },
            @{
                Line     = '--column=a';
                Expected = @{
                    ListItemText = 'always';
                    Tooltip      = 'always show in columns'; 
                },
                @{
                    ListItemText = 'auto';
                    Tooltip      = 'show in columns if the output is to the terminal'; 
                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--column=$_" }
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $Expected
        }
    }

    Describe 'Refs:<Prefix>' -ForEach @(
        '-f zeta ',
        '-f -- zeta ',
        '--force zeta ',
        '--force zeta -- ',
        'new-tag ',
        'new-tag -- ',
        '-- new-tag ' | ForEach-Object { @{Prefix = $_ } }
    ) {
        Describe-Revlist -Ref {
            "git $Command $Prefix $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
}