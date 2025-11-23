import { renderResult } from "./util.js";

const resultStatus = document.getElementById('result-status');
const formHash = document.getElementById('form-hash');
const formFile = document.getElementById('form-file');
const result = document.getElementById('result-container');

document.getElementById('files').onchange = function () {
	document.getElementById('file-name').innerHTML = this.value.replace(/.*[\/\\]/,'');
};

function callAPI(path, data) {
  fetch(path, {
    method: "POST",
    body: data
  })
    .then(async (res) => {
      if (res.ok) return res.json();
      throw new Error(await res.text());
    })
    .then((resJson) => {
      localStorage.setItem('localData', JSON.stringify(resJson));
      result.replaceChildren(renderResult(resJson));
    })
    .catch((err) => {
      resultStatus.innerHTML = `${err}`;
    });
}

formHash.addEventListener("submit", (event) => {
  event.preventDefault();

  const hash = formHash.elements["hash"].value.trim();

  if (hash.length == 0) {
    resultStatus.innerHTML = 'No hash selected.';
  } else {
    resultStatus.innerHTML = `Searching for ${hash}...`;

    callAPI('/query', hash);
  }
});

formFile.addEventListener("submit", (event) => {
  event.preventDefault();

  const currFiles = formFile.elements["file"].files;

  if (currFiles.length === 0) {
    resultStatus.innerHTML = "No files selected.";
  } else {
    resultStatus.innerHTML = "Analyzing...";

    const file = currFiles[0];

    callAPI('/analyze', file);
  }
});
