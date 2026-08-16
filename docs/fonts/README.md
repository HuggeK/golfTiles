# Self-hosted font glyphs

These are prebuilt SDF glyph ranges (`{fontstack}/{range}.pbf`) consumed by the MapLibre GL style
via its top-level `glyphs` property:

```
https://huggek.github.io/golfTiles/fonts/{fontstack}/{range}.pbf
```

GitHub Pages serves everything with `Access-Control-Allow-Origin: *`, so the same URL also works
when the style is served from golftiles.org or embedded in third-party apps.

## Source and license

- The `.pbf` ranges were downloaded from the [openmaptiles/fonts](https://github.com/openmaptiles/fonts)
  project (`https://fonts.openmaptiles.org/`), which generates them from the original TTFs.
- **Open Sans** is © Google, licensed under the
  [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0). A verbatim copy of that
  licence ships next to the glyphs as [`LICENSE.txt`](LICENSE.txt) and is published with the
  site at `/fonts/LICENSE.txt`, which is what Apache 2.0 section 4(a) asks for when
  redistributing: these `.pbf` ranges are a derivative of the original font files.

  Note the version matters. Open Sans was relicensed from Apache 2.0 to the SIL Open Font
  License in March 2021, when it became a variable font. `openmaptiles/fonts` still builds from
  the older static TTFs (`OpenSans-Regular.ttf`, `OpenSans-Semibold.ttf`) and ships an
  `Apache License.txt` alongside them, so Apache 2.0 is the licence that applies to *these*
  ranges. If the ranges are ever regenerated from current upstream Open Sans, this needs to
  become OFL 1.1 instead.

## Adding another fontstack

Download all 256 ranges of the new stack into a sibling directory named exactly like the fontstack
(spaces included), e.g. `Open Sans Bold/0-255.pbf` … `65280-65535.pbf`, and reference it from the
style's `text-font`. The `publish-pages.yml` workflow copies the whole `docs/fonts/` directory into
the published site.
