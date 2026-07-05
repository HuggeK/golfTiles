golfTiles PR demo bundle
========================

Contents
  index.html          - local map viewer (opens over Emmaboda GK, zoom 14)
  golfTilesStyle.json - the style exactly as committed on this PR branch
  golfTiles.pmtiles   - tiles built by CI from a small test fixture
                        (Emmaboda GK + Nybro golfklubb area only)

How to view
  1. Unzip this bundle into a folder.
  2. From that folder run:      npx http-server -p 8080 .
  3. Open:                      http://localhost:8080/

http-server supports HTTP Range Requests, which the pmtiles library
requires. Do NOT use "python -m http.server" - it does not support
Range requests and the map will stay blank.

You can also inspect golfTiles.pmtiles directly with the file picker
at https://pmtiles.io/ (no server needed).

Where this came from
  Built by the "PR demo bundle" GitHub Actions workflow. Find it on the
  PR page under Checks -> PR demo bundle -> Artifacts (you must be
  logged in to GitHub to download artifacts).
