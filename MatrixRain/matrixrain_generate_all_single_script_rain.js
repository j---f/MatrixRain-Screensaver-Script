// Generates standalone MatrixRain HTML files for each script in the scripts array
// Usage: node matrixrain_generate_all_single_script_rain.js

const fs = require('fs');
const path = require('path');

// Scripts array, must match MatrixRain.html
const scripts = [
  ["Hebrew", "'Noto Sans Hebrew', 'Noto Sans', sans-serif", [[0x0590, 0x05FF]]],
  ["Yiddish", "'Noto Sans Hebrew', 'Noto Sans', sans-serif", [[0x0590, 0x05FF]]],
  ["Farsi", "'Noto Nastaliq Urdu', 'Amiri', 'Noto Sans Arabic', 'Noto Sans', sans-serif", [[0x0600, 0x06FF], [0x0750, 0x077F], [0x08A0, 0x08FF]]],
  ["Avestan", "'Noto Sans Avestan', 'Noto Sans', sans-serif", [[0x10B00, 0x10B3F]]],
  ["Amazigh", "'Noto Sans Tifinagh', sans-serif", [[0x2D30, 0x2D7F]]],
  ["Turkish", "Noto Sans, sans-serif", [[0x0021, 0x024F]]],
  ["Azeri", "Noto Sans, sans-serif", [[0x0021, 0x024F]]],
  ["Armenian", "'Noto Sans Armenian', sans-serif", [[0x0530, 0x058F]]],
  ["Georgian", "'Noto Sans Georgian', sans-serif", [[0x10A0, 0x10FF]]],
  ["Abkhaz", "Noto Sans, sans-serif", [[0x0400, 0x04FF]]],
  ["Ukrainian", "Noto Sans, sans-serif", [[0x0400, 0x04FF]]],
  ["Nenets", "Noto Sans, sans-serif", [[0x0400, 0x04FF]]],
  ["Lao", "'Noto Sans Lao', sans-serif", [[0x0E80, 0x0EFF]]],
  ["Thai", "'Noto Sans Thai', sans-serif", [[0x0E00, 0x0E7F]]],
  ["Khmer", "'Noto Sans Khmer', sans-serif", [[0x1780, 0x17FF]]],
  ["Burmese", "'Noto Sans Myanmar', sans-serif", [[0x1000, 0x109F]]],
  ["Tamil", "'Noto Sans Tamil', sans-serif", [[0x0B80, 0x0BFF]]],
  ["Icelandic", "Noto Sans, sans-serif", [[0x0021, 0x024F]]],
  ["Faroese", "Noto Sans, sans-serif", [[0x0021, 0x024F]]],
  ["Osage", "'Noto Sans Osage', sans-serif", [[0x104B0, 0x104FF]]],
  ["Inuit", "'Noto Sans Canadian Aboriginal', sans-serif", [[0x1400, 0x167F]]],
  ["Nepalese", "'Noto Sans Devanagari', sans-serif", [[0x0900, 0x097F]]],
  ["Sanskrit", "'Noto Sans Devanagari', sans-serif", [[0x0900, 0x097F]]],
  ["Bhutanese", "'Noto Sans Tibetan', sans-serif", [[0x0F00, 0x0FFF]]],
  ["French", "Noto Sans, sans-serif", [[0x0021, 0x024F]]],
  ["Italian", "Noto Sans, sans-serif", [[0x0021, 0x024F]]],
  ["German", "Noto Sans, sans-serif", [[0x0021, 0x024F]]],
  ["Pashto", "'Noto Sans Arabic', 'Noto Nastaliq Urdu', 'Amiri', sans-serif", [[0x0600, 0x06FF], [0x0750, 0x077F], [0x08A0, 0x08FF]]],
  ["Dari", "'Noto Sans Arabic', 'Noto Nastaliq Urdu', sans-serif", [[0x0600, 0x06FF]]],
  ["Urdu", "'Noto Nastaliq Urdu', 'Noto Sans Arabic', sans-serif", [[0x0600, 0x06FF]]],
  ["Klingon", "'KlingonPiqadPUA', 'KlingonPiqadHaSta', 'KlingonPiqadMandel', 'KlingonPiqadVaHbo', sans-serif", [[0xF8D0, 0xF8FF]]],
  ["Cardassian", "'CardassianStd', sans-serif", [[0x0021, 0x007E]]],
  ["Sundanese", "'Noto Sans Sundanese', sans-serif", [[0x1B80, 0x1BBF]]],
  ["Braille", "'Noto Sans Braille', sans-serif", [[0x2800, 0x28FF]]],
  ["Latin", "Noto Sans, sans-serif", [[0x0021, 0x024F]]],
  ["Greek", "Noto Sans, sans-serif", [[0x0370, 0x03FF]]],
  ["Cyrillic", "Noto Sans, sans-serif", [[0x0400, 0x04FF]]],
  ["Armenian", "'Noto Sans Armenian', sans-serif", [[0x0530, 0x058F]]],
  ["Georgian", "'Noto Sans Georgian', sans-serif", [[0x10A0, 0x10FF]]],
  ["Ethiopic", "'Noto Sans Ethiopic', sans-serif", [[0x1200, 0x137F]]],
  ["Tifinagh", "'Noto Sans Tifinagh', sans-serif", [[0x2D30, 0x2D7F]]],
  ["Hebrew", "'Noto Sans Hebrew', sans-serif", [[0x0590, 0x05FF]]],
  ["Arabic", "'Noto Sans Arabic', sans-serif", [[0x0600, 0x06FF]]],
  ["Bengali", "'Noto Sans Bengali', sans-serif", [[0x0980, 0x09FF]]],
  ["Devanagari", "'Noto Sans Devanagari', sans-serif", [[0x0900, 0x097F]]],
  ["Gurmukhi", "'Noto Sans Gurmukhi', sans-serif", [[0x0A00, 0x0A7F]]],
  ["Gujarati", "'Noto Sans Gujarati', sans-serif", [[0x0A80, 0x0AFF]]],
  ["Tamil", "'Noto Sans Tamil', sans-serif", [[0x0B80, 0x0BFF]]],
  ["Telugu", "'Noto Sans Telugu', sans-serif", [[0x0C00, 0x0C7F]]],
  ["Kannada", "'Noto Sans Kannada', sans-serif", [[0x0C80, 0x0CFF]]],
  ["Malayalam", "'Noto Sans Malayalam', sans-serif", [[0x0D00, 0x0D7F]]],
  ["Oriya", "'Noto Sans Oriya', sans-serif", [[0x0B00, 0x0B7F]]],
  ["Sinhala", "'Noto Sans Sinhala', sans-serif", [[0x0D80, 0x0DFF]]],
  ["Thai", "'Noto Sans Thai', sans-serif", [[0x0E00, 0x0E7F]]],
  ["Lao", "'Noto Sans Lao', sans-serif", [[0x0E80, 0x0EFF]]],
  ["Cherokee", "'Noto Sans Cherokee', sans-serif", [[0x13A0, 0x13FF]]],
  ["Canadian Aboriginal", "'Noto Sans Canadian Aboriginal', sans-serif", [[0x1400, 0x167F]]],
  ["Mongolian", "'Noto Sans Mongolian', sans-serif", [[0x1800, 0x18AF]]],
  ["Glagolitic", "'Noto Sans Glagolitic', sans-serif", [[0x2C00, 0x2C5F]]],
  ["Runic", "'Noto Sans Runic', sans-serif", [[0x16A0, 0x16FF]]],
  ["Ogham", "'Noto Sans Ogham', sans-serif", [[0x1680, 0x169F]]],
  ["Hiragana", "Noto Sans JP, 'Hiragino Sans', 'Meiryo', sans-serif", [[0x3040, 0x309F]]],
  ["Katakana", "Noto Sans JP, 'Hiragino Sans', 'Meiryo', sans-serif", [[0x30A0, 0x30FF]]],
  ["CJK", "Noto Sans SC, Noto Sans TC, Noto Sans JP, Noto Sans KR, sans-serif", [[0x4E00, 0x9FFF]]],
  ["Korean Hangul", "Noto Sans KR, 'Malgun Gothic', 'Apple SD Gothic Neo', sans-serif", [[0xAC00, 0xD7AF]]],
];

function getCharsForScript(ranges) {
  const chars = [];
  ranges.forEach(([start, end]) => {
    for (let code = start; code <= end; code++) {
      const char = String.fromCharCode(code);
      if (/\s/.test(char)) continue;
      chars.push(char);
    }
  });
  return chars;
}

// Template for single-script MatrixRain
function makeHTML(scriptName, font, chars) {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Matrix Rain - ${scriptName}</title>
  <style>
    html, body { width: 100vw; height: 100vh; margin: 0; padding: 0; background: black; overflow: hidden; }
    canvas { display: block; width: 100vw; height: 100vh; background: black; }
    @font-face {
      font-family: 'KlingonPiqadPUA';
      src: url('Klingon-pIqaD-PUA.ttf') format('truetype');
      font-display: swap;
    }
    @font-face {
      font-family: 'CardassianStd';
      src: url('CARDAS-1.TTF') format('truetype');
      font-display: swap;
    }
  </style>
</head>
<body>
<canvas id="matrix"></canvas>
<script>
const fontSize = 26;
let canvas = document.getElementById('matrix');
let ctx = canvas.getContext('2d');
let width = window.innerWidth;
let height = window.innerHeight;
canvas.width = width;
canvas.height = height;
let columns = Math.floor(width / fontSize);
let drops = Array(columns).fill(1);
const chars = ${JSON.stringify(chars)};
const font = ${JSON.stringify(font)};
function draw() {
  ctx.fillStyle = 'rgba(0, 0, 0, 0.05)';
  ctx.fillRect(0, 0, width, height);
  for (let i = 0; i < columns; i++) {
    ctx.font = fontSize + "px " + font;
    ctx.fillStyle = "#0F0";
    let text = chars[Math.floor(Math.random() * chars.length)];
    ctx.fillText(text, i * fontSize, drops[i] * fontSize);
    if (drops[i] * fontSize > height && Math.random() > 0.975) {
      drops[i] = 0;
    }
    drops[i]++;
  }
}
setInterval(draw, 70);
window.addEventListener('resize', () => {
  width = window.innerWidth;
  height = window.innerHeight;
  canvas.width = width;
  canvas.height = height;
  columns = Math.floor(width / fontSize);
  drops = Array(columns).fill(1);
});
</script>
</body>
</html>`;
}

for (const [name, font, ranges] of scripts) {
  const chars = getCharsForScript(ranges).filter(ch => ch.trim() !== '');
  const html = makeHTML(name, font, chars);
  const fname = `matrixrain_${name.toLowerCase().replace(/[^a-z0-9]+/g, '_')}.html`;
  fs.writeFileSync(fname, html);
  console.log('Wrote', fname);
}
