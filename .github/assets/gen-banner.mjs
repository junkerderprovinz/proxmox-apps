/**
 * The repository banner, in the layout of the GitHub style guide: the Proxmox mark
 * on the left (largest ink 400px, ink-left x=165, centred on y=250), the name to
 * its right in Bree Serif Regular at a cap height of 110, and one Bree Light claim
 * below it. The mark is the Simple Icons path (CC0). Light and dark variants for the
 * README's <picture>; the single-colour mark takes the text colour of each.
 *
 * Text is rendered at the origin and placed with a transform, because
 * opentype.js emits NaN control points for some glyphs at large offsets.
 * Deps (global): opentype.js, @resvg/resvg-js, and the house fonts as TTF in
 * HOUSE_FONTS (default %LOCALAPPDATA%\halleluja-fonts).
 * Run: node .github/assets/gen-banner.mjs
 */
import { readFileSync, writeFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { tmpdir } from "node:os";
import { createRequire } from "node:module";
import { execSync } from "node:child_process";

const require = createRequire(import.meta.url);
const groot = execSync("npm root -g").toString().trim();
const opentype = require(`${groot}/opentype.js`);
const { Resvg } = require(`${groot}/@resvg/resvg-js`);
const DIR = dirname(fileURLToPath(import.meta.url));

const NAME = "Proxmox";
const CLAIM = "One line. One container.";

const MARK = {
  vb: "0 0 24 24",
  content: `<path fill="COLOR" d="M4.928 1.825c-1.09.553-1.09.64-.07 1.78 5.655 6.295 7.004 7.782 7.107 7.782.139.017 7.971-8.542 8.058-8.801.034-.07-.208-.312-.519-.536-.415-.312-.864-.433-1.712-.467-1.59-.104-2.144.242-4.115 2.455-.899 1.003-1.66 1.833-1.66 1.833-.017 0-.76-.813-1.642-1.798S8.473 2.1 8.127 1.91c-.796-.45-2.421-.484-3.2-.086zM1.297 4.367C.45 4.695 0 5.007 0 5.248c0 .121 1.331 1.678 2.94 3.459 1.625 1.78 2.939 3.268 2.939 3.302 0 .035-1.331 1.522-2.94 3.303C1.314 17.11.017 18.683.035 18.822c.086.467 1.504 1.055 2.541 1.055 1.678-.018 2.058-.312 5.603-4.202 1.78-1.954 3.233-3.614 3.233-3.666 0-.069-1.435-1.694-3.199-3.63-2.3-2.508-3.423-3.632-3.96-3.874-.812-.398-2.126-.467-2.956-.138zm18.467.12c-.502.26-1.764 1.505-3.943 3.891-1.763 1.937-3.199 3.562-3.199 3.631 0 .07 1.453 1.712 3.234 3.666 3.544 3.89 3.925 4.184 5.602 4.202 1.038 0 2.455-.588 2.542-1.055.017-.156-1.28-1.712-2.905-3.493-1.608-1.78-2.94-3.285-2.94-3.32 0-.034 1.332-1.539 2.94-3.32C22.72 6.91 24.017 5.352 24 5.214c-.087-.45-1.366-.968-2.473-1.038-.795-.034-1.21.035-1.763.312zM7.954 16.973c-2.144 2.369-3.908 4.374-3.943 4.46-.034.07.208.312.52.537.414.311.864.432 1.711.467 1.574.103 2.161-.26 4.15-2.508.864-.968 1.608-1.78 1.625-1.78s.761.812 1.643 1.798c2.023 2.248 2.559 2.576 4.132 2.49.848-.035 1.297-.156 1.712-.467.311-.225.553-.467.519-.536-.087-.26-7.92-8.819-8.058-8.801-.069 0-1.867 1.954-4.011 4.34z"/>`,
};

const W = 1600, H = 500, LOGO_INK = 400, LOGO_X = 165, GAP_LOGO_TEXT = 70, GAP_NAME_CLAIM = 16, CLAIM_SIZE = 44;
const TARGET_CAP = 110;
const THEMES = [
  { suf: "", bg: "#ffffff", name: "#1f2328", claim: "#5a5d5e" },
  { suf: "-dark", bg: "#0d1117", name: "#e6edf3", claim: "#9aa4ad" },
];

// The house typeface is licensed, so it is read from a local folder and never committed.
const fonts = process.env.HOUSE_FONTS ?? join(process.env.LOCALAPPDATA ?? tmpdir(), "halleluja-fonts");
const bree = opentype.parse(readFileSync(join(fonts, "bree-serif-regular.ttf")).buffer);
const claimFont = opentype.parse(readFileSync(join(fonts, "bree-light.ttf")).buffer);
const bbox = (vb, content) =>
  new Resvg(`<svg xmlns="http://www.w3.org/2000/svg" viewBox="${vb}">${content}</svg>`, { fitTo: { mode: "original" } }).getBBox();

const mb = bbox(MARK.vb, MARK.content.replace(/COLOR/g, "#000"));
const sM = LOGO_INK / Math.max(mb.width, mb.height);
const markTX = LOGO_X - mb.x * sM, markTY = H / 2 - (mb.height * sM) / 2 - mb.y * sM;
const textX = LOGO_X + mb.width * sM + GAP_LOGO_TEXT;

const capRatio = bbox("0 0 600 400", `<path d="${bree.getPath("H", 0, 300, 200).toPathData(2)}"/>`).height / 200;
// Some sizes hit the same opentype.js NaN bug in the name, so step past them.
let nameSize = TARGET_CAP / capRatio;
while (bree.getPath(NAME, 0, 0, nameSize).toPathData(2).includes("NaN")) nameSize += 0.01;
const nb = bbox("0 0 2000 800", `<path d="${bree.getPath(NAME, 0, 500, nameSize).toPathData(2)}"/>`);
const nameH = nb.height;
const nameD = bree.getPath(NAME, 0, 0, nameSize).toPathData(2);

const claimScale = CLAIM_SIZE / claimFont.unitsPerEm;
const claimAsc = claimFont.ascender * claimScale, claimDesc = -claimFont.descender * claimScale;
const top = H / 2 - (nameH + GAP_NAME_CLAIM + claimAsc + claimDesc) / 2;
const claimBaseline = Math.round(top + nameH + GAP_NAME_CLAIM + claimAsc);
const claimD = claimFont.getPath(CLAIM, 0, 0, CLAIM_SIZE, { kerning: false }).toPathData(2);
if (claimD.includes("NaN")) throw new Error("claim path has NaN points");

for (const t of THEMES) {
  const svg = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${H}" width="${W}" height="${H}" role="img" aria-label="${NAME}: ${CLAIM}">
  <rect width="${W}" height="${H}" fill="${t.bg}"/>
  <g transform="translate(${markTX.toFixed(2)},${markTY.toFixed(2)}) scale(${sM.toFixed(5)})">${MARK.content.replace(/COLOR/g, t.name)}</g>
  <g transform="translate(${textX.toFixed(2)},${(top - (nb.y - 500)).toFixed(2)})"><path d="${nameD}" fill="${t.name}"/></g>
  <g transform="translate(${textX.toFixed(2)},${claimBaseline})"><path d="${claimD}" fill="${t.claim}"/></g>
</svg>
`;
  writeFileSync(join(DIR, `banner${t.suf}.svg`), svg);
  writeFileSync(join(DIR, `banner${t.suf}.png`), new Resvg(svg, { background: t.bg, fitTo: { mode: "original" } }).render().asPng());
}
console.log(`proxmox-apps banner: name at x ${textX.toFixed(0)}, right margin ${(W - textX - nb.width).toFixed(0)}`);
