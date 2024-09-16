// Copyright (C) 2024 kzrnm
// Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
// Distributed under the GNU General Public License, version 2.0.
using Kzrnm.GitCompletion.Context;
using System.Collections.Generic;
using System.Diagnostics;
using System.Management.Automation;
using System.Management.Automation.Language;

namespace Kzrnm.GitCompletion;

public abstract class CompleteGitCommandBase : PSCmdlet
{
    [Parameter(Mandatory = true, ParameterSetName = "String")]
    [AllowEmptyCollection()]
    [AllowEmptyString()]
    public string[]? Words { get; set; }

    [Parameter(ParameterSetName = "String")]
    public int CurrentIndex { get; set; } = -1;


    [Parameter(Mandatory = true, ParameterSetName = "Ast")]
    [AllowEmptyCollection()]
    [AllowEmptyString()]
    public CommandAst? CommandAst { get; set; }

    [Parameter(Mandatory = true, ParameterSetName = "Ast")]
    public int CursorPosition { get; set; }

    private void ParseAst()
    {
        var ast = CommandAst;
        Debug.Assert(ast != null);

        var ws = new List<string>(ast!.CommandElements.Count + 2);

        var currentIndex = 0;
        for (int i = 0; i < ast.CommandElements.Count; i++)
        {
            var cmd = ast.CommandElements[i];
            var extent = cmd.Extent;
            string text = cmd switch
            {
                StringConstantExpressionAst { Value: { } constText } => constText.ToString(),
                ConstantExpressionAst { Value: { } constText } => constText.ToString(),
                _ => extent.Text,
            };

            if (currentIndex == 0 && CursorPosition <= extent.EndOffset)
            {
                currentIndex = i;
                if (CursorPosition < extent.StartOffset)
                {
                    ws.Add("");
                }
            }
            ws.Add(text);
        }

        if (currentIndex == 0)
        {
            currentIndex = ws.Count;
            ws.Add("");
        }

        Words = ws.ToArray();
        CurrentIndex = currentIndex;
    }

    // This method gets called once for each cmdlet in the pipeline when the pipeline starts executing
    protected override void BeginProcessing()
    {
        if (ParameterSetName == "Ast")
        {
            ParseAst();
        }

        Debug.Assert(Words != null);
        if (CurrentIndex < 0)
        {
            CurrentIndex = Words!.Length;
        }

        var settings = GetVariableValue(nameof(GitCompletionSettings)) as GitCompletionSettings;
        foreach (var c in Complete(new(this, settings, Words!, CurrentIndex)))
        {
            WriteObject(c);
        }
    }

    protected abstract IEnumerable<CompletionResult> Complete(CompletionContext context);
}
