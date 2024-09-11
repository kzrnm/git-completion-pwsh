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

    It 'ShortOptions' {
        $expected = @{
            ListItemText = '-h';
            ToolTip      = "show help";
        } | ConvertTo-Completion -ResultType ParameterName
        "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'Subcommands' {
        It '<Line>' -ForEach @(
            @{
                Line     = '';
                Expected = @{
                    ListItemText = 'list';
                    ToolTip      = "list the notes object";
                },
                @{
                    ListItemText = 'add';
                    ToolTip      = "add notes";
                },
                @{
                    ListItemText = 'copy';
                    ToolTip      = "copy the notes for the first object onto the second object ";
                },
                @{
                    ListItemText = 'append';
                    ToolTip      = "append new message(s) ";
                },
                @{
                    ListItemText = 'edit';
                    ToolTip      = "edit the notes";
                },
                @{
                    ListItemText = 'show';
                    ToolTip      = "show the notes";
                },
                @{
                    ListItemText = 'merge';
                    ToolTip      = "merge the given notes ref into the current notes ref";
                },
                @{
                    ListItemText = 'remove';
                    ToolTip      = "remove the notes";
                },
                @{
                    ListItemText = 'prune';
                    ToolTip      = "remove all notes for non-existing/unreachable objects";
                },
                @{
                    ListItemText = 'get-ref';
                    ToolTip      = "print the current notes ref";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = 'p';
                Expected = @{
                    ListItemText = 'prune';
                    ToolTip      = "remove all notes for non-existing/unreachable objects";
                } | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'RefOption' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--';
                Expected = @{
                    ListItemText = '--ref=';
                    ToolTip      = "use notes from <notes-ref>";
                },
                @{
                    ListItemText = '--no-ref';
                    ToolTip      = "[NO] use notes from <notes-ref>";
                } | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe-Revlist -Ref {
            "git $Command --ref $Line" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe-Revlist -Ref -CompletionPrefix '--ref=' {
            "git $Command --ref=$Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'list' {
        BeforeAll {
            Set-Variable Subcommand 'list'
        }

        Describe-Revlist -Ref {
            "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
    Describe 'add' {
        BeforeAll {
            Set-Variable Subcommand 'add'
        }

        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-c';
                ToolTip      = "reuse and edit specified note object";
            },
            @{
                ListItemText = '-C';
                ToolTip      = "reuse specified note object";
            },
            @{
                ListItemText = '-f';
                ToolTip      = "replace existing notes";
            },
            @{
                ListItemText = '-F';
                ToolTip      = "note contents in a file";
            },
            @{
                ListItemText = '-m';
                ToolTip      = "note contents as a string";
            },
            @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--separator';
                        Right    = ' --';
                        Expected = @{
                            ListItemText = '--separator';
                            ToolTip      = "insert <paragraph-break> between paragraphs";
                        } | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Left     = '--separator';
                        Right    = ' -- --all';
                        Expected = @{
                            ListItemText = '--separator';
                            ToolTip      = "insert <paragraph-break> between paragraphs";
                        } | ConvertTo-Completion -ResultType ParameterName
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
                }
            }

            Describe-Revlist -Ref {
                "git $Command $Subcommand -- $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--message=';
                        ToolTip      = "note contents as a string";
                    },
                    @{
                        ListItemText = '--file=';
                        ToolTip      = "note contents in a file";
                    },
                    @{
                        ListItemText = '--reedit-message=';
                        ToolTip      = "reuse and edit specified note object";
                    },
                    @{
                        ListItemText = '--reuse-message=';
                        ToolTip      = "reuse specified note object";
                    },
                    @{
                        ListItemText = '--allow-empty';
                        ToolTip      = "allow storing empty note";
                    },
                    @{
                        ListItemText = '--separator';
                        ToolTip      = "insert <paragraph-break> between paragraphs";
                    },
                    @{
                        ListItemText = '--stripspace';
                        ToolTip      = "remove unnecessary whitespace";
                    },
                    @{
                        ListItemText = '--no-allow-empty';
                        ToolTip      = "[NO] allow storing empty note";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--re';
                    Expected = @{
                        ListItemText = '--reedit-message=';
                        ToolTip      = "reuse and edit specified note object";
                    },
                    @{
                        ListItemText = '--reuse-message=';
                        ToolTip      = "reuse specified note object";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--s';
                    Expected = @{
                        ListItemText = '--separator';
                        ToolTip      = "insert <paragraph-break> between paragraphs";
                    },
                    @{
                        ListItemText = '--stripspace';
                        ToolTip      = "remove unnecessary whitespace";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-a';
                    Expected = @{
                        ListItemText = '--no-allow-empty';
                        ToolTip      = "[NO] allow storing empty note";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-s';
                    Expected = @{
                        ListItemText = '--no-separator';
                        ToolTip      = "[NO] insert <paragraph-break> between paragraphs";
                    },
                    @{
                        ListItemText = '--no-stripspace';
                        ToolTip      = "[NO] remove unnecessary whitespace";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-allow-empty';
                        ToolTip      = "[NO] allow storing empty note";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'OptionValue' {
            Describe-Revlist -Ref -CompletionPrefix '--reuse-message=' {
                "git $Command $Subcommand --reuse-message=$Line" | Complete-FromLine | Should -BeCompletion $expected
            }
            Describe-Revlist -Ref -CompletionPrefix '--reedit-message=' {
                "git $Command $Subcommand --reedit-message=$Line" | Complete-FromLine | Should -BeCompletion $expected
            }
            Describe-Revlist -Ref {
                "git $Command $Subcommand --reuse-message $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
            Describe-Revlist -Ref {
                "git $Command $Subcommand --reedit-message $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe-Revlist -Ref {
            "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
    Describe 'copy' {
        BeforeAll {
            Set-Variable Subcommand 'copy'
        }

        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-f';
                ToolTip      = "replace existing notes";
            },
            @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--stdin';
                        Right    = ' --';
                        Expected = @{
                            ListItemText = '--stdin';
                            ToolTip      = "read objects from stdin";
                        } | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Left     = '--stdin';
                        Right    = ' -- --all';
                        Expected = @{
                            ListItemText = '--stdin';
                            ToolTip      = "read objects from stdin";
                        } | ConvertTo-Completion -ResultType ParameterName
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
                }
            }

            Describe-Revlist -Ref {
                "git $Command $Subcommand -- $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--stdin';
                        ToolTip      = "read objects from stdin";
                    },
                    @{
                        ListItemText = '--for-rewrite=';
                        ToolTip      = "load rewriting config for <command> (implies --stdin)";
                    },
                    @{
                        ListItemText = '--no-stdin';
                        ToolTip      = "[NO] read objects from stdin";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--s';
                    Expected = @{
                        ListItemText = '--stdin';
                        ToolTip      = "read objects from stdin";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-';
                    Expected = @{
                        ListItemText = '--no-stdin';
                        ToolTip      = "[NO] read objects from stdin";
                    },
                    @{
                        ListItemText = '--no-for-rewrite';
                        ToolTip      = "[NO] load rewriting config for <command> (implies --stdin)";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-stdin';
                        ToolTip      = "[NO] read objects from stdin";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe-Revlist -Ref {
            "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
    Describe 'append' {
        BeforeAll {
            Set-Variable Subcommand 'append'
        }

        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-c';
                ToolTip      = "reuse and edit specified note object";
            },
            @{
                ListItemText = '-C';
                ToolTip      = "reuse specified note object";
            },
            @{
                ListItemText = '-F';
                ToolTip      = "note contents in a file";
            },
            @{
                ListItemText = '-m';
                ToolTip      = "note contents as a string";
            },
            @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--separator';
                        Right    = ' --';
                        Expected = @{
                            ListItemText = '--separator';
                            ToolTip      = "insert <paragraph-break> between paragraphs";
                        } | ConvertTo-Completion -ResultType ParameterName
                    },
                    @{
                        Left     = '--separator';
                        Right    = ' -- --all';
                        Expected = @{
                            ListItemText = '--separator';
                            ToolTip      = "insert <paragraph-break> between paragraphs";
                        } | ConvertTo-Completion -ResultType ParameterName
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
                }
            }

            Describe-Revlist -Ref {
                "git $Command $Subcommand -- $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--message=';
                        ToolTip      = "note contents as a string";
                    },
                    @{
                        ListItemText = '--file=';
                        ToolTip      = "note contents in a file";
                    },
                    @{
                        ListItemText = '--reedit-message=';
                        ToolTip      = "reuse and edit specified note object";
                    },
                    @{
                        ListItemText = '--reuse-message=';
                        ToolTip      = "reuse specified note object";
                    },
                    @{
                        ListItemText = '--allow-empty';
                        ToolTip      = "allow storing empty note";
                    },
                    @{
                        ListItemText = '--separator';
                        ToolTip      = "insert <paragraph-break> between paragraphs";
                    },
                    @{
                        ListItemText = '--stripspace';
                        ToolTip      = "remove unnecessary whitespace";
                    },
                    @{
                        ListItemText = '--no-allow-empty';
                        ToolTip      = "[NO] allow storing empty note";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--re';
                    Expected = @{
                        ListItemText = '--reedit-message=';
                        ToolTip      = "reuse and edit specified note object";
                    },
                    @{
                        ListItemText = '--reuse-message=';
                        ToolTip      = "reuse specified note object";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--s';
                    Expected = @{
                        ListItemText = '--separator';
                        ToolTip      = "insert <paragraph-break> between paragraphs";
                    },
                    @{
                        ListItemText = '--stripspace';
                        ToolTip      = "remove unnecessary whitespace";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-a';
                    Expected = @{
                        ListItemText = '--no-allow-empty';
                        ToolTip      = "[NO] allow storing empty note";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-s';
                    Expected = @{
                        ListItemText = '--no-separator';
                        ToolTip      = "[NO] insert <paragraph-break> between paragraphs";
                    },
                    @{
                        ListItemText = '--no-stripspace';
                        ToolTip      = "[NO] remove unnecessary whitespace";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-allow-empty';
                        ToolTip      = "[NO] allow storing empty note";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'OptionValue' {
            Describe-Revlist -Ref -CompletionPrefix '--reuse-message=' {
                "git $Command $Subcommand --reuse-message=$Line" | Complete-FromLine | Should -BeCompletion $expected
            }
            Describe-Revlist -Ref -CompletionPrefix '--reedit-message=' {
                "git $Command $Subcommand --reedit-message=$Line" | Complete-FromLine | Should -BeCompletion $expected
            }
            Describe-Revlist -Ref {
                "git $Command $Subcommand --reuse-message $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
            Describe-Revlist -Ref {
                "git $Command $Subcommand --reedit-message $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe-Revlist -Ref {
            "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
    Describe 'edit' {
        BeforeAll {
            Set-Variable Subcommand 'edit'
        }

        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-c';
                ToolTip      = "reuse and edit specified note object";
            },
            @{
                ListItemText = '-C';
                ToolTip      = "reuse specified note object";
            },
            @{
                ListItemText = '-F';
                ToolTip      = "note contents in a file";
            },
            @{
                ListItemText = '-m';
                ToolTip      = "note contents as a string";
            },
            @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--stripspace';
                        Right    = ' --';
                        Expected = '--stripspace' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'remove unnecessary whitespace'
                    },
                    @{
                        Left     = '--stripspace';
                        Right    = ' -- --all';
                        Expected = '--stripspace' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'remove unnecessary whitespace'
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
                }
            }

            Describe-Revlist -Ref {
                "git $Command $Subcommand -- $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--message=';
                        ToolTip      = "note contents as a string";
                    },
                    @{
                        ListItemText = '--file=';
                        ToolTip      = "note contents in a file";
                    },
                    @{
                        ListItemText = '--reedit-message=';
                        ToolTip      = "reuse and edit specified note object";
                    },
                    @{
                        ListItemText = '--reuse-message=';
                        ToolTip      = "reuse specified note object";
                    },
                    @{
                        ListItemText = '--allow-empty';
                        ToolTip      = "allow storing empty note";
                    },
                    @{
                        ListItemText = '--separator';
                        ToolTip      = "insert <paragraph-break> between paragraphs";
                    },
                    @{
                        ListItemText = '--stripspace';
                        ToolTip      = "remove unnecessary whitespace";
                    },
                    @{
                        ListItemText = '--no-allow-empty';
                        ToolTip      = "[NO] allow storing empty note";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--s';
                    Expected = @{
                        ListItemText = '--separator';
                        ToolTip      = "insert <paragraph-break> between paragraphs";
                    },
                    @{
                        ListItemText = '--stripspace';
                        ToolTip      = "remove unnecessary whitespace";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-s';
                    Expected = @{
                        ListItemText = '--no-separator';
                        ToolTip      = "[NO] insert <paragraph-break> between paragraphs";
                    },
                    @{
                        ListItemText = '--no-stripspace';
                        ToolTip      = "[NO] remove unnecessary whitespace";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-';
                    Expected = @{
                        ListItemText = '--no-allow-empty';
                        ToolTip      = "[NO] allow storing empty note";
                    },
                    @{
                        ListItemText = '--no-separator';
                        ToolTip      = "[NO] insert <paragraph-break> between paragraphs";
                    },
                    @{
                        ListItemText = '--no-stripspace';
                        ToolTip      = "[NO] remove unnecessary whitespace";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-allow-empty';
                        ToolTip      = "[NO] allow storing empty note";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe-Revlist -Ref {
            "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
    Describe 'show' {
        BeforeAll {
            Set-Variable Subcommand 'show'
        }

        Describe-Revlist -Ref {
            "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
    Describe 'merge' {
        BeforeAll {
            Set-Variable Subcommand 'merge'
        }

        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-q';
                ToolTip      = "be more quiet";
            },
            @{
                ListItemText = '-s';
                ToolTip      = "resolve notes conflicts using the given strategy (manual/ours/theirs/union/cat_sort_uniq)";
            },
            @{
                ListItemText = '-v';
                ToolTip      = "be more verbose";
            },
            @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--quiet';
                        Right    = ' --';
                        Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be more quiet'
                    },
                    @{
                        Left     = '--quiet';
                        Right    = ' -- --all';
                        Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be more quiet'
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
                }
            }

            Describe-Revlist -Ref {
                "git $Command $Subcommand -- $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--verbose';
                        ToolTip      = "be more verbose";
                    },
                    @{
                        ListItemText = '--quiet';
                        ToolTip      = "be more quiet";
                    },
                    @{
                        ListItemText = '--strategy=';
                        ToolTip      = "resolve notes conflicts using the given strategy (manual/ours/theirs/union/cat_sort_uniq)";
                    },
                    @{
                        ListItemText = '--commit';
                        ToolTip      = "finalize notes merge by committing unmerged notes";
                    },
                    @{
                        ListItemText = '--abort';
                        ToolTip      = "abort notes merge";
                    },
                    @{
                        ListItemText = '--no-verbose';
                        ToolTip      = "[NO] be more verbose";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--v';
                    Expected = @{
                        ListItemText = '--verbose';
                        ToolTip      = "be more verbose";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--s';
                    Expected = @{
                        ListItemText = '--strategy=';
                        ToolTip      = "resolve notes conflicts using the given strategy (manual/ours/theirs/union/cat_sort_uniq)";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-s';
                    Expected = @{
                        ListItemText = '--no-strategy';
                        ToolTip      = "[NO] resolve notes conflicts using the given strategy (manual/ours/theirs/union/cat_sort_uniq)";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-';
                    Expected = @{
                        ListItemText = '--no-verbose';
                        ToolTip      = "[NO] be more verbose";
                    },
                    @{
                        ListItemText = '--no-quiet';
                        ToolTip      = "[NO] be more quiet";
                    },
                    @{
                        ListItemText = '--no-strategy';
                        ToolTip      = "[NO] resolve notes conflicts using the given strategy (manual/ours/theirs/union/cat_sort_uniq)";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-verbose';
                        ToolTip      = "[NO] be more verbose";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe-Revlist -Ref {
            "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
    Describe 'remove' {
        BeforeAll {
            Set-Variable Subcommand 'remove'
        }

        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--stdin';
                        Right    = ' --';
                        Expected = '--stdin' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'read object names from the standard input'
                    },
                    @{
                        Left     = '--stdin';
                        Right    = ' -- --all';
                        Expected = '--stdin' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'read object names from the standard input'
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
                }
            }

            Describe-Revlist -Ref {
                "git $Command $Subcommand -- $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--ignore-missing';
                        ToolTip      = "attempt to remove non-existent note is not an error";
                    },
                    @{
                        ListItemText = '--stdin';
                        ToolTip      = "read object names from the standard input";
                    },
                    @{
                        ListItemText = '--no-ignore-missing';
                        ToolTip      = "[NO] attempt to remove non-existent note is not an error";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--i';
                    Expected = @{
                        ListItemText = '--ignore-missing';
                        ToolTip      = "attempt to remove non-existent note is not an error";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--s';
                    Expected = @{
                        ListItemText = '--stdin';
                        ToolTip      = "read object names from the standard input";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-s';
                    Expected = @{
                        ListItemText = '--no-stdin';
                        ToolTip      = "[NO] read object names from the standard input";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-';
                    Expected = @{
                        ListItemText = '--no-ignore-missing';
                        ToolTip      = "[NO] attempt to remove non-existent note is not an error";
                    },
                    @{
                        ListItemText = '--no-stdin';
                        ToolTip      = "[NO] read object names from the standard input";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-ignore-missing';
                        ToolTip      = "[NO] attempt to remove non-existent note is not an error";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        Describe-Revlist -Ref {
            "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }
    Describe 'prune' {
        BeforeAll {
            Set-Variable Subcommand 'prune'
        }

        It 'ShortOptions' {
            $Expected = @{
                ListItemText = '-n';
                ToolTip      = "do not remove, show only";
            },
            @{
                ListItemText = '-v';
                ToolTip      = "report pruned notes";
            },
            @{
                ListItemText = '-h';
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $Subcommand -" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe 'DoubleDash' {
            Describe 'InRight' {
                It '<Left>(cursor)<Right>' -ForEach @(
                    @{
                        Left     = '--verbose';
                        Right    = ' --';
                        Expected = '--verbose' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'report pruned notes'
                    },
                    @{
                        Left     = '--verbose';
                        Right    = ' -- --all';
                        Expected = '--verbose' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'report pruned notes'
                    }
                ) {
                    "git $Command $Subcommand $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
                }
            }

            It 'None' {
                "git $Command $Subcommand -- $Line" | Complete-FromLine | Should -BeCompletion @()
            }
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--dry-run';
                        ToolTip      = "do not remove, show only";
                    },
                    @{
                        ListItemText = '--verbose';
                        ToolTip      = "report pruned notes";
                    },
                    @{
                        ListItemText = '--no-dry-run';
                        ToolTip      = "[NO] do not remove, show only";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--v';
                    Expected = @{
                        ListItemText = '--verbose';
                        ToolTip      = "report pruned notes";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-v';
                    Expected = @{
                        ListItemText = '--no-verbose';
                        ToolTip      = "[NO] report pruned notes";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no-';
                    Expected = @{
                        ListItemText = '--no-dry-run';
                        ToolTip      = "[NO] do not remove, show only";
                    },
                    @{
                        ListItemText = '--no-verbose';
                        ToolTip      = "[NO] report pruned notes";
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--no';
                    Expected = @{
                        ListItemText = '--no-dry-run';
                        ToolTip      = "[NO] do not remove, show only";
                    },
                    @{
                        CompletionText = '--no-';
                        ListItemText   = '--no-...';
                        ResultType     = 'Text';
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }

        It 'None' {
            "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion @()
        }
    }
    Describe 'get-ref' {
        BeforeAll {
            Set-Variable Subcommand 'get-ref'
        }

        It 'None' {
            "git $Command $Subcommand $Line" | Complete-FromLine | Should -BeCompletion @()
        }
    }
}