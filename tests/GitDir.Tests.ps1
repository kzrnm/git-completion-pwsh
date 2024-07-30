BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.Replace('\', '/').LastIndexOf('tests')))/tests/_TestInitialize.ps1"
}

AfterAll {
    Remove-Module git-completion, _TestModule
}

Describe 'GirDir' {
    BeforeAll {
        $script:envHOMEBak = $env:HOME
        
        mkdir ($env:HOME = "$TestDrive/home")
        mkdir ($rootPath = "$TestDrive/gitRoot")

        "[user]
    email = Kitazato@example.com
    name = 1000yen" > "$env:HOME/.gitconfig"

        Push-Location $rootPath
        git init --initial-branch=main
        git commit -m "initial" --allow-empty
        Pop-Location
    }

    AfterAll {
        $env:HOME = $script:envHOMEBak
    }

    It '--git-dir=' {
        
    }
}
