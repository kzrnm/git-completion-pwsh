using System.Collections.Immutable;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;

namespace Kzrnm.GitCompletion.Generator;

[Generator]
public class SubcommandSelectorGenerator : IIncrementalGenerator
{
    public void Initialize(IncrementalGeneratorInitializationContext context)
    {
        context.RegisterImplementationSourceOutput(
            context.SyntaxProvider.CreateSyntaxProvider(IsClassNode, Transform)
            .Where(t => !t.Targets.IsDefaultOrEmpty)
            .Collect(),
            Write);
    }

    bool IsClassNode(SyntaxNode node, CancellationToken cancellationToken)
    {
        return node.IsKind(SyntaxKind.ClassDeclaration);
    }

    static readonly Regex subcommandClassRegex = new(@"^Subcommand(.+)");
    static readonly Regex camelRegex = new(@"(?!^)([A-Z])");

    (ImmutableArray<string> Targets, string ClassName) Transform(GeneratorSyntaxContext context, CancellationToken cancellationToken)
    {
        var node = (ClassDeclarationSyntax)context.Node;
        var symbol = context.SemanticModel.GetDeclaredSymbol(node, cancellationToken);
        if (symbol == null || node.AttributeLists.Count == 0)
            return (ImmutableArray<string>.Empty, "");

        var builder = ImmutableArray.CreateBuilder<string>();
        foreach (var attr in symbol.GetAttributes())
        {
            if (attr.AttributeClass?.ToString() != "Kzrnm.GitCompletion.Completion.GitSubcommandAttribute")
                continue;
            var attributeArguments = attr.ConstructorArguments[0].Values;
            if (attributeArguments.Length > 0)
            {
                builder.AddRange(attributeArguments.Select(t => t.Value).OfType<string>());
            }
            else if (subcommandClassRegex.Match(symbol.Name) is { Success: true, Groups: var m })
            {
                var name = m[1].Value;
                builder.Add(camelRegex.Replace(name, "-$1").ToLower());
            }
        }
        return (builder.ToImmutable(), symbol.ToString());
    }

    void Write(SourceProductionContext context, ImmutableArray<(ImmutableArray<string> Targets, string ClassName)> inputs)
    {
        var sb = new StringBuilder();
        sb.AppendLine("""
using Kzrnm.GitCompletion.Context;
using System.Collections.Generic;
using System.Management.Automation;

namespace Kzrnm.GitCompletion.Completion;
internal static partial class SubcommandSelector
{
    private static partial IEnumerable<CompletionResult> CompleteSubcommandImpl(CompletionContext context)
    {
switch (context.Command)
{
""");

        foreach (var (targets, className) in inputs)
        {
            foreach (var t in targets)
            {
                sb.AppendLine($"    case \"{t}\":");
            }
            sb.AppendLine($"        return {className}.Complete(context);");
        }
        sb.AppendLine("""
    default:
        return CompleteSubcommandCommon(context);
}
    }
}
""");
        context.AddSource("caller.cs", sb.ToString());
    }
}
