# MatrixRain Screensaver Script

A Unicode-enhanced Matrix rain screensaver supporting all major world alphabets and CJK characters, optimized for macOS WebViewScreenSaver and web demo use.

## 🌐 Live Demo
[GitHub Pages Demo](https://j---f.github.io/MatrixRain-Screensaver-Script/)

## Features
- Classic Matrix rain animation in vibrant green
- Full Unicode support: Latin, Greek, Cyrillic, Hebrew, Arabic, CJK (Chinese, Japanese, Korean), Indic, Klingon (Piqad), and more
- No emoji/tofu squares: robust font loading and glyph filtering
- Responsive design, works in browsers and as a screensaver
- Uses Google Noto fonts for broad script coverage

## Klingon (Piqad) Support
The Klingon script (Piqad, ISO-15924 code Piqd/293) is included using the Private Use Area (PUA: U+F8D0–U+F8FF). To see Klingon glyphs rendered correctly, you must provide a compatible Klingon Piqad font file.

### How to Add Klingon Font
1. Download a Klingon Piqad font (such as KLIpIqaD or pIqaD HaSta):
   - [KLI pIqaD font (truetype)](https://www.kli.org/fonts/pIqaD.ttf)
   - [Alternative Klingon fonts (scroll to pIqaD section)](https://www.evertype.com/fonts/tlh/)
2. Rename the downloaded font to `KLIpIqaD.ttf` or convert to `KLIpIqaD.woff2` if you prefer webfont format.
3. Place the font file in the same directory as your `index.html`/`MatrixRain.html`.
4. The Matrix Rain will now display Klingon glyphs in the rain animation!

**Note:** Without the font, Klingon characters will appear as tofu (empty squares).

## Supported Scripts

This project now supports a wide range of scripts, including:
- Klingon (PUA)
- Cardassian
- Hebrew, Yiddish
- Latin, Greek, Cyrillic, Armenian, Georgian, etc.
- Japanese (Hiragana, Katakana, Kanji)
- Chinese Hanzi
- Korean Hangul
- Modern Sundanese, Old Sundanese
- Balinese
- Makassanese (Makasar)

## Single-Alphabet Matrix Rain

For research, font QA, and demo purposes, every supported script/alphabet has its own standalone Matrix Rain HTML file. These files render the rain effect using only one script at a time (e.g. only Klingon, only Cardassian, only Hebrew, etc.).

Example files:
- `matrixrain_klingon.html` — Klingon-only Matrix Rain
- `matrixrain_cardassian.html` — Cardassian-only Matrix Rain
- `matrixrain_hebrew.html` — Hebrew-only Matrix Rain
- ...and many more, one per script in the main array

These are auto-generated via `matrixrain_generate_all_single_script_rain.js`.

To view a specific script's rain effect, simply open the corresponding HTML file in your browser.

---

## Usage
### 1. Web Demo
Visit the [Live Demo](https://j---f.github.io/MatrixRain-Screensaver-Script/) to see it in action.

### 2. macOS Screensaver
- Download the latest `MatrixRain-Screensaver.zip` from [Releases](https://github.com/j---f/MatrixRain-Screensaver-Script/releases)
- Unzip and use the HTML file with [WebViewScreenSaver](https://github.com/liquidx/webviewscreensaver)
- In WebViewScreenSaver settings, set the HTML file as the screensaver source

### 3. Manual
- Download `MatrixRain.html` or `index.html`
- Open in any modern browser

## Download
- [Latest Release (ZIP)](https://github.com/j---f/MatrixRain-Screensaver-Script/releases)

## Screenshots
*Add screenshots here after first deployment*

## Troubleshooting: HDMI/TV Usage

If the Matrix Rain script is not loading or displaying when using an HDMI TV or external monitor:
- Ensure your browser window is maximized or in fullscreen mode for best results.
- The canvas now auto-resizes to fit any screen (including TVs and projectors).
- Make sure all required font files are present and accessible. Some fonts (like Noto Sans Makasar) may not be available on Google Fonts yet.
- If you see blank columns or no rain, try a hard refresh (Ctrl+Shift+R or Cmd+Shift+R) and check your browser's developer console for errors.
- If you are using the file:// protocol, some browsers may block font loading. Try running a local web server.

## Credits
- Inspired by the Matrix digital rain
- Uses [Google Noto Fonts](https://fonts.google.com/noto)

## License
MIT
