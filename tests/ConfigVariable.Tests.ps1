BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.Replace('\', '/').LastIndexOf('tests')))/tests/_TestInitialize.ps1"
}

AfterAll {
    Remove-Module git-completion, _TestModule
}

Describe 'ConfigVariable' {
    BeforeAll {
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")

        Push-Location $remotePath
        git init --initial-branch=main
        git submodule add https://github.com/github/nagios-plugins-github.git sub
        git submodule add https://github.com/github/nagios-plugins-github.git sum
        git add -A
        git commit -m "initial"
        Pop-Location

        Push-Location $rootPath
        git init --initial-branch=main

        git remote add origin "$remotePath"
        git remote add ordinary "$remotePath"
        git remote add grm "$remotePath"

        git pull origin main
        git fetch ordinary
        git fetch grm

        git branch -c master
        git branch -c develop
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Context 'Value' {
        It '<line>' -ForEach @(
            @{
                Line     = "branch.main.remote=";
                Expected = (
                    @{
                        CompletionText = "branch.main.remote=grm";
                        ListItemText   = "grm";
                        ResultType     = "ParameterValue";
                        ToolTip        = "grm";
                    },
                    @{
                        CompletionText = "branch.main.remote=ordinary";
                        ListItemText   = "ordinary";
                        ResultType     = "ParameterValue";
                        ToolTip        = "ordinary";
                    },
                    @{
                        CompletionText = "branch.main.remote=origin";
                        ListItemText   = "origin";
                        ResultType     = "ParameterValue";
                        ToolTip        = "origin";
                    }
                );
            },
            @{
                Line     = "branch.main.remote=or";
                Expected = (
                    @{
                        CompletionText = "branch.main.remote=ordinary";
                        ListItemText   = "ordinary";
                        ResultType     = "ParameterValue";
                        ToolTip        = "ordinary";
                    },
                    @{
                        CompletionText = "branch.main.remote=origin";
                        ListItemText   = "origin";
                        ResultType     = "ParameterValue";
                        ToolTip        = "origin";
                    }
                );
            },

            @{
                Line     = "branch.main.pushremote=";
                Expected = (
                    @{
                        CompletionText = "branch.main.pushremote=grm";
                        ListItemText   = "grm";
                        ResultType     = "ParameterValue";
                        ToolTip        = "grm";
                    },
                    @{
                        CompletionText = "branch.main.pushremote=ordinary";
                        ListItemText   = "ordinary";
                        ResultType     = "ParameterValue";
                        ToolTip        = "ordinary";
                    },
                    @{
                        CompletionText = "branch.main.pushremote=origin";
                        ListItemText   = "origin";
                        ResultType     = "ParameterValue";
                        ToolTip        = "origin";
                    }
                );
            },
            @{
                Line     = "branch.main.pushremote=or";
                Expected = (
                    @{
                        CompletionText = "branch.main.pushremote=ordinary";
                        ListItemText   = "ordinary";
                        ResultType     = "ParameterValue";
                        ToolTip        = "ordinary";
                    },
                    @{
                        CompletionText = "branch.main.pushremote=origin";
                        ListItemText   = "origin";
                        ResultType     = "ParameterValue";
                        ToolTip        = "origin";
                    }
                );
            },
            @{
                Line     = "branch.main.pushdefault=";
                Expected = (
                    @{
                        CompletionText = "branch.main.pushdefault=grm";
                        ListItemText   = "grm";
                        ResultType     = "ParameterValue";
                        ToolTip        = "grm";
                    },
                    @{
                        CompletionText = "branch.main.pushdefault=ordinary";
                        ListItemText   = "ordinary";
                        ResultType     = "ParameterValue";
                        ToolTip        = "ordinary";
                    },
                    @{
                        CompletionText = "branch.main.pushdefault=origin";
                        ListItemText   = "origin";
                        ResultType     = "ParameterValue";
                        ToolTip        = "origin";
                    }
                );
            },
            @{
                Line     = "branch.main.pushdefault=or";
                Expected = (
                    @{
                        CompletionText = "branch.main.pushdefault=ordinary";
                        ListItemText   = "ordinary";
                        ResultType     = "ParameterValue";
                        ToolTip        = "ordinary";
                    },
                    @{
                        CompletionText = "branch.main.pushdefault=origin";
                        ListItemText   = "origin";
                        ResultType     = "ParameterValue";
                        ToolTip        = "origin";
                    }
                );
            },
            @{
                Line     = "remote.pushdefault=";
                Expected = (
                    @{
                        CompletionText = "remote.pushdefault=grm";
                        ListItemText   = "grm";
                        ResultType     = "ParameterValue";
                        ToolTip        = "grm";
                    },
                    @{
                        CompletionText = "remote.pushdefault=ordinary";
                        ListItemText   = "ordinary";
                        ResultType     = "ParameterValue";
                        ToolTip        = "ordinary";
                    },
                    @{
                        CompletionText = "remote.pushdefault=origin";
                        ListItemText   = "origin";
                        ResultType     = "ParameterValue";
                        ToolTip        = "origin";
                    }
                );
            },
            @{
                Line     = "remote.pushdefault=or";
                Expected = (
                    @{
                        CompletionText = "remote.pushdefault=ordinary";
                        ListItemText   = "ordinary";
                        ResultType     = "ParameterValue";
                        ToolTip        = "ordinary";
                    },
                    @{
                        CompletionText = "remote.pushdefault=origin";
                        ListItemText   = "origin";
                        ResultType     = "ParameterValue";
                        ToolTip        = "origin";
                    }
                );
            },


            @{
                Line     = "branch.main.merge=";
                Expected = (
                    @{
                        CompletionText = "branch.main.merge=HEAD";
                        ListItemText   = "HEAD";
                        ResultType     = "ParameterValue";
                        ToolTip        = "HEAD";
                    },
                    @{
                        CompletionText = "branch.main.merge=FETCH_HEAD";
                        ListItemText   = "FETCH_HEAD";
                        ResultType     = "ParameterValue";
                        ToolTip        = "FETCH_HEAD";
                    },
                    @{
                        CompletionText = "branch.main.merge=develop";
                        ListItemText   = "develop";
                        ResultType     = "ParameterValue";
                        ToolTip        = "develop";
                    },
                    @{
                        CompletionText = "branch.main.merge=main";
                        ListItemText   = "main";
                        ResultType     = "ParameterValue";
                        ToolTip        = "main";
                    },
                    @{
                        CompletionText = "branch.main.merge=master";
                        ListItemText   = "master";
                        ResultType     = "ParameterValue";
                        ToolTip        = "master";
                    },
                    @{
                        CompletionText = "branch.main.merge=grm/main";
                        ListItemText   = "grm/main";
                        ResultType     = "ParameterValue";
                        ToolTip        = "grm/main";
                    },
                    @{
                        CompletionText = "branch.main.merge=ordinary/main";
                        ListItemText   = "ordinary/main";
                        ResultType     = "ParameterValue";
                        ToolTip        = "ordinary/main";
                    },
                    @{
                        CompletionText = "branch.main.merge=origin/main";
                        ListItemText   = "origin/main";
                        ResultType     = "ParameterValue";
                        ToolTip        = "origin/main";
                    }
                );
            },
            @{
                Line     = "branch.main.merge=or";
                Expected = (
                    @{
                        CompletionText = "branch.main.merge=ordinary/main";
                        ListItemText   = "ordinary/main";
                        ResultType     = "ParameterValue";
                        ToolTip        = "ordinary/main";
                    },
                    @{
                        CompletionText = "branch.main.merge=origin/main";
                        ListItemText   = "origin/main";
                        ResultType     = "ParameterValue";
                        ToolTip        = "origin/main";
                    }
                );
            },
            @{
                Line     = "branch.main.rebase=";
                Expected = (
                    @{
                        CompletionText = "branch.main.rebase=false";
                        ListItemText   = "false";
                        ResultType     = "ParameterValue";
                        ToolTip        = "false";
                    },
                    @{
                        CompletionText = "branch.main.rebase=true";
                        ListItemText   = "true";
                        ResultType     = "ParameterValue";
                        ToolTip        = "true";
                    },
                    @{
                        CompletionText = "branch.main.rebase=merges";
                        ListItemText   = "merges";
                        ResultType     = "ParameterValue";
                        ToolTip        = "merges";
                    },
                    @{
                        CompletionText = "branch.main.rebase=interactive";
                        ListItemText   = "interactive";
                        ResultType     = "ParameterValue";
                        ToolTip        = "interactive";
                    }
                );
            },
            @{
                Line     = "branch.main.rebase=t";
                Expected = (
                    @{
                        CompletionText = "branch.main.rebase=true";
                        ListItemText   = "true";
                        ResultType     = "ParameterValue";
                        ToolTip        = "true";
                    }
                );
            },
            @{
                Line     = "remote.origin.fetch=";
                Expected = (
                    @{
                        CompletionText = "remote.origin.fetch=refs/heads";
                        ListItemText   = "refs/heads";
                        ResultType     = "ParameterValue";
                        ToolTip        = "refs/heads";
                    }
                );
            },
            @{
                Line     = "remote.origin.fetch=r";
                Expected = (
                    @{
                        CompletionText = "remote.origin.fetch=refs/heads/main:refs/remotes/origin/main";
                        ListItemText   = "refs/heads/main:refs/remotes/origin/main";
                        ResultType     = "ParameterValue";
                        ToolTip        = "refs/heads/main:refs/remotes/origin/main";
                    }
                );
            },
            @{
                Line     = "pull.twohead=";
                Expected = (
                    @{
                        CompletionText = "pull.twohead=octopus";
                        ListItemText   = "octopus";
                        ResultType     = "ParameterValue";
                        ToolTip        = "octopus";
                    },
                    @{
                        CompletionText = "pull.twohead=ours";
                        ListItemText   = "ours";
                        ResultType     = "ParameterValue";
                        ToolTip        = "ours";
                    },
                    @{
                        CompletionText = "pull.twohead=recursive";
                        ListItemText   = "recursive";
                        ResultType     = "ParameterValue";
                        ToolTip        = "recursive";
                    },
                    @{
                        CompletionText = "pull.twohead=resolve";
                        ListItemText   = "resolve";
                        ResultType     = "ParameterValue";
                        ToolTip        = "resolve";
                    },
                    @{
                        CompletionText = "pull.twohead=subtree";
                        ListItemText   = "subtree";
                        ResultType     = "ParameterValue";
                        ToolTip        = "subtree";
                    }
                );
            },
            @{
                Line     = "pull.twohead=r";
                Expected = (
                    @{
                        CompletionText = "pull.twohead=recursive";
                        ListItemText   = "recursive";
                        ResultType     = "ParameterValue";
                        ToolTip        = "recursive";
                    },
                    @{
                        CompletionText = "pull.twohead=resolve";
                        ListItemText   = "resolve";
                        ResultType     = "ParameterValue";
                        ToolTip        = "resolve";
                    }
                );
            },
            @{
                Line     = "pull.octopus=";
                Expected = (
                    @{
                        CompletionText = "pull.octopus=octopus";
                        ListItemText   = "octopus";
                        ResultType     = "ParameterValue";
                        ToolTip        = "octopus";
                    },
                    @{
                        CompletionText = "pull.octopus=ours";
                        ListItemText   = "ours";
                        ResultType     = "ParameterValue";
                        ToolTip        = "ours";
                    },
                    @{
                        CompletionText = "pull.octopus=recursive";
                        ListItemText   = "recursive";
                        ResultType     = "ParameterValue";
                        ToolTip        = "recursive";
                    },
                    @{
                        CompletionText = "pull.octopus=resolve";
                        ListItemText   = "resolve";
                        ResultType     = "ParameterValue";
                        ToolTip        = "resolve";
                    },
                    @{
                        CompletionText = "pull.octopus=subtree";
                        ListItemText   = "subtree";
                        ResultType     = "ParameterValue";
                        ToolTip        = "subtree";
                    }
                );
            },
            @{
                Line     = "pull.octopus=r";
                Expected = (
                    @{
                        CompletionText = "pull.octopus=recursive";
                        ListItemText   = "recursive";
                        ResultType     = "ParameterValue";
                        ToolTip        = "recursive";
                    },
                    @{
                        CompletionText = "pull.octopus=resolve";
                        ListItemText   = "resolve";
                        ResultType     = "ParameterValue";
                        ToolTip        = "resolve";
                    }
                );
            },

            @{
                Line     = "color.pager=";
                Expected = (
                    @{
                        CompletionText = "color.pager=false";
                        ListItemText   = "false";
                        ResultType     = "ParameterValue";
                        ToolTip        = "false";
                    },
                    @{
                        CompletionText = "color.pager=true";
                        ListItemText   = "true";
                        ResultType     = "ParameterValue";
                        ToolTip        = "true";
                    }
                );
            },
            @{
                Line     = "color.pager=t";
                Expected = (
                    @{
                        CompletionText = "color.pager=true";
                        ListItemText   = "true";
                        ResultType     = "ParameterValue";
                        ToolTip        = "true";
                    }
                );
            },
            @{
                Line     = "color.diff.old=";
                Expected = (
                    @{
                        CompletionText = "color.diff.old=normal";
                        ListItemText   = "normal";
                        ResultType     = "ParameterValue";
                        ToolTip        = "normal";
                    },
                    @{
                        CompletionText = "color.diff.old=black";
                        ListItemText   = "black";
                        ResultType     = "ParameterValue";
                        ToolTip        = "black";
                    },
                    @{
                        CompletionText = "color.diff.old=red";
                        ListItemText   = "red";
                        ResultType     = "ParameterValue";
                        ToolTip        = "red";
                    },
                    @{
                        CompletionText = "color.diff.old=green";
                        ListItemText   = "green";
                        ResultType     = "ParameterValue";
                        ToolTip        = "green";
                    },
                    @{
                        CompletionText = "color.diff.old=yellow";
                        ListItemText   = "yellow";
                        ResultType     = "ParameterValue";
                        ToolTip        = "yellow";
                    },
                    @{
                        CompletionText = "color.diff.old=blue";
                        ListItemText   = "blue";
                        ResultType     = "ParameterValue";
                        ToolTip        = "blue";
                    },
                    @{
                        CompletionText = "color.diff.old=magenta";
                        ListItemText   = "magenta";
                        ResultType     = "ParameterValue";
                        ToolTip        = "magenta";
                    },
                    @{
                        CompletionText = "color.diff.old=cyan";
                        ListItemText   = "cyan";
                        ResultType     = "ParameterValue";
                        ToolTip        = "cyan";
                    },
                    @{
                        CompletionText = "color.diff.old=white";
                        ListItemText   = "white";
                        ResultType     = "ParameterValue";
                        ToolTip        = "white";
                    },
                    @{
                        CompletionText = "color.diff.old=bold";
                        ListItemText   = "bold";
                        ResultType     = "ParameterValue";
                        ToolTip        = "bold";
                    },
                    @{
                        CompletionText = "color.diff.old=dim";
                        ListItemText   = "dim";
                        ResultType     = "ParameterValue";
                        ToolTip        = "dim";
                    },
                    @{
                        CompletionText = "color.diff.old=ul";
                        ListItemText   = "ul";
                        ResultType     = "ParameterValue";
                        ToolTip        = "ul";
                    },
                    @{
                        CompletionText = "color.diff.old=blink";
                        ListItemText   = "blink";
                        ResultType     = "ParameterValue";
                        ToolTip        = "blink";
                    },
                    @{
                        CompletionText = "color.diff.old=reverse";
                        ListItemText   = "reverse";
                        ResultType     = "ParameterValue";
                        ToolTip        = "reverse";
                    }
                );
            },
            @{
                Line     = "color.diff.old=r";
                Expected = (
                    @{
                        CompletionText = "color.diff.old=red";
                        ListItemText   = "red";
                        ResultType     = "ParameterValue";
                        ToolTip        = "red";
                    },
                    @{
                        CompletionText = "color.diff.old=reverse";
                        ListItemText   = "reverse";
                        ResultType     = "ParameterValue";
                        ToolTip        = "reverse";
                    }
                );
            },
            @{
                Line     = "color.remote.hint=";
                Expected = (
                    @{
                        CompletionText = "color.remote.hint=normal";
                        ListItemText   = "normal";
                        ResultType     = "ParameterValue";
                        ToolTip        = "normal";
                    },
                    @{
                        CompletionText = "color.remote.hint=black";
                        ListItemText   = "black";
                        ResultType     = "ParameterValue";
                        ToolTip        = "black";
                    },
                    @{
                        CompletionText = "color.remote.hint=red";
                        ListItemText   = "red";
                        ResultType     = "ParameterValue";
                        ToolTip        = "red";
                    },
                    @{
                        CompletionText = "color.remote.hint=green";
                        ListItemText   = "green";
                        ResultType     = "ParameterValue";
                        ToolTip        = "green";
                    },
                    @{
                        CompletionText = "color.remote.hint=yellow";
                        ListItemText   = "yellow";
                        ResultType     = "ParameterValue";
                        ToolTip        = "yellow";
                    },
                    @{
                        CompletionText = "color.remote.hint=blue";
                        ListItemText   = "blue";
                        ResultType     = "ParameterValue";
                        ToolTip        = "blue";
                    },
                    @{
                        CompletionText = "color.remote.hint=magenta";
                        ListItemText   = "magenta";
                        ResultType     = "ParameterValue";
                        ToolTip        = "magenta";
                    },
                    @{
                        CompletionText = "color.remote.hint=cyan";
                        ListItemText   = "cyan";
                        ResultType     = "ParameterValue";
                        ToolTip        = "cyan";
                    },
                    @{
                        CompletionText = "color.remote.hint=white";
                        ListItemText   = "white";
                        ResultType     = "ParameterValue";
                        ToolTip        = "white";
                    },
                    @{
                        CompletionText = "color.remote.hint=bold";
                        ListItemText   = "bold";
                        ResultType     = "ParameterValue";
                        ToolTip        = "bold";
                    },
                    @{
                        CompletionText = "color.remote.hint=dim";
                        ListItemText   = "dim";
                        ResultType     = "ParameterValue";
                        ToolTip        = "dim";
                    },
                    @{
                        CompletionText = "color.remote.hint=ul";
                        ListItemText   = "ul";
                        ResultType     = "ParameterValue";
                        ToolTip        = "ul";
                    },
                    @{
                        CompletionText = "color.remote.hint=blink";
                        ListItemText   = "blink";
                        ResultType     = "ParameterValue";
                        ToolTip        = "blink";
                    },
                    @{
                        CompletionText = "color.remote.hint=reverse";
                        ListItemText   = "reverse";
                        ResultType     = "ParameterValue";
                        ToolTip        = "reverse";
                    }
                );
            },
            @{
                Line     = "color.remote.hint=r";
                Expected = (
                    @{
                        CompletionText = "color.remote.hint=red";
                        ListItemText   = "red";
                        ResultType     = "ParameterValue";
                        ToolTip        = "red";
                    },
                    @{
                        CompletionText = "color.remote.hint=reverse";
                        ListItemText   = "reverse";
                        ResultType     = "ParameterValue";
                        ToolTip        = "reverse";
                    }
                );
            },
            @{
                Line     = "color.advice=";
                Expected = (
                    @{
                        CompletionText = "color.advice=false";
                        ListItemText   = "false";
                        ResultType     = "ParameterValue";
                        ToolTip        = "false";
                    },
                    @{
                        CompletionText = "color.advice=true";
                        ListItemText   = "true";
                        ResultType     = "ParameterValue";
                        ToolTip        = "true";
                    },
                    @{
                        CompletionText = "color.advice=always";
                        ListItemText   = "always";
                        ResultType     = "ParameterValue";
                        ToolTip        = "always";
                    },
                    @{
                        CompletionText = "color.advice=never";
                        ListItemText   = "never";
                        ResultType     = "ParameterValue";
                        ToolTip        = "never";
                    },
                    @{
                        CompletionText = "color.advice=auto";
                        ListItemText   = "auto";
                        ResultType     = "ParameterValue";
                        ToolTip        = "auto";
                    }
                );
            },
            @{
                Line     = "color.advice=a";
                Expected = (
                    @{
                        CompletionText = "color.advice=always";
                        ListItemText   = "always";
                        ResultType     = "ParameterValue";
                        ToolTip        = "always";
                    },
                    @{
                        CompletionText = "color.advice=auto";
                        ListItemText   = "auto";
                        ResultType     = "ParameterValue";
                        ToolTip        = "auto";
                    }
                );
            },

            @{
                Line     = "color.push=";
                Expected = (
                    @{
                        CompletionText = "color.push=false";
                        ListItemText   = "false";
                        ResultType     = "ParameterValue";
                        ToolTip        = "false";
                    },
                    @{
                        CompletionText = "color.push=true";
                        ListItemText   = "true";
                        ResultType     = "ParameterValue";
                        ToolTip        = "true";
                    },
                    @{
                        CompletionText = "color.push=always";
                        ListItemText   = "always";
                        ResultType     = "ParameterValue";
                        ToolTip        = "always";
                    },
                    @{
                        CompletionText = "color.push=never";
                        ListItemText   = "never";
                        ResultType     = "ParameterValue";
                        ToolTip        = "never";
                    },
                    @{
                        CompletionText = "color.push=auto";
                        ListItemText   = "auto";
                        ResultType     = "ParameterValue";
                        ToolTip        = "auto";
                    }
                );
            },
            @{
                Line     = "color.push=a";
                Expected = (
                    @{
                        CompletionText = "color.push=always";
                        ListItemText   = "always";
                        ResultType     = "ParameterValue";
                        ToolTip        = "always";
                    },
                    @{
                        CompletionText = "color.push=auto";
                        ListItemText   = "auto";
                        ResultType     = "ParameterValue";
                        ToolTip        = "auto";
                    }
                );
            },

            @{
                Line     = "diff.submodule=";
                Expected = (
                    @{
                        CompletionText = "diff.submodule=diff";
                        ListItemText   = "diff";
                        ResultType     = "ParameterValue";
                        ToolTip        = "diff";
                    },
                    @{
                        CompletionText = "diff.submodule=log";
                        ListItemText   = "log";
                        ResultType     = "ParameterValue";
                        ToolTip        = "log";
                    },
                    @{
                        CompletionText = "diff.submodule=short";
                        ListItemText   = "short";
                        ResultType     = "ParameterValue";
                        ToolTip        = "short";
                    }
                );
            },
            @{
                Line     = "diff.submodule=d";
                Expected = (
                    @{
                        CompletionText = "diff.submodule=diff";
                        ListItemText   = "diff";
                        ResultType     = "ParameterValue";
                        ToolTip        = "diff";
                    }
                );
            },
            @{
                Line     = "help.format=";
                Expected = (
                    @{
                        CompletionText = "help.format=man";
                        ListItemText   = "man";
                        ResultType     = "ParameterValue";
                        ToolTip        = "man";
                    },
                    @{
                        CompletionText = "help.format=info";
                        ListItemText   = "info";
                        ResultType     = "ParameterValue";
                        ToolTip        = "info";
                    },
                    @{
                        CompletionText = "help.format=web";
                        ListItemText   = "web";
                        ResultType     = "ParameterValue";
                        ToolTip        = "web";
                    },
                    @{
                        CompletionText = "help.format=html";
                        ListItemText   = "html";
                        ResultType     = "ParameterValue";
                        ToolTip        = "html";
                    }
                );
            },
            @{
                Line     = "help.format=m";
                Expected = (
                    @{
                        CompletionText = "help.format=man";
                        ListItemText   = "man";
                        ResultType     = "ParameterValue";
                        ToolTip        = "man";
                    }
                );
            },
            @{
                Line     = "log.date=";
                Expected = (
                    @{
                        CompletionText = "log.date=relative";
                        ListItemText   = "relative";
                        ResultType     = "ParameterValue";
                        ToolTip        = "relative";
                    },
                    @{
                        CompletionText = "log.date=iso8601";
                        ListItemText   = "iso8601";
                        ResultType     = "ParameterValue";
                        ToolTip        = "iso8601";
                    },
                    @{
                        CompletionText = "log.date=iso8601-strict";
                        ListItemText   = "iso8601-strict";
                        ResultType     = "ParameterValue";
                        ToolTip        = "iso8601-strict";
                    },
                    @{
                        CompletionText = "log.date=rfc2822";
                        ListItemText   = "rfc2822";
                        ResultType     = "ParameterValue";
                        ToolTip        = "rfc2822";
                    },
                    @{
                        CompletionText = "log.date=short";
                        ListItemText   = "short";
                        ResultType     = "ParameterValue";
                        ToolTip        = "short";
                    },
                    @{
                        CompletionText = "log.date=local";
                        ListItemText   = "local";
                        ResultType     = "ParameterValue";
                        ToolTip        = "local";
                    },
                    @{
                        CompletionText = "log.date=default";
                        ListItemText   = "default";
                        ResultType     = "ParameterValue";
                        ToolTip        = "default";
                    },
                    @{
                        CompletionText = "log.date=human";
                        ListItemText   = "human";
                        ResultType     = "ParameterValue";
                        ToolTip        = "human";
                    },
                    @{
                        CompletionText = "log.date=raw";
                        ListItemText   = "raw";
                        ResultType     = "ParameterValue";
                        ToolTip        = "raw";
                    },
                    @{
                        CompletionText = "log.date=unix";
                        ListItemText   = "unix";
                        ResultType     = "ParameterValue";
                        ToolTip        = "unix";
                    },
                    @{
                        CompletionText = "log.date=auto:";
                        ListItemText   = "auto:";
                        ResultType     = "ParameterValue";
                        ToolTip        = "auto:";
                    },
                    @{
                        CompletionText = "log.date=format:";
                        ListItemText   = "format:";
                        ResultType     = "ParameterValue";
                        ToolTip        = "format:";
                    }
                );
            },
            @{
                Line     = "log.date=i";
                Expected = (
                    @{
                        CompletionText = "log.date=iso8601";
                        ListItemText   = "iso8601";
                        ResultType     = "ParameterValue";
                        ToolTip        = "iso8601";
                    },
                    @{
                        CompletionText = "log.date=iso8601-strict";
                        ListItemText   = "iso8601-strict";
                        ResultType     = "ParameterValue";
                        ToolTip        = "iso8601-strict";
                    }
                );
            },
            @{
                Line     = "sendemail.aliasfiletype=";
                Expected = (
                    @{
                        CompletionText = "sendemail.aliasfiletype=mutt";
                        ListItemText   = "mutt";
                        ResultType     = "ParameterValue";
                        ToolTip        = "mutt";
                    },
                    @{
                        CompletionText = "sendemail.aliasfiletype=mailrc";
                        ListItemText   = "mailrc";
                        ResultType     = "ParameterValue";
                        ToolTip        = "mailrc";
                    },
                    @{
                        CompletionText = "sendemail.aliasfiletype=pine";
                        ListItemText   = "pine";
                        ResultType     = "ParameterValue";
                        ToolTip        = "pine";
                    },
                    @{
                        CompletionText = "sendemail.aliasfiletype=elm";
                        ListItemText   = "elm";
                        ResultType     = "ParameterValue";
                        ToolTip        = "elm";
                    },
                    @{
                        CompletionText = "sendemail.aliasfiletype=gnus";
                        ListItemText   = "gnus";
                        ResultType     = "ParameterValue";
                        ToolTip        = "gnus";
                    }
                );
            },
            @{
                Line     = "sendemail.aliasfiletype=m";
                Expected = (
                    @{
                        CompletionText = "sendemail.aliasfiletype=mutt";
                        ListItemText   = "mutt";
                        ResultType     = "ParameterValue";
                        ToolTip        = "mutt";
                    },
                    @{
                        CompletionText = "sendemail.aliasfiletype=mailrc";
                        ListItemText   = "mailrc";
                        ResultType     = "ParameterValue";
                        ToolTip        = "mailrc";
                    }
                );
            },
            @{
                Line     = "sendemail.confirm=";
                Expected = (
                    @{
                        CompletionText = "sendemail.confirm=always";
                        ListItemText   = "always";
                        ResultType     = "ParameterValue";
                        ToolTip        = "always";
                    },
                    @{
                        CompletionText = "sendemail.confirm=never";
                        ListItemText   = "never";
                        ResultType     = "ParameterValue";
                        ToolTip        = "never";
                    },
                    @{
                        CompletionText = "sendemail.confirm=auto";
                        ListItemText   = "auto";
                        ResultType     = "ParameterValue";
                        ToolTip        = "auto";
                    },
                    @{
                        CompletionText = "sendemail.confirm=cc";
                        ListItemText   = "cc";
                        ResultType     = "ParameterValue";
                        ToolTip        = "cc";
                    },
                    @{
                        CompletionText = "sendemail.confirm=compose";
                        ListItemText   = "compose";
                        ResultType     = "ParameterValue";
                        ToolTip        = "compose";
                    }
                );
            },
            @{
                Line     = "sendemail.confirm=a";
                Expected = (
                    @{
                        CompletionText = "sendemail.confirm=always";
                        ListItemText   = "always";
                        ResultType     = "ParameterValue";
                        ToolTip        = "always";
                    },
                    @{
                        CompletionText = "sendemail.confirm=auto";
                        ListItemText   = "auto";
                        ResultType     = "ParameterValue";
                        ToolTip        = "auto";
                    }
                );
            },
            @{
                Line     = "sendemail.suppresscc=";
                Expected = (@{
                        CompletionText = "sendemail.suppresscc=author";
                        ListItemText   = "author";
                        ResultType     = "ParameterValue";
                        ToolTip        = "author";
                    },
                    @{
                        CompletionText = "sendemail.suppresscc=self";
                        ListItemText   = "self";
                        ResultType     = "ParameterValue";
                        ToolTip        = "self";
                    },
                    @{
                        CompletionText = "sendemail.suppresscc=cc";
                        ListItemText   = "cc";
                        ResultType     = "ParameterValue";
                        ToolTip        = "cc";
                    },
                    @{
                        CompletionText = "sendemail.suppresscc=bodycc";
                        ListItemText   = "bodycc";
                        ResultType     = "ParameterValue";
                        ToolTip        = "bodycc";
                    },
                    @{
                        CompletionText = "sendemail.suppresscc=sob";
                        ListItemText   = "sob";
                        ResultType     = "ParameterValue";
                        ToolTip        = "sob";
                    },
                    @{
                        CompletionText = "sendemail.suppresscc=cccmd";
                        ListItemText   = "cccmd";
                        ResultType     = "ParameterValue";
                        ToolTip        = "cccmd";
                    },
                    @{
                        CompletionText = "sendemail.suppresscc=body";
                        ListItemText   = "body";
                        ResultType     = "ParameterValue";
                        ToolTip        = "body";
                    },
                    @{
                        CompletionText = "sendemail.suppresscc=all";
                        ListItemText   = "all";
                        ResultType     = "ParameterValue";
                        ToolTip        = "all";
                    }
                );
            },
            @{
                Line     = "sendemail.suppresscc=a";
                Expected = (@{
                        CompletionText = "sendemail.suppresscc=author";
                        ListItemText   = "author";
                        ResultType     = "ParameterValue";
                        ToolTip        = "author";
                    },
                    @{
                        CompletionText = "sendemail.suppresscc=all";
                        ListItemText   = "all";
                        ResultType     = "ParameterValue";
                        ToolTip        = "all";
                    }
                );
            },
            @{
                Line     = "sendemail.transferencoding=";
                Expected = (
                    @{
                        CompletionText = "sendemail.transferencoding=7bit";
                        ListItemText   = "7bit";
                        ResultType     = "ParameterValue";
                        ToolTip        = "7bit";
                    },
                    @{
                        CompletionText = "sendemail.transferencoding=8bit";
                        ListItemText   = "8bit";
                        ResultType     = "ParameterValue";
                        ToolTip        = "8bit";
                    },
                    @{
                        CompletionText = "sendemail.transferencoding=quoted-printable";
                        ListItemText   = "quoted-printable";
                        ResultType     = "ParameterValue";
                        ToolTip        = "quoted-printable";
                    },
                    @{
                        CompletionText = "sendemail.transferencoding=base64";
                        ListItemText   = "base64";
                        ResultType     = "ParameterValue";
                        ToolTip        = "base64";
                    }
                );
            },
            @{
                Line     = "sendemail.transferencoding=7";
                Expected = (
                    @{
                        CompletionText = "sendemail.transferencoding=7bit";
                        ListItemText   = "7bit";
                        ResultType     = "ParameterValue";
                        ToolTip        = "7bit";
                    }
                );
            },
            @{
                Line     = "branch.main.notmatch=";
                Expected = @();
            }
        ) {
            "git -c $line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Context 'Name' {
        It '<line>' -ForEach @(
            @{
                Line     = "branch.main.";
                Expected = (
                    @{
                        CompletionText = "branch.main.description=";
                        ListItemText   = "branch.main.description";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.main.description";
                    },
                    @{
                        CompletionText = "branch.main.merge=";
                        ListItemText   = "branch.main.merge";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.main.merge";
                    },
                    @{
                        CompletionText = "branch.main.mergeOptions=";
                        ListItemText   = "branch.main.mergeOptions";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.main.mergeOptions";
                    },
                    @{
                        CompletionText = "branch.main.pushRemote=";
                        ListItemText   = "branch.main.pushRemote";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.main.pushRemote";
                    },
                    @{
                        CompletionText = "branch.main.rebase=";
                        ListItemText   = "branch.main.rebase";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.main.rebase";
                    },
                    @{
                        CompletionText = "branch.main.remote=";
                        ListItemText   = "branch.main.remote";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.main.remote";
                    }
                );
            },
            @{
                Line     = "branch.main.r";
                Expected = (
                    @{
                        CompletionText = "branch.main.rebase=";
                        ListItemText   = "branch.main.rebase";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.main.rebase";
                    },
                    @{
                        CompletionText = "branch.main.remote=";
                        ListItemText   = "branch.main.remote";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.main.remote";
                    }
                );
            },
            @{
                Line     = "guitool.pwsh.";
                Expected = (
                    @{
                        CompletionText = "guitool.pwsh.argPrompt=";
                        ListItemText   = "guitool.pwsh.argPrompt";
                        ResultType     = "ParameterName";
                        ToolTip        = "guitool.pwsh.argPrompt";
                    },
                    @{
                        CompletionText = "guitool.pwsh.cmd=";
                        ListItemText   = "guitool.pwsh.cmd";
                        ResultType     = "ParameterName";
                        ToolTip        = "guitool.pwsh.cmd";
                    },
                    @{
                        CompletionText = "guitool.pwsh.confirm=";
                        ListItemText   = "guitool.pwsh.confirm";
                        ResultType     = "ParameterName";
                        ToolTip        = "guitool.pwsh.confirm";
                    },
                    @{
                        CompletionText = "guitool.pwsh.needsFile=";
                        ListItemText   = "guitool.pwsh.needsFile";
                        ResultType     = "ParameterName";
                        ToolTip        = "guitool.pwsh.needsFile";
                    },
                    @{
                        CompletionText = "guitool.pwsh.noConsole=";
                        ListItemText   = "guitool.pwsh.noConsole";
                        ResultType     = "ParameterName";
                        ToolTip        = "guitool.pwsh.noConsole";
                    },
                    @{
                        CompletionText = "guitool.pwsh.noRescan=";
                        ListItemText   = "guitool.pwsh.noRescan";
                        ResultType     = "ParameterName";
                        ToolTip        = "guitool.pwsh.noRescan";
                    },
                    @{
                        CompletionText = "guitool.pwsh.prompt=";
                        ListItemText   = "guitool.pwsh.prompt";
                        ResultType     = "ParameterName";
                        ToolTip        = "guitool.pwsh.prompt";
                    },
                    @{
                        CompletionText = "guitool.pwsh.revPrompt=";
                        ListItemText   = "guitool.pwsh.revPrompt";
                        ResultType     = "ParameterName";
                        ToolTip        = "guitool.pwsh.revPrompt";
                    },
                    @{
                        CompletionText = "guitool.pwsh.revUnmerged=";
                        ListItemText   = "guitool.pwsh.revUnmerged";
                        ResultType     = "ParameterName";
                        ToolTip        = "guitool.pwsh.revUnmerged";
                    },
                    @{
                        CompletionText = "guitool.pwsh.title=";
                        ListItemText   = "guitool.pwsh.title";
                        ResultType     = "ParameterName";
                        ToolTip        = "guitool.pwsh.title";
                    }
                );
            },
            @{
                Line     = "guitool.pwsh.r";
                Expected = (
                    @{
                        CompletionText = "guitool.pwsh.revPrompt=";
                        ListItemText   = "guitool.pwsh.revPrompt";
                        ResultType     = "ParameterName";
                        ToolTip        = "guitool.pwsh.revPrompt";
                    },
                    @{
                        CompletionText = "guitool.pwsh.revUnmerged=";
                        ListItemText   = "guitool.pwsh.revUnmerged";
                        ResultType     = "ParameterName";
                        ToolTip        = "guitool.pwsh.revUnmerged";
                    }
                );
            },
            @{
                Line     = "difftool.pwsh.";
                Expected = (
                    @{
                        CompletionText = "difftool.pwsh.cmd=";
                        ListItemText   = "difftool.pwsh.cmd";
                        ResultType     = "ParameterName";
                        ToolTip        = "difftool.pwsh.cmd";
                    },
                    @{
                        CompletionText = "difftool.pwsh.path=";
                        ListItemText   = "difftool.pwsh.path";
                        ResultType     = "ParameterName";
                        ToolTip        = "difftool.pwsh.path";
                    }
                );
            },
            @{
                Line     = "difftool.pwsh.c";
                Expected = (
                    @{
                        CompletionText = "difftool.pwsh.cmd=";
                        ListItemText   = "difftool.pwsh.cmd";
                        ResultType     = "ParameterName";
                        ToolTip        = "difftool.pwsh.cmd";
                    }
                );
            },
            @{
                Line     = "man.pwsh.";
                Expected = (
                    @{
                        CompletionText = "man.pwsh.cmd=";
                        ListItemText   = "man.pwsh.cmd";
                        ResultType     = "ParameterName";
                        ToolTip        = "man.pwsh.cmd";
                    },
                    @{
                        CompletionText = "man.pwsh.path=";
                        ListItemText   = "man.pwsh.path";
                        ResultType     = "ParameterName";
                        ToolTip        = "man.pwsh.path";
                    }
                );
            },
            @{
                Line     = "man.pwsh.c";
                Expected = (
                    @{
                        CompletionText = "man.pwsh.cmd=";
                        ListItemText   = "man.pwsh.cmd";
                        ResultType     = "ParameterName";
                        ToolTip        = "man.pwsh.cmd";
                    }
                );
            },
            @{
                Line     = "mergetool.pwsh.";
                Expected = (
                    @{
                        CompletionText = "mergetool.pwsh.cmd=";
                        ListItemText   = "mergetool.pwsh.cmd";
                        ResultType     = "ParameterName";
                        ToolTip        = "mergetool.pwsh.cmd";
                    },
                    @{
                        CompletionText = "mergetool.pwsh.hideResolved=";
                        ListItemText   = "mergetool.pwsh.hideResolved";
                        ResultType     = "ParameterName";
                        ToolTip        = "mergetool.pwsh.hideResolved";
                    },
                    @{
                        CompletionText = "mergetool.pwsh.path=";
                        ListItemText   = "mergetool.pwsh.path";
                        ResultType     = "ParameterName";
                        ToolTip        = "mergetool.pwsh.path";
                    },
                    @{
                        CompletionText = "mergetool.pwsh.trustExitCode=";
                        ListItemText   = "mergetool.pwsh.trustExitCode";
                        ResultType     = "ParameterName";
                        ToolTip        = "mergetool.pwsh.trustExitCode";
                    },
                    @{
                        CompletionText = "mergetool.pwsh.layout=";
                        ListItemText   = "mergetool.pwsh.layout";
                        ResultType     = "ParameterName";
                        ToolTip        = "mergetool.pwsh.layout";
                    },
                    @{
                        CompletionText = "mergetool.pwsh.hasOutput=";
                        ListItemText   = "mergetool.pwsh.hasOutput";
                        ResultType     = "ParameterName";
                        ToolTip        = "mergetool.pwsh.hasOutput";
                    },
                    @{
                        CompletionText = "mergetool.pwsh.useAutoMerge=";
                        ListItemText   = "mergetool.pwsh.useAutoMerge";
                        ResultType     = "ParameterName";
                        ToolTip        = "mergetool.pwsh.useAutoMerge";
                    }
                );
            },
            @{
                Line     = "mergetool.pwsh.c";
                Expected = (
                    @{
                        CompletionText = "mergetool.pwsh.cmd=";
                        ListItemText   = "mergetool.pwsh.cmd";
                        ResultType     = "ParameterName";
                        ToolTip        = "mergetool.pwsh.cmd";
                    }
                );
            },
            @{
                Line     = "remote.pwsh.";
                Expected = (
                    @{
                        CompletionText = "remote.pwsh.fetch=";
                        ListItemText   = "remote.pwsh.fetch";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.fetch";
                    },
                    @{
                        CompletionText = "remote.pwsh.mirror=";
                        ListItemText   = "remote.pwsh.mirror";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.mirror";
                    },
                    @{
                        CompletionText = "remote.pwsh.partialclonefilter=";
                        ListItemText   = "remote.pwsh.partialclonefilter";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.partialclonefilter";
                    },
                    @{
                        CompletionText = "remote.pwsh.promisor=";
                        ListItemText   = "remote.pwsh.promisor";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.promisor";
                    },
                    @{
                        CompletionText = "remote.pwsh.proxy=";
                        ListItemText   = "remote.pwsh.proxy";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.proxy";
                    },
                    @{
                        CompletionText = "remote.pwsh.proxyAuthMethod=";
                        ListItemText   = "remote.pwsh.proxyAuthMethod";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.proxyAuthMethod";
                    },
                    @{
                        CompletionText = "remote.pwsh.prune=";
                        ListItemText   = "remote.pwsh.prune";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.prune";
                    },
                    @{
                        CompletionText = "remote.pwsh.pruneTags=";
                        ListItemText   = "remote.pwsh.pruneTags";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.pruneTags";
                    },
                    @{
                        CompletionText = "remote.pwsh.push=";
                        ListItemText   = "remote.pwsh.push";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.push";
                    },
                    @{
                        CompletionText = "remote.pwsh.pushurl=";
                        ListItemText   = "remote.pwsh.pushurl";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.pushurl";
                    },
                    @{
                        CompletionText = "remote.pwsh.receivepack=";
                        ListItemText   = "remote.pwsh.receivepack";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.receivepack";
                    },
                    @{
                        CompletionText = "remote.pwsh.skipDefaultUpdate=";
                        ListItemText   = "remote.pwsh.skipDefaultUpdate";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.skipDefaultUpdate";
                    },
                    @{
                        CompletionText = "remote.pwsh.skipFetchAll=";
                        ListItemText   = "remote.pwsh.skipFetchAll";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.skipFetchAll";
                    },
                    @{
                        CompletionText = "remote.pwsh.tagOpt=";
                        ListItemText   = "remote.pwsh.tagOpt";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.tagOpt";
                    },
                    @{
                        CompletionText = "remote.pwsh.uploadpack=";
                        ListItemText   = "remote.pwsh.uploadpack";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.uploadpack";
                    },
                    @{
                        CompletionText = "remote.pwsh.url=";
                        ListItemText   = "remote.pwsh.url";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.url";
                    },
                    @{
                        CompletionText = "remote.pwsh.vcs=";
                        ListItemText   = "remote.pwsh.vcs";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.vcs";
                    }
                );
            },
            @{
                Line     = "remote.pwsh.u";
                Expected = (
                    @{
                        CompletionText = "remote.pwsh.uploadpack=";
                        ListItemText   = "remote.pwsh.uploadpack";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.uploadpack";
                    },
                    @{
                        CompletionText = "remote.pwsh.url=";
                        ListItemText   = "remote.pwsh.url";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pwsh.url";
                    }
                );
            },
            @{
                Line     = "submodule.posh.";
                Expected = @(
                    @{
                        CompletionText = "submodule.posh.active=";
                        ListItemText   = "submodule.posh.active";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.posh.active";
                    },
                    @{
                        CompletionText = "submodule.posh.branch=";
                        ListItemText   = "submodule.posh.branch";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.posh.branch";
                    },
                    @{
                        CompletionText = "submodule.posh.fetchRecurseSubmodules=";
                        ListItemText   = "submodule.posh.fetchRecurseSubmodules";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.posh.fetchRecurseSubmodules";
                    },
                    @{
                        CompletionText = "submodule.posh.ignore=";
                        ListItemText   = "submodule.posh.ignore";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.posh.ignore";
                    },
                    @{
                        CompletionText = "submodule.posh.update=";
                        ListItemText   = "submodule.posh.update";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.posh.update";
                    },
                    @{
                        CompletionText = "submodule.posh.url=";
                        ListItemText   = "submodule.posh.url";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.posh.url";
                    }
                )
            },
            @{
                Line     = "submodule.posh.u";
                Expected = @(
                    @{
                        CompletionText = "submodule.posh.update=";
                        ListItemText   = "submodule.posh.update";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.posh.update";
                    },
                    @{
                        CompletionText = "submodule.posh.url=";
                        ListItemText   = "submodule.posh.url";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.posh.url";
                    }
                )
            },
            @{
                Line     = "url.git@github.com:.";
                Expected = @(
                    @{
                        CompletionText = "url.git@github.com:.insteadOf=";
                        ListItemText   = "url.git@github.com:.insteadOf";
                        ResultType     = "ParameterName";
                        ToolTip        = "url.git@github.com:.insteadOf";
                    },
                    @{
                        CompletionText = "url.git@github.com:.pushInsteadOf=";
                        ListItemText   = "url.git@github.com:.pushInsteadOf";
                        ResultType     = "ParameterName";
                        ToolTip        = "url.git@github.com:.pushInsteadOf";
                    }
                )
            },
            @{
                Line     = "url.git@github.com:.i";
                Expected = @(
                    @{
                        CompletionText = "url.git@github.com:.insteadOf=";
                        ListItemText   = "url.git@github.com:.insteadOf";
                        ResultType     = "ParameterName";
                        ToolTip        = "url.git@github.com:.insteadOf";
                    }
                )
            },
            @{
                Line     = "branch.";
                Expected = @(
                    @{
                        CompletionText = "branch.develop.";
                        ListItemText   = "branch.develop.";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.develop.";
                    },
                    @{
                        CompletionText = "branch.main.";
                        ListItemText   = "branch.main.";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.main.";
                    },
                    @{
                        CompletionText = "branch.master.";
                        ListItemText   = "branch.master.";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.master.";
                    },
                    @{
                        CompletionText = "branch.autoSetupMerge=";
                        ListItemText   = "branch.autoSetupMerge";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.autoSetupMerge";
                    },
                    @{
                        CompletionText = "branch.autoSetupRebase=";
                        ListItemText   = "branch.autoSetupRebase";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.autoSetupRebase";
                    },
                    @{
                        CompletionText = "branch.sort=";
                        ListItemText   = "branch.sort";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.sort";
                    }
                )
            },
            @{
                Line     = "branch.m";
                Expected = @(
                    @{
                        CompletionText = "branch.main.";
                        ListItemText   = "branch.main.";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.main.";
                    },
                    @{
                        CompletionText = "branch.master.";
                        ListItemText   = "branch.master.";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.master.";
                    }
                )
            },
            @{
                Line     = "branch.a";
                Expected = @(
                    @{
                        CompletionText = "branch.autoSetupMerge=";
                        ListItemText   = "branch.autoSetupMerge";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.autoSetupMerge";
                    },
                    @{
                        CompletionText = "branch.autoSetupRebase=";
                        ListItemText   = "branch.autoSetupRebase";
                        ResultType     = "ParameterName";
                        ToolTip        = "branch.autoSetupRebase";
                    }
                )
            },
            @{
                Line     = "remote.";
                Expected = @(
                    @{
                        CompletionText = "remote.grm.";
                        ListItemText   = "remote.grm.";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.grm.";
                    },
                    @{
                        CompletionText = "remote.ordinary.";
                        ListItemText   = "remote.ordinary.";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.ordinary.";
                    },
                    @{
                        CompletionText = "remote.origin.";
                        ListItemText   = "remote.origin.";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.origin.";
                    },
                    @{
                        CompletionText = "remote.pushDefault=";
                        ListItemText   = "remote.pushDefault";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pushDefault";
                    }
                )
            },
            @{
                Line     = "remote.o";
                Expected = @(
                    @{
                        CompletionText = "remote.ordinary.";
                        ListItemText   = "remote.ordinary.";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.ordinary.";
                    },
                    @{
                        CompletionText = "remote.origin.";
                        ListItemText   = "remote.origin.";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.origin.";
                    }
                )
            },
            @{
                Line     = "remote.p";
                Expected = @(
                    @{
                        CompletionText = "remote.pushDefault=";
                        ListItemText   = "remote.pushDefault";
                        ResultType     = "ParameterName";
                        ToolTip        = "remote.pushDefault";
                    }
                )
            },
            @{
                Line     = "submodule.";
                Expected = @(
                    @{
                        CompletionText = "submodule.sub.";
                        ListItemText   = "submodule.sub.";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.sub.";
                    },
                    @{
                        CompletionText = "submodule.sum.";
                        ListItemText   = "submodule.sum.";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.sum.";
                    },
                    @{
                        CompletionText = "submodule.active=";
                        ListItemText   = "submodule.active";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.active";
                    },
                    @{
                        CompletionText = "submodule.alternateErrorStrategy=";
                        ListItemText   = "submodule.alternateErrorStrategy";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.alternateErrorStrategy";
                    },
                    @{
                        CompletionText = "submodule.alternateLocation=";
                        ListItemText   = "submodule.alternateLocation";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.alternateLocation";
                    },
                    @{
                        CompletionText = "submodule.fetchJobs=";
                        ListItemText   = "submodule.fetchJobs";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.fetchJobs";
                    },
                    @{
                        CompletionText = "submodule.propagateBranches=";
                        ListItemText   = "submodule.propagateBranches";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.propagateBranches";
                    },
                    @{
                        CompletionText = "submodule.recurse=";
                        ListItemText   = "submodule.recurse";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.recurse";
                    }
                )
            },
            @{
                Line     = "submodule.s";
                Expected = @(
                    @{
                        CompletionText = "submodule.sub.";
                        ListItemText   = "submodule.sub.";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.sub.";
                    },
                    @{
                        CompletionText = "submodule.sum.";
                        ListItemText   = "submodule.sum.";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.sum.";
                    }
                )
            },
            @{
                Line     = "submodule.r";
                Expected = @(
                    @{
                        CompletionText = "submodule.recurse=";
                        ListItemText   = "submodule.recurse";
                        ResultType     = "ParameterName";
                        ToolTip        = "submodule.recurse";
                    }
                )
            },
            @{
                Line     = "tag.";
                Expected = @(
                    @{
                        CompletionText = "tag.forceSignAnnotated=";
                        ListItemText   = "tag.forceSignAnnotated";
                        ResultType     = "ParameterName";
                        ToolTip        = "tag.forceSignAnnotated";
                    },
                    @{
                        CompletionText = "tag.gpgSign=";
                        ListItemText   = "tag.gpgSign";
                        ResultType     = "ParameterName";
                        ToolTip        = "tag.gpgSign";
                    },
                    @{
                        CompletionText = "tag.sort=";
                        ListItemText   = "tag.sort";
                        ResultType     = "ParameterName";
                        ToolTip        = "tag.sort";
                    }
                )
            },
            @{
                Line     = "revert.r";
                Expected = @(
                    @{
                        CompletionText = "revert.reference=";
                        ListItemText   = "revert.reference";
                        ResultType     = "ParameterName";
                        ToolTip        = "revert.reference";
                    }
                )
            },
            @{
                Line     = "pu";
                Expected = @(
                    @{
                        CompletionText = "pull.";
                        ListItemText   = "pull.";
                        ResultType     = "ParameterName";
                        ToolTip        = "pull.";
                    },
                    @{
                        CompletionText = "push.";
                        ListItemText   = "push.";
                        ResultType     = "ParameterName";
                        ToolTip        = "push.";
                    }
                )
            },
            @{
                Line     = "notmatch";
                Expected = @();
            }
        ) {
            "git -c $line" | Complete-FromLine | Should -BeCompletion $expected
        }

        Context "Commands" {
            Context 'WithAlias' {
                BeforeAll {
                    git config alias.pr 'pull origin'
                }
                AfterAll {
                    git config --unset alias.pr
                }

                It '<line>' -ForEach @(
                    @{
                        Line     = "pager.pr";
                        Expected = (
                            @{
                                CompletionText = "pager.pr=";
                                ListItemText   = "pager.pr";
                                ResultType     = "ParameterName";
                                ToolTip        = "pager.pr";
                            },
                            @{
                                CompletionText = "pager.prune=";
                                ListItemText   = "pager.prune";
                                ResultType     = "ParameterName";
                                ToolTip        = "pager.prune";
                            },
                            @{
                                CompletionText = "pager.prune-packed=";
                                ListItemText   = "pager.prune-packed";
                                ResultType     = "ParameterName";
                                ToolTip        = "pager.prune-packed";
                            }
                        )
                    }
                ) {
                    "git -c $line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }

            Context 'WithoutAlias' {
                It '<line>' -ForEach @(
                    @{
                        Line     = "pager.pr";
                        Expected = (
                            @{
                                CompletionText = "pager.prune=";
                                ListItemText   = "pager.prune";
                                ResultType     = "ParameterName";
                                ToolTip        = "pager.prune";
                            },
                            @{
                                CompletionText = "pager.prune-packed=";
                                ListItemText   = "pager.prune-packed";
                                ResultType     = "ParameterName";
                                ToolTip        = "pager.prune-packed";
                            }
                        )
                    }
                ) {
                    "git -c $line" | Complete-FromLine | Should -BeCompletion $expected
                }
            }
        }
    }
}
