/**
 * ひらがな・カタカナ → ヘボン式ローマ字（駅名表示用の近似）
 * map.html / index.html から利用
 */
(function (global) {
  function toHiragana(str) {
    if (!str) return '';
    return String(str).replace(/[\u30A1-\u30F6]/g, function (c) {
      return String.fromCharCode(c.charCodeAt(0) - 0x60);
    });
  }

  var YOON = {
    きゃ: 'kya', きゅ: 'kyu', きょ: 'kyo', ぎゃ: 'gya', ぎゅ: 'gyu', ぎょ: 'gyo',
    しゃ: 'sha', しゅ: 'shu', しょ: 'sho', じゃ: 'ja', じゅ: 'ju', じょ: 'jo',
    ちゃ: 'cha', ちゅ: 'chu', ちょ: 'cho', ぢゃ: 'ja', ぢゅ: 'ju', ぢょ: 'jo',
    にゃ: 'nya', にゅ: 'nyu', にょ: 'nyo',
    ひゃ: 'hya', ひゅ: 'hyu', ひょ: 'hyo', びゃ: 'bya', びゅ: 'byu', びょ: 'byo',
    ぴゃ: 'pya', ぴゅ: 'pyu', ぴょ: 'pyo',
    みゃ: 'mya', みゅ: 'myu', みょ: 'myo',
    りゃ: 'rya', りゅ: 'ryu', りょ: 'ryo',
    てぃ: 'ti', てゅ: 'tyu', とぅ: 'tu', とぁ: 'twa', とぃ: 'twi', とぇ: 'twe', とぉ: 'two',
    でぃ: 'di', でゅ: 'dyu', でぇ: 'dye',
    ふぁ: 'fa', ふぃ: 'fi', ふぇ: 'fe', ふぉ: 'fo',
    うぃ: 'wi', うぇ: 'we', うぉ: 'wo', いぇ: 'ye', ゔぁ: 'va', ゔぃ: 'vi', ゔ: 'vu', ゔぇ: 've', ゔぉ: 'vo'
  };

  var ROM = {
    あ: 'a', い: 'i', う: 'u', え: 'e', お: 'o',
    か: 'ka', き: 'ki', く: 'ku', け: 'ke', こ: 'ko',
    が: 'ga', ぎ: 'gi', ぐ: 'gu', げ: 'ge', ご: 'go',
    さ: 'sa', し: 'shi', す: 'su', せ: 'se', そ: 'so',
    ざ: 'za', じ: 'ji', ず: 'zu', ぜ: 'ze', ぞ: 'zo',
    た: 'ta', ち: 'chi', つ: 'tsu', て: 'te', と: 'to',
    だ: 'da', ぢ: 'ji', づ: 'zu', で: 'de', ど: 'do',
    な: 'na', に: 'ni', ぬ: 'nu', ね: 'ne', の: 'no',
    は: 'ha', ひ: 'hi', ふ: 'fu', へ: 'he', ほ: 'ho',
    ば: 'ba', び: 'bi', ぶ: 'bu', べ: 'be', ぼ: 'bo',
    ぱ: 'pa', ぴ: 'pi', ぷ: 'pu', ぺ: 'pe', ぽ: 'po',
    ま: 'ma', み: 'mi', む: 'mu', め: 'me', も: 'mo',
    や: 'ya', ゆ: 'yu', よ: 'yo',
    ら: 'ra', り: 'ri', る: 'ru', れ: 're', ろ: 'ro',
    わ: 'wa', ゐ: 'i', ゑ: 'e', を: 'o',
    ぁ: 'a', ぃ: 'i', ぅ: 'u', ぇ: 'e', ぉ: 'o', ゃ: 'ya', ゅ: 'yu', ょ: 'yo', ゎ: 'wa'
  };

  function nRom(str, i) {
    if (i >= str.length) return 'n';
    var c = str[i];
    if ('まみむめもばびぶべぼぱぴぷぺぽ'.indexOf(c) >= 0) return 'm';
    return 'n';
  }

  function lastVowel(rom) {
    var m = String(rom).match(/([aeiou])[^aeiou]*$/i);
    return m ? m[1].toLowerCase() : '';
  }

  /** 位置 i から1モーラ分（っ・ん・拗音はここで扱わない想定） */
  function consumeCore(str, i, allowN) {
    var len = str.length;
    if (i >= len) return { out: '', ni: i };
    var c = str[i];
    if (c === 'ん') {
      if (!allowN) return { out: '', ni: i };
      return { out: nRom(str, i + 1), ni: i + 1 };
    }
    if (i + 1 < len) {
      var pair = str.slice(i, i + 2);
      if (YOON[pair]) return { out: YOON[pair], ni: i + 2 };
    }
    if (ROM[c]) return { out: ROM[c], ni: i + 1 };
    return { out: '', ni: i + 1 };
  }

  function kanaToRomaji(input) {
    var str = toHiragana(input || '');
    var i = 0;
    var len = str.length;
    var out = '';
    while (i < len) {
      var c = str[i];
      if (c === 'っ') {
        if (i + 1 >= len) {
          i++;
          continue;
        }
        var nx = consumeCore(str, i + 1, true);
        if (nx.out && /^[a-z]/i.test(nx.out)) {
          out += nx.out.charAt(0) + nx.out;
          i = nx.ni;
          while (i < len && str[i] === 'ー') {
            var lv0 = lastVowel(out);
            if (lv0) out += lv0;
            i++;
          }
          continue;
        }
        i++;
        continue;
      }
      var r = consumeCore(str, i, true);
      if (r.out) {
        out += r.out;
        i = r.ni;
        while (i < len && str[i] === 'ー') {
          var lv = lastVowel(out);
          if (lv) out += lv;
          i++;
        }
        continue;
      }
      if (c === 'ー') {
        var v = lastVowel(out);
        if (v) out += v;
        i++;
        continue;
      }
      i++;
    }
    return out;
  }

  function capitalizeSegment(seg) {
    seg = String(seg || '').toLowerCase();
    if (!seg) return '';
    return seg.charAt(0).toUpperCase() + seg.slice(1);
  }

  /** JR駅看板風：先頭大文字（ハイフン区切りは各セグメントをタイトルケース） */
  function capitalizeStationEn(romaji) {
    if (!romaji) return '';
    return romaji.split('-').map(capitalizeSegment).join('-');
  }

  function stationRomajiFromReading(reading, explicitEn) {
    if (explicitEn) return String(explicitEn);
    var h = toHiragana(reading || '');
    if (!h) return '';
    var joined = h.split('・').map(function (part) {
      return kanaToRomaji(part);
    }).join('-');
    return joined;
  }

  function escHtml(t) {
    if (t == null) return '';
    return String(t)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  global.KanaRomaji = {
    toHiragana: toHiragana,
    kanaToRomaji: kanaToRomaji,
    capitalizeStationEn: capitalizeStationEn,
    stationRomajiFromReading: stationRomajiFromReading,
    escHtml: escHtml
  };
})(typeof window !== 'undefined' ? window : this);
