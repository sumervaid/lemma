/* The overlap rule from Lemma/Meta/Overlap.lean, plus the draft renderer.
   pipeline/tests/test_explore.py runs this file under Node against the compiler's own output. */
(function (root, factory) {
  var api = factory();
  if (typeof module === "object" && module.exports) module.exports = api;
  else root.LemmaCore = api;
})(typeof self !== "undefined" ? self : this, function () {
  function overlapKind(keysA, keysB) {
    var a = new Set(keysA), b = new Set(keysB);
    var shared = 0;
    a.forEach(function (k) { if (b.has(k)) shared += 1; });
    if (shared === 0) return "none";
    if (shared === a.size && shared === b.size) return "identity";
    if (shared === a.size || shared === b.size) return "subtype";
    return "partial";
  }

  function fieldName(part) {
    var pieces = part.split(" ");
    return pieces[0].charAt(0).toLowerCase() + pieces[0].slice(1) + pieces.slice(1).join("");
  }

  function leanType(part) {
    var pieces = part.split(" ");
    return ["Lemma." + pieces[0]].concat(pieces.slice(1).map(function (a) { return "." + a; })).join(" ");
  }

  function toIdentifier(text) {
    var pieces = text.match(/[A-Za-z0-9]+/g) || [];
    return pieces.map(function (p) { return p.charAt(0).toUpperCase() + p.slice(1); }).join("");
  }

  function docstring(definition, citation) {
    var text = (definition.trim().replace(/\.+$/, "") + " (" + (citation.trim() || "citation to add") + ").").split(/\s+/).join(" ");
    return text.replace(/-\//g, "- /").replace(/\/-/g, "/ -");
  }

  function renderLean(d) {
    var imports = ["import Lemma"].concat(d.generated.map(function (m) { return "import Lemma.Generated." + m; }));
    var fields = d.parts.map(function (p) { return "  " + fieldName(p) + " : " + leanType(p); });
    return imports.concat([
      "",
      "namespace Lemma.Drafts." + d.name,
      "",
      "/-- " + docstring(d.definition, d.citation) + " -/",
      "@[construct] structure " + d.name + " extends " + d.category + " (level := ." + d.level + ") (horizon := ." + d.horizon + ") where"
    ], fields, ["", "end Lemma.Drafts." + d.name, ""]).join("\n");
  }

  return { overlapKind: overlapKind, renderLean: renderLean, toIdentifier: toIdentifier };
});
