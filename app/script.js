const form = document.getElementById('form');
const result = document.getElementById('result-container');
const fileItem = document.getElementById('fileItem');

function syntaxHighlight(json) {
  if (typeof json != 'string') {
    json = JSON.stringify(json, undefined, 2);
  }
  json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(?:\s*:)?|\b(true|false|null)\b|-?\d+\.?\d*(?:[eE][+\-]?\d+)?)/g, function (match) {
    let cls = 'json-number';
    if (/^"/.test(match)) {
      if (/:$/.test(match)) {
        cls = 'json-key';
      } else {
        cls = 'json-string';
      }
    } else if (/true|false/.test(match)) {
      cls = 'json-boolean';
    } else if (/null/.test(match)) {
      cls = 'json-null';
    }
    return '<span class="' + cls + '">' + match + '</span>';
  });
}

form.addEventListener('submit', async (e) => {
  const formData = new FormData();

  e.preventDefault();

  if (!fileItem) return alert("Please select a file.");
  formData.append('raw', fileItem.files[0]);

  result.innerHTML = "<em>Analyzing...</em>";

  console.log('Fetching API route...');

  fetch('/analyze', { method: 'POST', body: formData })
    .then((res) => res.json())
    .then((data) => {
      // var spanHash = document.createElement('span');
      // var spanType = document.createElement('span');
      var spanStrs = document.createElement('span');
      var spanDcmp = document.createElement('span');
      var spanStrsInner = document.createElement('span');
      var spanDcmpInner = document.createElement('span');
      var logText = new String();
      var key;

      // spanHash.setAttribute('id', 'span-hashes');
      // spanType.setAttribute('id', 'span-file-type');
      spanStrs.setAttribute('id', 'span-strings');
      spanDcmp.setAttribute('id', 'span-decompile');
      spanStrsInner.setAttribute('id', 'span-strings-inner');
      spanDcmpInner.setAttribute('id', 'span-decompile-inner');

      // spanHash.innerHTML += '<h3>Hashes</h3>';
      // for (var hashType in data['general']['hashes']) {
      //   spanHash.appendChild(
      //     document.createTextNode(`${hashType}: ${data['general']['hashes'][hashType]}\n`));
      // }
      //
      // spanType.innerHTML += '<h3>File Type</h3>';
      // spanType.appendChild(document.createTextNode(`magic: ${data['general']['fileType']['magic']}\n`));
      // spanType.appendChild(document.createTextNode('trid:\n'));
      // for (var tridEntry of data['general']['fileType']['trid']) {
      //   spanType.appendChild(document.createTextNode(`${tridEntry}\n`));
      // }

      for (var string of data['general']['strings']) {
        spanStrsInner.appendChild(document.createTextNode(`${string}\n`));
      }
      spanStrs.innerHTML += '<h3>Strings</h3>';
      spanStrs.appendChild(spanStrsInner);

      spanDcmp.innerHTML += '<h3>Decompilation (Ghidra)</h3>';
      spanDcmpInner.appendChild(
        document.createTextNode(`${data['general']['decomp'].replace(/\\n/g, '\n')}\n`));
      spanDcmp.appendChild(spanDcmpInner);

      result.innerHTML = '';
      result.innerHTML += '<h3>General</h3>';
      result.innerHTML += syntaxHighlight(data['general']['hashes']);
      result.innerHTML += syntaxHighlight(data['general']['fileType']);
      result.innerHTML += '<h3>Type Specific</h3>';
      for (var key of Object.keys(data).slice(1)) {
        result.innerHTML += syntaxHighlight(data[key]);
      }
      result.appendChild(spanStrs);
      result.appendChild(spanDcmp);

    })
    .catch((err) => { 
      console.log(err);
      result.innerHTML = `<strong>Error:</strong> ${err.detail}`;
    });
});
