(function () {
  "use strict";
  var D = JSON.parse(document.getElementById("lemma-data").textContent);
  var Core = window.LemmaCore;
  var view = document.getElementById("view");
  var byId = {};
  D.constructs.forEach(function (c) { byId[c.id] = c; });
  var state = {
    q: "", theory: "", origin: "", part: "", claimQ: "", evidence: "", direction: "", agendaKind: "",
    a: "Burnout.Exhaustion", b: "Engagement.Vigor",
    draft: {
      name: "Work Vitality", definition: "A felt sense of energy and focus across the working week.",
      citation: "Example draft, replace with author, year, page", category: "AffectiveState",
      level: "Individual", horizon: "Weekly", parts: ["Energy", "Attention Work"], picker: "Learning"
    }
  };
  var NAV = [["start", "Overview"], ["constructs", "Constructs"], ["compare", "Compare"], ["claims", "Claims"],
    ["disagreements", "Disagreements"], ["agenda", "Agenda"], ["draft", "Draft a construct"], ["guide", "Guide"]];
  var KIND = {
    identity: "Identical definitions. Both constructs use exactly these parts at this scope.",
    subtype: "Nested definitions. Every part of one construct also belongs to the other.",
    partial: "Partial overlap. The constructs share some parts while each keeps parts of its own.",
    none: "Separate definitions. The constructs share no part at the same scope."
  };

  var KIND_WORD = { identity: "identical", subtype: "nested", partial: "partial" };
  var DECL_WORD = { distinct_from: "Declared distinct", alias_of: "Declared an alias", subtype_of: "Declared a subtype" };
  function esc(v) {
    return String(v == null ? "" : v).replace(/[&<>"']/g, function (ch) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[ch];
    });
  }
  function short(id) { return String(id).split(".").pop(); }
  function hashId(id) { return String(id).replace(/\./g, "-"); }
  function unhash(s) {
    var found = null;
    D.constructs.forEach(function (c) { if (hashId(c.id) === s) found = c; });
    return found;
  }
  function originPill(o) {
    return o === "curated" ? '<span class="pill">curated</span>' : '<span class="pill fixture">pipeline fixture</span>';
  }
  function chip(p, cls) { return '<span class="chip ' + (cls || "") + '"><b>' + esc(p.sym) + "</b>" + esc(p.label) + "</span>"; }
  function cLink(id) {
    return byId[id] ? '<a href="#c-' + hashId(id) + '">' + esc(id) + "</a>" : esc(id);
  }
  function csvButton(id) { return '<button class="btn" id="' + id + '" type="button">Download CSV</button>'; }
  function saveCsv(name, rows) {
    var text = rows.map(function (r) {
      return r.map(function (v) {
        var s = String(v == null ? "" : v);
        return /[",\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s;
      }).join(",");
    }).join("\n");
    var a = document.createElement("a");
    a.href = URL.createObjectURL(new Blob([text], { type: "text/csv" }));
    a.download = name;
    document.body.appendChild(a); a.click(); a.remove();
  }
  function options(list, sel, blank) {
    return (blank ? '<option value="">' + esc(blank) + "</option>" : "") + list.map(function (o) {
      return '<option value="' + esc(o) + '"' + (o === sel ? " selected" : "") + ">" + esc(o) + "</option>";
    }).join("");
  }
  function uniq(list) { return Array.from(new Set(list)).sort(); }
  function constructOptions(sel) {
    var groups = {};
    D.constructs.forEach(function (c) { (groups[c.theory] = groups[c.theory] || []).push(c); });
    return Object.keys(groups).sort().map(function (t) {
      return '<optgroup label="' + esc(t) + '">' + groups[t].map(function (c) {
        return '<option value="' + esc(c.id) + '"' + (c.id === sel ? " selected" : "") + ">" + esc(c.short) + "</option>";
      }).join("") + "</optgroup>";
    }).join("");
  }
  function go(hash) {
    if (location.hash === "#" + hash) route(); else location.hash = hash;
  }
  function bindGo() {
    view.querySelectorAll("[data-go]").forEach(function (el) {
      el.addEventListener("click", function () { go(el.getAttribute("data-go")); });
    });
    view.querySelectorAll("[data-compare]").forEach(function (el) {
      el.addEventListener("click", function () {
        var pair = el.getAttribute("data-compare").split("|");
        state.a = pair[0]; state.b = pair[1]; go("compare");
      });
    });
  }

  /* Overview */
  function start() {
    var s = D.summary;
    var max = Math.max.apply(null, D.catalog.map(function (p) { return p.uses; }));
    var tiles = D.catalog.map(function (p) {
      return '<button class="tile" type="button" data-part="' + esc(p.prim) + '" style="--heat:' + (p.uses / max).toFixed(2) + '" title="' + esc(p.doc) + '">' +
        '<span class="sym">' + esc(p.sym) + '</span><span class="n">' + p.uses + '</span><span class="nm">' + esc(p.prim) + "</span></button>";
    }).join("");
    var findings = D.findings.map(function (f) {
      var action = f.compare
        ? '<button class="linkish" type="button" data-compare="' + esc(f.compare.join("|")) + '">Compare the two definitions</button>'
        : '<button class="linkish" type="button" data-go="' + esc(f.view) + '">Open the evidence</button>';
      return '<article class="finding"><h3>' + esc(f.title) + "</h3><p>" + esc(f.body) + '</p><p class="caution">' + esc(f.caution) + "</p>" + action + "</article>";
    }).join("");
    var collections = D.collections.map(function (col) {
      return '<div class="collection"><h3>' + esc(col.title) + "</h3><span>" + esc(col.blurb) + '</span><div class="chips">' +
        col.constructs.map(function (id) { return '<a class="chip" style="padding-left:7px" href="#c-' + hashId(id) + '">' + esc(id) + "</a>"; }).join("") + "</div></div>";
    }).join("");
    view.innerHTML =
      '<section class="lede"><h1>Organizational theory, checked like code.</h1>' +
      "<p>Lemma writes every construct from a small vocabulary of basic parts at a stated level of analysis with a stated time horizon. A compiler then reports shared parts, undeclared scopes, disagreements among theories, plus claims the library implies. Everything below runs in this page, with nothing to install.</p></section>" +
      '<section class="stats" aria-label="Library size">' + [[s.constructs, "constructs"], [s.propositions, "claims"], [s.theories, "theories"], [s.papers_total, "source papers"], [s.primitives, "parts"]].map(function (x) {
        return "<div><b>" + x[0] + "</b><span>" + x[1] + "</span></div>";
      }).join("") + "</section>" +
      '<div class="status">' + esc(D.status) + "</div>" +
      '<section><div class="head-row"><h2>The table of parts</h2><span class="note">Each number counts the constructs using a part. Select a tile to list those constructs.</span></div><div class="table-of-parts">' + tiles + "</div></section>" +
      '<section><h2>What the compiler reports</h2><div class="findings">' + findings + "</div></section>" +
      '<section><h2>Good places to start</h2><div class="collections">' + collections + "</div></section>";
    view.querySelectorAll("[data-part]").forEach(function (el) {
      el.addEventListener("click", function () {
        state.part = el.getAttribute("data-part"); state.q = ""; state.theory = ""; state.origin = ""; go("constructs");
      });
    });
    bindGo();
  }

  /* Constructs */
  function matchesConstruct(c) {
    var q = state.q.toLowerCase().trim();
    if (state.theory && c.theory !== state.theory) return false;
    if (state.origin && c.origin !== state.origin) return false;
    if (state.part && !c.parts.some(function (p) { return p.prim === state.part; })) return false;
    if (!q) return true;
    var hay = (c.id + " " + c.doc + " " + c.parts.map(function (p) { return p.label; }).join(" ")).toLowerCase();
    return q.split(/\s+/).every(function (t) { return hay.indexOf(t) >= 0; });
  }
  function constructRows() {
    var rows = D.constructs.filter(matchesConstruct);
    document.getElementById("count").textContent = rows.length + " of " + D.constructs.length;
    document.getElementById("rows").innerHTML = rows.length ? rows.map(function (c) {
      return '<tr class="row" data-id="' + esc(c.id) + '"><td><a href="#c-' + hashId(c.id) + '">' + esc(c.short) + "</a></td><td>" + esc(c.theory) + "</td><td>" + esc(c.level + " / " + c.horizon) + '</td><td><div class="chips">' + c.parts.map(function (p) { return chip(p); }).join("") + "</div></td><td>" + originPill(c.origin) + "</td></tr>";
    }).join("") : '<tr><td colspan="5" class="empty">Nothing matches. Clear a filter or try one broader word.</td></tr>';
    document.querySelectorAll("tr.row").forEach(function (tr) {
      tr.addEventListener("click", function (e) {
        if (e.target.tagName !== "A") go("c-" + hashId(tr.getAttribute("data-id")));
      });
    });
  }
  function constructs() {
    view.innerHTML =
      '<section><div class="head-row"><h2>Constructs</h2><span class="note" id="count"></span></div>' +
      '<div class="controls">' +
      '<label class="f" for="q">Search<input id="q" type="search" placeholder="energy, trust, Hobfoll" value="' + esc(state.q) + '"></label>' +
      '<label class="f" for="theory">Theory<select id="theory">' + options(uniq(D.constructs.map(function (c) { return c.theory; })), state.theory, "All theories") + "</select></label>" +
      '<label class="f" for="part">Part<select id="part">' + options(D.catalog.map(function (p) { return p.prim; }), state.part, "All parts") + "</select></label>" +
      '<label class="f" for="origin">Source of entry<select id="origin">' + options(["curated", "pipeline fixture"], state.origin, "All entries") + "</select></label>" +
      csvButton("csv") + "</div>" +
      '<div class="scroll"><table><thead><tr><th>Construct</th><th>Theory</th><th>Scope</th><th>Built from</th><th>Entry</th></tr></thead><tbody id="rows"></tbody></table></div></section>';
    [["q", "q", "input"], ["theory", "theory", "change"], ["part", "part", "change"], ["origin", "origin", "change"]].forEach(function (x) {
      document.getElementById(x[0]).addEventListener(x[2], function (e) { state[x[1]] = e.target.value; constructRows(); });
    });
    document.getElementById("csv").addEventListener("click", function () {
      saveCsv("lemma-constructs.csv", [["construct", "theory", "level", "horizon", "parts", "source_of_entry", "definition"]].concat(D.constructs.filter(matchesConstruct).map(function (c) {
        return [c.id, c.theory, c.level, c.horizon, c.parts.map(function (p) { return p.label; }).join("; "), c.origin, c.doc];
      })));
    });
    constructRows();
  }
  function constructDetail(c) {
    var overlaps = D.overlaps.filter(function (o) { return o.a === c.id || o.b === c.id; });
    var claims = D.propositions.filter(function (p) { return p.a === c.id || p.b === c.id; });
    view.innerHTML =
      '<section class="detail"><div class="head-row"><h1 style="font-size:2rem">' + esc(c.short) + '</h1><button class="btn" type="button" data-go="constructs">All constructs</button></div>' +
      '<div class="meta"><span class="pill">' + esc(c.theory) + '</span><span class="pill">' + esc(c.level + " / " + c.horizon) + "</span>" + originPill(c.origin) + '<a href="' + esc(c.source) + '" rel="noopener">Read the source file</a></div>' +
      '<p class="definition">' + esc(c.doc) + "</p>" +
      '<div><div class="eyebrow">Built from</div><div class="chips" style="margin-top:5px">' + c.parts.map(function (p) { return chip(p); }).join("") + "</div></div></section>" +
      "<section><h2>Shares parts with " + overlaps.length + ' constructs</h2>' + (overlaps.length ? '<div class="scroll"><table><thead><tr><th>Construct</th><th>Overlap</th><th>Recorded decision</th><th></th></tr></thead><tbody>' + overlaps.map(function (o) {
        var other = o.a === c.id ? o.b : o.a;
        return "<tr><td>" + cLink(other) + '</td><td><span class="pill ' + esc(o.kind) + '">' + esc(KIND_WORD[o.kind]) + "</span></td><td>" + (o.declared ? esc(DECL_WORD[o.declared.kind] + ". " + o.declared.reason) : '<span class="pill">awaiting a decision</span>') + '</td><td><button class="linkish" type="button" data-compare="' + esc(c.id + "|" + other) + '">Compare</button></td></tr>';
      }).join("") + "</tbody></table></div>" : '<p class="note">This construct shares no part with another at the same scope.</p>') + "</section>" +
      "<section><h2>Appears in " + claims.length + " claims</h2>" + (claims.length ? claimTable(claims) : '<p class="note">No claim in the library uses this construct.</p>') + "</section>";
    bindGo();
  }

  /* Compare */
  function comparison() {
    var a = byId[state.a], b = byId[state.b];
    if (!a || !b) return '<p class="empty">Pick two constructs.</p>';
    var ka = a.parts.map(function (p) { return p.key; }), kb = b.parts.map(function (p) { return p.key; });
    var kind = Core.overlapKind(ka, kb);
    var shared = a.parts.filter(function (p) { return kb.indexOf(p.key) >= 0; });
    var onlyA = a.parts.filter(function (p) { return kb.indexOf(p.key) < 0; });
    var onlyB = b.parts.filter(function (p) { return ka.indexOf(p.key) < 0; });
    var shifts = onlyB.filter(function (p) { return onlyA.some(function (q) { return q.part === p.part; }); });
    var decl = D.declarations.filter(function (d) { return (d.a === a.id && d.b === b.id) || (d.a === b.id && d.b === a.id); })[0];
    var claims = D.propositions.filter(function (p) { return (p.a === a.id && p.b === b.id) || (p.a === b.id && p.b === a.id); });
    var corr = D.correlations.filter(function (r) { return (r.a === a.short && r.b === b.short) || (r.a === b.short && r.b === a.short); })[0];
    function col(title, list, cls) {
      return "<div><div class=\"eyebrow\">" + esc(title) + '</div><div class="chips">' + (list.length ? list.map(function (p) { return chip(p, cls); }).join("") : '<span class="note">None</span>') + "</div></div>";
    }
    return '<div class="detail"><div class="verdict"><strong>' + esc(KIND[kind].split(". ")[0]) + '</strong><span class="note">' + esc(KIND[kind].split(". ").slice(1).join(". ")) + "</span></div>" +
      '<div class="split">' + col("Shared", shared, "shared") + col("Only in " + a.id, onlyA) + col("Only in " + b.id, onlyB) + "</div>" +
      (shifts.length ? '<p class="note">The same part appears at a different scope: ' + esc(shifts.map(function (p) { return p.label; }).join(", ")) + ". A temporal or aggregation rule could connect them.</p>" : "") +
      '<div class="split"><div><div class="eyebrow">' + esc(a.id) + '</div><p style="font-family:var(--read)">' + esc(a.doc) + "</p></div><div><div class=\"eyebrow\">" + esc(b.id) + '</div><p style="font-family:var(--read)">' + esc(b.doc) + "</p></div></div>" +
      (decl ? '<div><div class="eyebrow">Recorded decision</div><p><span class="pill">' + esc(DECL_WORD[decl.kind]) + "</span> " + esc(decl.reason) + "</p></div>" : "") +
      (corr ? '<div class="status">Correlation on file ' + esc(corr.rho) + ". Status " + esc(corr.status) + ". This value awaits a check against " + esc(corr.source || "a source") + ".</div>" : "") +
      (claims.length ? '<div><div class="eyebrow">Claims linking the pair</div>' + claimTable(claims) + "</div>" : "") + "</div>";
  }
  function compare() {
    view.innerHTML = '<section class="lede"><h2>Compare two constructs</h2><p class="note">The result comes from the parts each definition uses, the same rule the compiler applies. Empirical distinctness is a separate question.</p></section>' +
      '<section><div class="controls"><label class="f" for="ca">First construct<select id="ca">' + constructOptions(state.a) + '</select></label><label class="f" for="cb">Second construct<select id="cb">' + constructOptions(state.b) + "</select></label></div><div id=\"cmp\"></div></section>" +
      '<section><h2>Pairs worth seeing</h2><div class="chips">' + D.findings.filter(function (f) { return f.compare; }).map(function (f) {
        return '<button class="btn" type="button" data-compare="' + esc(f.compare.join("|")) + '">' + esc(short(f.compare[0]) + " and " + short(f.compare[1])) + "</button>";
      }).join("") + '<button class="btn" type="button" data-compare="Thriving.Thriving|Engagement.Engagement">Thriving and Engagement</button><button class="btn" type="button" data-compare="COR.Resources|JDR.JobResources">Resources and JobResources</button></div></section>';
    function draw() { document.getElementById("cmp").innerHTML = comparison(); }
    document.getElementById("ca").addEventListener("change", function (e) { state.a = e.target.value; draw(); });
    document.getElementById("cb").addEventListener("change", function (e) { state.b = e.target.value; draw(); });
    view.querySelectorAll("[data-compare]").forEach(function (el) {
      el.addEventListener("click", function () {
        var pair = el.getAttribute("data-compare").split("|");
        state.a = pair[0]; state.b = pair[1];
        document.getElementById("ca").value = state.a; document.getElementById("cb").value = state.b; draw();
      });
    });
    draw();
  }

  /* Claims */
  function claimTable(list) {
    return '<div class="scroll"><table><thead><tr><th>Claim</th><th>Direction</th><th>Evidence</th><th>Stated in</th><th>Citation</th></tr></thead><tbody>' + list.map(function (p) {
      return "<tr><td>" + cLink(p.a) + " → " + cLink(p.b) + (p.boundary ? '<br><span class="note">' + esc(p.boundary) + "</span>" : "") + '</td><td><span class="pill ' + esc(p.direction) + '">' + esc(p.direction) + "</span></td><td>" + esc(p.evidence) + "</td><td>" + esc(p.theory) + (p.origin === "curated" ? "" : '<br><span class="pill fixture">pipeline fixture</span>') + "</td><td>" + esc(p.citation) + "</td></tr>";
    }).join("") + "</tbody></table></div>";
  }
  function matchesClaim(p) {
    if (state.evidence && p.evidence !== state.evidence) return false;
    if (state.direction && p.direction !== state.direction) return false;
    var q = state.claimQ.toLowerCase().trim();
    if (!q) return true;
    var hay = (p.a + " " + p.b + " " + p.doc + " " + p.citation + " " + p.theory).toLowerCase();
    return q.split(/\s+/).every(function (t) { return hay.indexOf(t) >= 0; });
  }
  function claims() {
    view.innerHTML = '<section><div class="head-row"><h2>Claims</h2><span class="note" id="count"></span></div><div class="controls">' +
      '<label class="f" for="cq">Search<input id="cq" type="search" placeholder="exhaustion, Hobfoll" value="' + esc(state.claimQ) + '"></label>' +
      '<label class="f" for="ev">Evidence<select id="ev">' + options(uniq(D.propositions.map(function (p) { return p.evidence; })), state.evidence, "All evidence") + "</select></label>" +
      '<label class="f" for="dir">Direction<select id="dir">' + options(uniq(D.propositions.map(function (p) { return p.direction; })), state.direction, "All directions") + "</select></label>" +
      csvButton("csv") + '</div><div id="tbl"></div></section>';
    function draw() {
      var rows = D.propositions.filter(matchesClaim);
      document.getElementById("count").textContent = rows.length + " of " + D.propositions.length;
      document.getElementById("tbl").innerHTML = rows.length ? claimTable(rows) : '<p class="empty">Nothing matches. Clear a filter or try one broader word.</p>';
    }
    document.getElementById("cq").addEventListener("input", function (e) { state.claimQ = e.target.value; draw(); });
    document.getElementById("ev").addEventListener("change", function (e) { state.evidence = e.target.value; draw(); });
    document.getElementById("dir").addEventListener("change", function (e) { state.direction = e.target.value; draw(); });
    document.getElementById("csv").addEventListener("click", function () {
      saveCsv("lemma-claims.csv", [["antecedent", "consequent", "direction", "scope", "evidence", "boundary", "theory", "source_of_entry", "citation"]].concat(D.propositions.filter(matchesClaim).map(function (p) {
        return [p.a, p.b, p.direction, p.scope, p.evidence, p.boundary, p.theory, p.origin, p.citation];
      })));
    });
    draw();
  }

  /* Disagreements */
  function simpleTable(head, rows) {
    return '<div class="scroll"><table><thead><tr>' + head.map(function (h) { return "<th>" + esc(h) + "</th>"; }).join("") + "</tr></thead><tbody>" + rows.join("") + "</tbody></table></div>";
  }
  function disagreements() {
    var dir = function (d) { return '<span class="pill ' + esc(d) + '">' + esc(d) + "</span>"; };
    var pairRow = function (x) { return cLink(x.antecedent) + " → " + cLink(x.consequent); };
    view.innerHTML =
      '<section class="lede"><h2>Where theories part ways</h2><p class="note">The compiler compares claims with one pair of constructs, one scope, one boundary condition. Each result rests on the author\'s readings of the sources.</p></section>' +
      "<section><h3>Direct contradictions</h3>" + simpleTable(["Pair", "First theory", "Second theory", "Scope"], D.contradictions.map(function (x) { return "<tr><td>" + pairRow(x) + "</td><td>" + esc(x.theoryA) + " " + dir(x.directionA) + "</td><td>" + esc(x.theoryB) + " " + dir(x.directionB) + "</td><td>" + esc(x.level + " / " + x.horizon) + "</td></tr>"; })) + "</section>" +
      '<section><h3>Implied against direct</h3><p class="note">Chaining two claims implies a sign which a direct claim in the library contradicts.</p>' + simpleTable(["Pair", "Implied", "Direct claim", "Theories"], D.impliedConflicts.map(function (x) { return "<tr><td>" + cLink(x.a) + " → " + cLink(x.b) + "</td><td>" + dir(x.direction) + "</td><td>" + esc(x.registered) + "</td><td>" + esc(x.theories.join(", ")) + "</td></tr>"; })) + "</section>" +
      '<section><h3>Disagreement under a condition</h3><p class="note">Opposing directions under different boundary conditions.</p>' + simpleTable(["Pair", "First theory", "Second theory"], D.conditional.map(function (x) { return "<tr><td>" + pairRow(x) + "</td><td>" + esc(x.theoryA) + " " + dir(x.directionA) + "</td><td>" + esc(x.theoryB) + " " + dir(x.directionB) + "<br><span class=\"note\">" + esc(x.boundaryB) + "</span></td></tr>"; })) + "</section>" +
      '<section><h3>Disagreement on shape</h3><p class="note">One theory states a straight relation while another states a curve.</p>' + simpleTable(["Pair", "First theory", "Second theory"], D.shape.map(function (x) { return "<tr><td>" + pairRow(x) + "</td><td>" + esc(x.theoryA) + " " + dir(x.directionA) + "</td><td>" + esc(x.theoryB) + " " + dir(x.directionB) + "</td></tr>"; })) + "</section>" +
      '<section><h3>Agreement across theories</h3><p class="note">The same claim stated in two or more theories.</p>' + simpleTable(["Pair", "Direction", "Theories"], D.convergences.map(function (x) { return "<tr><td>" + pairRow(x) + "</td><td>" + dir(x.direction) + "</td><td>" + esc(x.theories.join(", ")) + "</td></tr>"; })) + "</section>" +
      '<section><h3>Papers the pipeline refused</h3><div class="status">Hand-written fixtures produced these outcomes in order to exercise the pipeline. No model ran.</div><ul class="plain">' + D.failures.map(function (f) {
        var notes = f.reason ? [f.reason] : f.notes.slice(0, 1);
        return '<li><span class="pill">' + esc(f.status) + "</span> <b>" + esc(f.paper) + "</b><br>" + esc(notes.join(" ")) + "</li>";
      }).join("") + "</ul></section>";
  }

  /* Agenda */
  function agenda() {
    var w = "Score = 0.40 evidence weakness + 0.25 structural load + 0.25 disagreement + 0.10 implied.";
    view.innerHTML = '<section class="lede"><h2>The verification agenda</h2><p class="note">A ranking of where a new study would teach the library the most. ' + esc(w) + " Implied rows name pairs with no direct claim in the library. Many may already have tests in the wider literature.</p></section>" +
      '<section><div class="controls"><label class="f" for="ak">Kind<select id="ak">' + options(["registered", "implied"], state.agendaKind, "All candidates") + "</select></label>" + csvButton("csv") + '</div><div id="tbl"></div></section>';
    function rows() { return D.agenda.filter(function (i) { return !state.agendaKind || i.kind === state.agendaKind; }); }
    function draw() {
      document.getElementById("tbl").innerHTML = simpleTable(["Rank", "Score", "Pair", "Kind", "Direction", "Why"], rows().slice(0, 60).map(function (i, n) {
        return '<tr><td class="num">' + (n + 1) + '</td><td class="num">' + i.score.toFixed(3) + "</td><td>" + cLink(i.a) + " → " + cLink(i.b) + '</td><td><span class="pill">' + esc(i.kind) + '</span></td><td><span class="pill ' + esc(i.direction) + '">' + esc(i.direction) + "</span></td><td><details><summary>Reasons</summary>" + i.why.map(function (y) { return "<div>" + esc(y) + "</div>"; }).join("") + "</details></td></tr>";
      })) + (rows().length > 60 ? '<p class="note" style="margin-top:8px">Showing the top 60 of ' + rows().length + ". The CSV holds every row.</p>" : "");
    }
    document.getElementById("ak").addEventListener("change", function (e) { state.agendaKind = e.target.value; draw(); });
    document.getElementById("csv").addEventListener("click", function () {
      saveCsv("lemma-agenda.csv", [["rank", "score", "antecedent", "consequent", "kind", "direction", "scope", "evidence", "theories"]].concat(rows().map(function (i, n) {
        return [n + 1, i.score, i.a, i.b, i.kind, i.direction, i.scope, i.evidence, i.theories.join("; ")];
      })));
    });
    draw();
  }

  /* Draft */
  function partChoices() {
    var out = [];
    D.catalog.forEach(function (entry) {
      var combos = [[]];
      entry.params.forEach(function (param) {
        var next = [];
        combos.forEach(function (c) { param.values.forEach(function (v) { next.push(c.concat([v])); }); });
        combos = next;
      });
      combos.forEach(function (c) { out.push({ part: [entry.prim].concat(c).join(" "), prim: entry.prim, sym: entry.sym, args: c }); });
    });
    return out;
  }
  var CHOICES = partChoices();
  var LABELS = {};
  D.constructs.forEach(function (c) { c.parts.forEach(function (p) { LABELS[p.part] = p.label; }); });
  function labelOf(part) { return LABELS[part] || part.replace(/([a-z])([A-Z])/g, "$1 $2"); }
  function draftResults() {
    var d = state.draft;
    var name = Core.toIdentifier(d.name);
    var keys = d.parts.map(function (p) { return p + "|" + d.level + "|" + d.horizon; });
    var hits = D.constructs.map(function (c) {
      return { c: c, kind: Core.overlapKind(keys, c.parts.map(function (p) { return p.key; })) };
    }).filter(function (h) { return h.kind !== "none"; });
    var order = { identity: 0, subtype: 1, partial: 2 };
    hits.sort(function (x, y) { return order[x.kind] - order[y.kind] || x.c.id.localeCompare(y.c.id); });
    var counts = { identity: 0, subtype: 0, partial: 0 };
    hits.forEach(function (h) { counts[h.kind] += 1; });
    var verdict = !d.parts.length ? "Add at least one part."
      : !/^[A-Za-z]/.test(name) ? "A name needs a word starting with a letter."
      : counts.identity ? counts.identity + " existing constructs have exactly this definition."
      : hits.length ? "This draft overlaps " + hits.length + " existing constructs."
      : "This draft overlaps nothing in the library at this scope.";
    var valid = d.parts.length && /^[A-Za-z]/.test(name);
    var lean = valid ? Core.renderLean({ name: name, definition: d.definition, citation: d.citation, category: d.category, level: d.level, horizon: d.horizon, parts: d.parts, generated: D.generated }) : "";
    document.getElementById("draft-out").innerHTML =
      '<div class="verdict"><strong>' + esc(verdict) + '</strong><span class="note">' + counts.identity + " identical, " + counts.subtype + " nested, " + counts.partial + " partial. Each overlap asks for a recorded decision with a stated reason.</span></div>" +
      (hits.length ? '<div class="scroll"><table><thead><tr><th>Construct</th><th>Overlap</th><th>Entry</th></tr></thead><tbody>' + hits.slice(0, 40).map(function (h) {
        return "<tr><td>" + cLink(h.c.id) + '</td><td><span class="pill ' + esc(h.kind) + '">' + esc(KIND_WORD[h.kind]) + "</span></td><td>" + originPill(h.c.origin) + "</td></tr>";
      }).join("") + "</tbody></table></div>" : "") +
      (valid ? '<div class="head-row"><div class="eyebrow">Ready to compile</div><button class="btn" id="copy" type="button">Copy the Lean file</button></div><pre class="code" id="lean">' + esc(lean) + "</pre>" : "") +
      '<p class="note">This page applies the overlap rule alone. The compiler runs all four checks. Save the file as drafts/' + esc(valid ? name : "MyIdea") + '.lean, then run lemma try on the file, or open a <a href="' + esc(D.repository) + '/discussions" rel="noopener">discussion</a> to propose the construct.</p>';
    var copy = document.getElementById("copy");
    if (copy) copy.addEventListener("click", function () {
      var done = function () { copy.textContent = "Copied"; };
      var fallback = function () {
        var r = document.createRange(); r.selectNodeContents(document.getElementById("lean"));
        var s = getSelection(); s.removeAllRanges(); s.addRange(r); copy.textContent = "Selected, press copy";
      };
      if (navigator.clipboard) navigator.clipboard.writeText(lean).then(done, fallback); else fallback();
    });
  }
  function draftChips() {
    document.getElementById("draft-parts").innerHTML = state.draft.parts.map(function (p, i) {
      var entry = CHOICES.filter(function (c) { return c.part === p; })[0];
      return '<span class="chip"><b>' + esc(entry ? entry.sym : "?") + "</b>" + esc(labelOf(p)) + '<button type="button" data-rm="' + i + '" aria-label="Remove ' + esc(p) + '">×</button></span>';
    }).join("") || '<span class="note">No parts yet.</span>';
    document.querySelectorAll("[data-rm]").forEach(function (b) {
      b.addEventListener("click", function () {
        state.draft.parts.splice(Number(b.getAttribute("data-rm")), 1);
        draftChips(); draftResults();
      });
    });
  }
  function draft() {
    var d = state.draft;
    var groups = {};
    CHOICES.forEach(function (c) { (groups[c.prim] = groups[c.prim] || []).push(c); });
    var pick = Object.keys(groups).map(function (prim) {
      return '<optgroup label="' + esc(prim) + '">' + groups[prim].map(function (c) {
        return '<option value="' + esc(c.part) + '"' + (c.part === d.picker ? " selected" : "") + ">" + esc(labelOf(c.part)) + "</option>";
      }).join("") + "</optgroup>";
    }).join("");
    var cats = Object.keys(D.categories).map(function (k) {
      return '<option value="' + esc(k) + '"' + (k === d.category ? " selected" : "") + ">" + esc(D.categories[k]) + "</option>";
    }).join("");
    view.innerHTML = '<section class="lede"><h2>Draft a construct</h2><p class="note">Describe an idea in plain terms. The library answers at once with every construct already built from the same parts. The example below is a sample to edit.</p></section>' +
      '<section class="draft"><form class="form" id="draft-form">' +
      '<label class="f" for="d-name">Name<input id="d-name" value="' + esc(d.name) + '"></label>' +
      '<label class="f" for="d-def">One-sentence definition<textarea id="d-def">' + esc(d.definition) + "</textarea></label>" +
      '<label class="f" for="d-cit">Citation<input id="d-cit" value="' + esc(d.citation) + '"></label>' +
      '<label class="f" for="d-cat">Category<select id="d-cat">' + cats + "</select></label>" +
      '<div class="row2"><label class="f" for="d-lev">Level of analysis<select id="d-lev">' + options(D.levels, d.level) + '</select></label><label class="f" for="d-hor">Time horizon<select id="d-hor">' + options(D.horizons, d.horizon) + "</select></label></div>" +
      '<div class="eyebrow">Parts</div><div class="chips" id="draft-parts"></div>' +
      '<div class="controls"><label class="f" for="d-pick" style="flex:1">Add a part<select id="d-pick" style="width:100%">' + pick + '</select></label><button class="btn primary" id="d-add" type="button">Add</button></div>' +
      '</form><div class="results" id="draft-out"></div></section>';
    [["d-name", "name"], ["d-def", "definition"], ["d-cit", "citation"]].forEach(function (x) {
      document.getElementById(x[0]).addEventListener("input", function (e) { d[x[1]] = e.target.value; draftResults(); });
    });
    [["d-cat", "category"], ["d-lev", "level"], ["d-hor", "horizon"]].forEach(function (x) {
      document.getElementById(x[0]).addEventListener("change", function (e) { d[x[1]] = e.target.value; draftResults(); });
    });
    document.getElementById("d-pick").addEventListener("change", function (e) { d.picker = e.target.value; });
    document.getElementById("d-add").addEventListener("click", function () {
      var value = document.getElementById("d-pick").value;
      if (d.parts.indexOf(value) < 0) d.parts.push(value);
      draftChips(); draftResults();
    });
    document.getElementById("draft-form").addEventListener("submit", function (e) { e.preventDefault(); });
    draftChips(); draftResults();
  }

  /* Guide */
  function guide() {
    var terms = [
      ["Part", "A basic quantity such as energy or attention. The library calls these primitives. Parts carry no sign, so a construct states in the definition whether the construct reads the high pole or the low pole."],
      ["Construct", "A named concept written as a set of parts at one level of analysis with one time horizon."],
      ["Scope", "The pairing of a level of analysis with a time horizon, such as Individual / Weekly."],
      ["Claim", "A typed statement linking two constructs, with a direction, a scope, an evidence kind, a citation. The library calls these propositions."],
      ["Overlap", "Two constructs sharing at least one part at the same scope. Identical means the same parts. Nested means one set sits inside the other. Partial means each keeps parts of its own."],
      ["Recorded decision", "A statement by a scholar on an overlap, marking the pair distinct, an alias, or a subtype, with a reason."],
      ["Implied pair", "A relation produced by chaining two claims. Untested in the reports means the library holds no direct claim on the pair. The wider literature may hold tests."],
      ["Curated entry", "A definition or claim the author wrote from the cited source. Fidelity to the source is itself a verification task."],
      ["Pipeline fixture", "An entry from a hand-written file standing in for model output. No model produced any entry in this release."]
    ];
    view.innerHTML = '<section class="lede"><h2>Guide</h2><p class="note">Three ways in, with no prior knowledge of Lean.</p></section>' +
      '<section class="split"><div><h3>Browse here</h3><p>Every page on this site runs in the browser. Start with the table of parts, then compare two constructs.</p></div>' +
      '<div><h3>Use a cloud workspace</h3><p>A GitHub account opens a ready workspace with the compiler in place. <a href="https://codespaces.new/sumervaid/lemma" rel="noopener">Open a Codespace</a>, then run lemma new in the terminal.</p></div>' +
      '<div><h3>Install on a laptop</h3><p>On macOS or Linux, paste one line into Terminal. Windows users can take the cloud workspace.</p><pre class="code">curl -fsSL https://raw.githubusercontent.com/sumervaid/lemma/main/install.sh | bash</pre></div></section>' +
      '<section><h2>Terms</h2><div class="scroll"><table><tbody>' + terms.map(function (t) { return "<tr><td><b>" + esc(t[0]) + "</b></td><td>" + esc(t[1]) + "</td></tr>"; }).join("") + "</tbody></table></div></section>" +
      '<section><h2>What this release leaves open</h2><ul class="plain"><li>No model has run. Precision is unmeasured.</li><li>Correlations on file are placeholder or recalled values, each labelled.</li><li>Four source readings await a check, listed in section J of the technical appendix.</li><li>Composition stops at chains of two claims, and an implied sign describes one path.</li></ul></section>' +
      "<section><h2>Sources</h2><details><summary>" + D.sources.length + ' curated sources</summary><ul class="plain" style="margin-top:8px">' + D.sources.map(function (s) { return "<li>" + esc(s.ref) + "</li>"; }).join("") + "</ul></details></section>";
  }

  var VIEWS = { start: start, constructs: constructs, compare: compare, claims: claims, disagreements: disagreements, agenda: agenda, draft: draft, guide: guide };
  function route() {
    var h = location.hash.replace(/^#/, "") || "start";
    var active = h.indexOf("c-") === 0 ? "constructs" : h;
    var c = h.indexOf("c-") === 0 ? unhash(h.slice(2)) : null;
    document.getElementById("nav").innerHTML = NAV.map(function (n) {
      return '<a href="#' + n[0] + '"' + (n[0] === active ? ' aria-current="page"' : "") + ">" + esc(n[1]) + "</a>";
    }).join("");
    if (c) constructDetail(c); else (VIEWS[h] || start)();
    window.scrollTo(0, 0);
  }
  document.getElementById("foot").innerHTML = 'Kernel ' + esc(D.summary.kernel_version) + '. Generated from the compiler report of ' + esc(D.generatedAt.slice(0, 10)) + '. <a href="' + esc(D.repository) + '" rel="noopener">Source code</a>, Apache-2.0.';
  window.addEventListener("hashchange", route);
  route();
})();
