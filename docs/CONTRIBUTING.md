# Contributing

You can start and look at the [tilemaker/process.lua](tilemaker/process.lua) for what keys and improve it by adding more keys and logic you can find inside of a [Tag:leisure=golf_course](https://wiki.openstreetmap.org/wiki/Tag:leisure%3Dgolf_course) Or if you just want to suggest a key to be added you can just suggest in the Discussion page of this repository with category: [New Keys](https://github.com/HuggeK/golfTiles/discussions/categories/new-keys).



## In regards to the use of LLM´s in the development process
If you are using LLM´s tools for development/issue-tracking/discussions, please sign of with both your name and the name of the LLM. It is both a question of integrity and it is easier for other contributors to be more cautious about hallucinated text. Please add the ```Co-authored-by``` trailer in your commit message if you are using a LLM to write all the code.



# Testing a pull request in your browser: the PR demo bundle
Every pull request (drafts included) automatically gets a downloadable **demo bundle** built by the "PR demo bundle" GitHub Actions workflow on each push. It lets you test a PR's schema ([custom-tilemaker/process.lua](../custom-tilemaker/process.lua)) and style ([styles/golfTilesStyle.json](../styles/golfTilesStyle.json)) changes in your own browser without installing osmium-tool or tilemaker.

The bundle contains:
- ```golfTiles.pmtiles``` — tiles freshly built by CI from a small committed test fixture ([tests/fixtures/golf-fixture.osm.pbf](../tests/fixtures/golf-fixture.osm.pbf), the area around Emmaboda GK and Nybro golfklubb).
- ```golfTilesStyle.json``` — the style exactly as committed on the PR branch.
- ```index.html``` — a local viewer that opens over Emmaboda GK at zoom 14 and points the style at the bundled tiles automatically.
- ```README.txt``` — the same instructions in short form.

To use it:
1. On the PR page go to Checks -> **PR demo bundle** -> Artifacts and download ```golftiles-demo-pr<N>-<sha>``` (you need to be logged in to GitHub).
2. Unzip it, and from that folder run ```npx http-server -p 8080 .```
3. Open http://localhost:8080/

Note that the pmtiles library needs HTTP Range Requests, which http-server supports — ```python -m http.server``` does not, and the map will stay blank with it. You can also inspect the ```golfTiles.pmtiles``` file directly with the file picker on https://pmtiles.io/ without any server.

The fixture is committed in the repo, so CI never downloads anything from Geofabrik; refresh the fixture manually with [tests/fixtures/extract-config.json](../tests/fixtures/extract-config.json) if it ever needs newer OSM data. The first CI run after a change to the Dockerfile or the tilemaker submodule recompiles tilemaker (~15–30 min); other runs reuse the GitHub Actions build cache and finish in a few minutes.



# Set up Maputnik locally in WSL to be able to work on the style:
Because I have not yet uploaded the example .pmtiles or the stle to a bucket which supports CORS some acrobatics with exposing the required things locally is needed:

To be able to graphicly edit the style locally with Maputnik you need to set up things locally. You then launch Maputnik using the docker image, example command line options is provided in [Maputnik.sh](Maputnik.sh) in to be able to update your golfTilesStyle.json in your IDE and the changes will be reflected back if you do not want to always use Maputnik.

I am developing on Windows using WSL on a Ubunut-26.04 image. Although maputnik is exposed through localhost on windows to be able to upload a style to edit you need to install firefox inside of Ubuntu in WSL and open Maputnik that way. Then chose the [style/golfTilesStyle.json](style/golfTilesStyle.json) with the browser picker. As mentioned before, because I have not made available the example .pmtiles on a bucket which supports CORS you need serve your .pmtiles with some simple http server which can be configured to allow CORS. For example [http-server](https://www.npmjs.com/package/http-server) using ```http-server ./samples --cors``` when situated in the root of the project. You then click on "data sources" in Maputnik and remove the one that points to golftiles.org which is imported through the style. Then add a pmtiles source and use the same source id of ```golfTiles_pmtiles_source``` which the style expects and the path to the tiles your http server is serving the files, for example: ```http://localhost:8080/golfTiles_se_dk_fi.pmtiles```

You need to manually pan to where the data is, watch the URL for the lat/long coordinates. You can then edit the style.


<details>

<summary>Previous discussion and questions on forums: </summary>
- Question about to be able to fallback to general purpose tileset for orientation to the golf courses on OSM US Slack: https://osmus.slack.com/archives/C03TFH5NE83/p1779814786461319 Using one for basemap and our golfTiles for overlay.
- Good feedback from the #developer channel in the OpenStreetMap Discord on how to make the export and filtering: [link](https://discord.com/channels/413070382636072960/607265062322700308/1508868644770283601)
- Tips from utidjinn, having a similar goal on the [OSM US slack #golf channel](https://osmus.slack.com/archives/CU8J8335X/p1780070298248989?thread_ts=1779912821.021149&cid=CU8J8335X)
</details>