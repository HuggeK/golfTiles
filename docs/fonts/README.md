# Self-hosted font glyphs

These are prebuilt SDF glyph ranges (`{fontstack}/{range}.pbf`) consumed by the MapLibre GL style
via its top-level `glyphs` property:

```
https://huggek.github.io/golfTiles/fonts/{fontstack}/{range}.pbf
```

GitHub Pages serves everything with `Access-Control-Allow-Origin: *`, so the same URL also works
when the style is served from golftiles.org or embedded in third-party apps.

## Source and license

- Generated from the current upstream **Open Sans**, the variable font
  [`ofl/opensans/OpenSans[wdth,wght].ttf`](https://github.com/google/fonts/tree/main/ofl/opensans)
  in `google/fonts`.
- Licensed under the [SIL Open Font License 1.1](https://openfontlicense.org/), © 2020 The Open
  Sans Project Authors. A verbatim copy ships beside the glyphs as [`OFL.txt`](OFL.txt) and is
  published at `/fonts/OFL.txt`; the OFL requires the licence and copyright notice to travel with
  any redistribution, and these `.pbf` ranges are derived from the font.
- Open Sans was **relicensed from Apache 2.0 to OFL 1.1 in March 2021**, when it became a variable
  font. Older prebuilt ranges (for example those from `fonts.openmaptiles.org`) are built from the
  pre-2021 static TTFs and are still Apache 2.0. Do not mix the two without also changing `OFL.txt`.

## Why only 16 files, not 256

MapLibre requests glyphs one 256-codepoint block at a time, so a complete fontstack is 256 files
covering the whole Basic Multilingual Plane. For Open Sans only **16 of those blocks contain any
glyphs** — the other 240 are ~32-byte empty stubs for scripts the font does not cover, so they are
not committed.

A range that is absent 404s instead of returning an empty file. MapLibre treats both the same way:
it warns once and falls back to rendering that codepoint locally. Since the omitted blocks have no
glyphs to begin with, nothing renders differently — the only change is a console warning instead of
a silent empty response, and only for text outside Open Sans's coverage.

## Regenerating

The ranges were produced with MapLibre's own [font-maker](https://github.com/maplibre/font-maker)
WASM build (`sdfglyph.wasm`), which is what <https://maplibre.org/font-maker> runs. Drop the
variable TTF into that page, name the stack exactly `Open Sans Regular` so it matches `text-font`
in `styles/golfTilesStyle.json`, download the ZIP, and keep only the non-empty ranges. FreeType
uses the variable font's default instance (`wght` 400, `wdth` 100), which is Regular.

## Adding another fontstack

Put the new stack's ranges in a sibling directory named exactly like the fontstack (spaces
included), e.g. `Open Sans Bold/0-255.pbf`, and reference it from the style's `text-font`. The
`publish-pages.yml` workflow copies the whole `docs/fonts/` directory into the published site.
