// Extract train line data from index.html into JSON for iOS app
const fs = require('fs');
const html = fs.readFileSync('index.html', 'utf8');

// Extract LINES array
const linesMatch = html.match(/var LINES = \[([\s\S]*?)\];\s*\n/);
if (!linesMatch) { console.error('LINES not found'); process.exit(1); }

// Extract GROUPS array
const groupsMatch = html.match(/var GROUPS = \[([\s\S]*?)\];\s*\n/);
if (!groupsMatch) { console.error('GROUPS not found'); process.exit(1); }

// Helper: strip R() ruby markup to plain text
function stripR(text) {
  // R('漢字','ふりがな') -> 漢字
  return text.replace(/R\('([^']*)',\s*'[^']*'\)/g, '$1').replace(/'/g, '').replace(/\+/g, '');
}

function stripRForReading(text) {
  // R('漢字','ふりがな') -> ふりがな
  return text.replace(/R\('([^']*)',\s*'([^']*)'\)/g, '$2').replace(/'/g, '').replace(/\+/g, '');
}

// Parse LINES
const linesStr = linesMatch[1];
const lines = [];
const lineRegex = /\{\s*id:'([^']*)'(?:,\s*isLoop:(true))?(?:,\s*group:'([^']*)')?\s*(?:,\s*isLoop:(true))?\s*(?:,\s*group:'([^']*)')?\s*,\s*nameHtml:(.*?),\s*companyHtml:(.*?),\s*color:'([^']*)',\s*icon:'([^']*)',\s*stations:\[([\s\S]*?)\]\s*\}/g;

// More robust regex approach - parse each line object
const lineBlocks = linesStr.split(/\},\s*\{/).map((s, i, arr) => {
  if (i === 0) s = s.replace(/^\s*\{/, '');
  if (i === arr.length - 1) s = s.replace(/\}\s*$/, '');
  return s;
});

for (const block of lineBlocks) {
  const id = (block.match(/id:'([^']*)'/)||[])[1];
  const isLoop = /isLoop:\s*true/.test(block);
  const group = (block.match(/group:'([^']*)'/)||[])[1];
  const color = (block.match(/color:'([^']*)'/)||[])[1];
  const icon = (block.match(/icon:'([^']*)'/)||[])[1];

  // Extract nameHtml
  const nameMatch = block.match(/nameHtml:(.*?)(?:,\s*companyHtml)/s);
  let name = '';
  let nameReading = '';
  if (nameMatch) {
    name = stripR(nameMatch[1].trim().replace(/,\s*$/, ''));
    nameReading = stripRForReading(nameMatch[1].trim().replace(/,\s*$/, ''));
  }

  const companyMatch = block.match(/companyHtml:(.*?)(?:,\s*color)/s);
  let company = '';
  if (companyMatch) {
    company = stripR(companyMatch[1].trim().replace(/,\s*$/, ''));
  }

  // Extract stations
  const stationsMatch = block.match(/stations:\[([\s\S]*)\]/);
  const stations = [];
  if (stationsMatch) {
    const stRe = /\['([^']*)',\s*'([^']*)'\s*(?:,\s*'([^']*)')?\]/g;
    let m;
    while ((m = stRe.exec(stationsMatch[1])) !== null) {
      const st = { name: m[1], reading: m[2] };
      if (m[3]) st.romaji = m[3];
      stations.push(st);
    }
  }

  if (id) {
    lines.push({ id, group, name, nameReading, company, color, icon, isLoop, stations });
  }
}

// Parse GROUPS
const groupsStr = groupsMatch[1];
const groups = [];
const groupBlocks = groupsStr.split(/\},\s*\{/).map((s, i, arr) => {
  if (i === 0) s = s.replace(/^\s*\{/, '');
  if (i === arr.length - 1) s = s.replace(/\}\s*$/, '');
  return s;
});

for (const block of groupBlocks) {
  const id = (block.match(/id:'([^']*)'/)||[])[1];
  const color = (block.match(/color:'([^']*)'/)||[])[1];
  const region = (block.match(/region:'([^']*)'/)||[])[1];
  const labelMatch = block.match(/label:(.*?)(?:,\s*color)/s);
  let label = '';
  if (labelMatch) {
    label = stripR(labelMatch[1].trim().replace(/,\s*$/, ''));
  }
  if (id) groups.push({ id, label, color, region });
}

const data = { groups, lines };
fs.writeFileSync('TrainQuiz/TrainQuiz/train_data.json', JSON.stringify(data, null, 2), 'utf8');
console.log(`Extracted ${lines.length} lines, ${groups.length} groups`);
console.log('Sample line:', JSON.stringify(lines[0], null, 2));
