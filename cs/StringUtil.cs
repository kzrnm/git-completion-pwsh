using System;

namespace Kzrnm.GitCompletion;
internal static class StringUtil
{
    public static string[] SplitEmpty(this string text) => text.Split(Array.Empty<char>(), StringSplitOptions.RemoveEmptyEntries);
}
