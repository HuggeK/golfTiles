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
  [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

## Adding another fontstack

Download all 256 ranges of the new stack into a sibling directory named exactly like the fontstack
(spaces included), e.g. `Open Sans Bold/0-255.pbf` … `65280-65535.pbf`, and reference it from the
style's `text-font`. The `publish-pages.yml` workflow copies the whole `docs/fonts/` directory into
the published site.
