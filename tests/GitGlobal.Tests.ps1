BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.Replace('\', '/').LastIndexOf('tests')))/tests/_TestInitialize.ps1"
}

AfterAll {
    Remove-Module git-completion, _TestModule
}

Describe 'GirGlobal' {
    # BeforeAll {
    #     $script:envHOMEBak = $env:HOME
        
    #     mkdir ($env:HOME = "$TestDrive/home")
    #     mkdir ($rootPath = "$TestDrive/gitRoot")

    #     "[user]
    # email = Kitazato@example.com
    # name = 1000yen" > "$env:HOME/.gitconfig"

    #     Push-Location $rootPath
    #     git init --initial-branch=main
    #     git commit -m "initial" --allow-empty
    #     Pop-Location
    # }

    # AfterAll {
    #     $env:HOME = $script:envHOMEBak
    # }
    It '<line>' -ForEach @(
        @{
            Line     = "--ver";
            Expected = @(
                @{
                    CompletionText = "--version";
                    ListItemText   = "--version";
                    ResultType     = "ParameterName";
                    ToolTip        = "Prints the Git suite version.";
                }
            )
        },
        @{
            Line     = "--attr-sourc";
            Expected = @(
                @{
                    CompletionText = "--attr-source";
                    ListItemText   = "--attr-source <tree-ish>";
                    ResultType     = "ParameterName";
                    ToolTip        = "Read gitattributes from <tree-ish> instead of the worktree.";
                }
            )
        },
        @{
            Line     = "-";
            Expected = @(
                @{
                    CompletionText = "-v";
                    ListItemText   = "-v";
                    ResultType     = "ParameterName";
                    ToolTip        = "Prints the Git suite version.";
                },
                @{
                    CompletionText = "-h";
                    ListItemText   = "-h";
                    ResultType     = "ParameterName";
                    ToolTip        = "Prints the helps. If --all is given then all available commands are printed.";
                }
            )
        },
        @{
            Line     = "--notmatch";
            Expected = @();
        }
    ) {
        "git $line" | Complete-FromLine | Should -BeCompletion $expected
    }
}
