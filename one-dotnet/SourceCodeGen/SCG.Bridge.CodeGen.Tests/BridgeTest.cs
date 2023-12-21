using System.Reflection;
using System.Text.RegularExpressions;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;

namespace TPFive.SCG.Bridge.CodeGen.Tests;

using TPFive.SCG.Bridge.Abstractions;
using TPFive.SCG.Bridge.CodeGen;

public class BridgeTest
{
    private const string Namespace = "TPFive.SCG.Bridge.CodeGen.Tests";

    [SetUp]
    public void Setup()
    {
    }

    private static Compilation CreateCompilation(string source)
    {
        var references = AppDomain.CurrentDomain
            .GetAssemblies()
            .Where(_ => !_.IsDynamic && !string.IsNullOrWhiteSpace(_.Location))
            .Select(_ => MetadataReference.CreateFromFile(_.Location))
            .Concat(new[]
            {
                // add your app/lib specifics, e.g.:
                MetadataReference.CreateFromFile(typeof(DelegateFromAttribute).GetTypeInfo().Assembly.Location)
            })
            .ToList();

        return CSharpCompilation.Create(
            "compilation",
            new[] { CSharpSyntaxTree.ParseText(source) },
            references,
            new CSharpCompilationOptions(OutputKind.ConsoleApplication));
    }

    [Test]
    public void DefaultUsage()
    {
        var code = $@"
namespace {Namespace}
{{
    using TPFive.SCG.Bridge.Abstractions;

    public sealed partial class Service
    {{
        [DelegateFrom(DelegateName = ""PlaySound"")]
        public void PlaySound(string name)
        {{
        }}
    }}
}}
";
        var inputCompilation = CreateCompilation(code);

        var generator = new SourceGenerator();
        var driver = CSharpGeneratorDriver.Create(generator);
        driver = (CSharpGeneratorDriver)driver.RunGeneratorsAndUpdateCompilation(inputCompilation, out var outputCompilation, out var diagnostics);
        var runResult = driver.GetRunResult();
        var generatedSource = runResult.Results[0].GeneratedSources[0].SourceText.ToString();

        var generatedCode = @"
// <auto-generated />

using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace TPFive.Cross
{
    /// <summary>
    /// This is from TPFive.SCG.Bridge.CodeGen.Tests Service.
    /// </summary>
    public sealed partial class Bridge
    {

        public delegate void PlaySoundDelegate(
            string name);

        /// <summary>
        /// Define handler for PlaySound.
        /// </summary>
        public static PlaySoundDelegate PlaySound;

    }
}
";

        Assert.IsTrue(generatedSource.Contains(generatedCode));
    }

    [Test]
    [TestCase(@"C:\abc\def\ghi\one-unity\core\dev\")]
    [TestCase(@"C:\abc\def\ghi\one-unity\creator\dev\h932\")]
    [TestCase("/abc/def/ghi/one-unity/core/dev/")]
    [TestCase("/abc/def/ghi/one-unity/creator/dev/h932/")]
    public void ReturnCorrectIndexGivenValidPath(string inPath)
    {
        var sep = Path.DirectorySeparatorChar;
        var pattern = @"[\\/]";
        var adjustedInPath = Regex.Replace(inPath, pattern, sep.ToString());
        var actual = Utility.GetAfterOneUnityPathIndex(adjustedInPath);
        var expected = 4;

        Assert.AreEqual(expected, actual);
    }

    [Test]
    [TestCase(@"C:\abc\def\ghi\ccc\aaa\dev\")]
    [TestCase(@"C:\abc\def\ghi\one-unity\aaa\dev\")]
    [TestCase(@"C:\abc\def\ghi\ne-unity\ccc\dev\h932\")]
    [TestCase(@"C:\abc\def\ghi\ccc\core\dev\")]
    [TestCase(@"C:\abc\def\ghi\ccc\creator\dev\")]
    [TestCase("/abc/def/ghi/ccc/aaa/dev/")]
    [TestCase("/abc/def/ghi/one-unity/aaa/dev/")]
    [TestCase("/abc/def/ghi/one-unity/ccc/dev/h932/")]
    [TestCase("/abc/def/ghi/ccc/core/dev/")]
    [TestCase("/abc/def/ghi/ccc/creator/dev/")]
    public void ReturnBelowZeroIndexGivenInvalidPath(string inPath)
    {
        var sep = Path.DirectorySeparatorChar;
        var pattern = @"[\\/]";
        var adjustedInPath = Regex.Replace(inPath, pattern, sep.ToString());
        var actual = Utility.GetAfterOneUnityPathIndex(adjustedInPath);
        var expected = -1;

        Assert.AreEqual(expected, actual);
    }
}
