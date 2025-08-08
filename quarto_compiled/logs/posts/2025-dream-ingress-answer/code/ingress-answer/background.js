// === background.js ===
// 1.  Load the long Markdown document that shows up in the DevTools console.
const DOC_URL = chrome.runtime.getURL("ingress-answer-doc.md");
let LONG_MD = "(loading…)";
fetch(DOC_URL)
  .then(r => r.text())
  .then(text => { LONG_MD = text; })
  .catch(() => { LONG_MD = "(failed to load ingress-answer-doc.md)"; });

// 2.  Build a list of HTML files to open from the ./quake folder, in filename order.
//     Preferred: provide an ordered JSON manifest at ./quake/index.json so the list
//     can be tweaked without touching code.
let QUAKE_FILES = [];
fetch(chrome.runtime.getURL("quake/index.json"))
  .then(r => r.ok ? r.json() : [])
  .then(list => { QUAKE_FILES = list; })
  .catch(() => {
    /* Fallback – edit the hard‑coded list below if you don’t want index.json */
    QUAKE_FILES = [
      "quake/imminent.html",
      "quake/quake.html",
      "quake/catastrophe.html",
      "quake/zero.html",
      "quake/coming.html",
      "quake/run.html"
    ];
  });

function quakeUrl(path) {
  return chrome.runtime.getURL(path);
}

// 3.  Add the two context‑menu items whenever the extension is installed or re‑loaded.
chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({ id: "ingress",      title: "Ingress Answer",         contexts: ["all"] });
  chrome.contextMenus.create({ id: "experimental", title: "Experimental: Doc here", contexts: ["all"] });
});

// 4.  Handle clicks.
chrome.contextMenus.onClicked.addListener((info, tab) => {
  /* EXPERIMENTAL: Dump the long Markdown into DevTools */
  if (info.menuItemId === "experimental") {
    chrome.scripting.executeScript({
      target: { tabId: tab.id },
      func: doc => console.log(doc),
      args: [LONG_MD]
    });

    // Best‑effort nudge to surface DevTools
    try {
      chrome.debugger.attach({ tabId: tab.id }, "1.3", () => {
        chrome.debugger.sendCommand({ tabId: tab.id }, "Inspector.enable", () =>
          chrome.debugger.detach({ tabId: tab.id })
        );
      });
    } catch (_) {
      /* Ignore; user can hit F12 manually. */
    }
  }

  /* INGRESS ANSWER: Spawn each ./quake HTML file to the immediate right of the current tab */
  if (info.menuItemId === "ingress") {
    QUAKE_FILES.forEach((file, i) => {
      chrome.tabs.create({
        url: quakeUrl(file),
        active: false,
        index: tab.index + 1 + i
      });
    });
  }
});
