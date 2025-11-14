import { renderResult } from "./util.js";

const resultStatus = document.getElementById('result-status');
const formHash = document.getElementById('form-hash');
const formFile = document.getElementById('form-file');
const result = document.getElementById('result-container');

formHash.addEventListener("submit", (event) => {
  event.preventDefault();

  const hash = formHash.elements["hash"].value.trim();

  if (hash.length == 0) {
    resultStatus.innerHTML = 'No hash selected.';
  } else {
    resultStatus.innerHTML = `Searching for ${hash}...`;

    fetch('/query', {
      method: "POST",
      headers: { "Content-Type": "text/html" },
      body: hash
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
});

formFile.addEventListener("submit", (event) => {
  event.preventDefault();

  const currFiles = formFile.elements["file"].files;

  if (currFiles.length === 0) {
    resultStatus.innerHTML = "No files selected.";
  } else {
    resultStatus.innerHTML = "Analyzing...";

    const file = currFiles[0];

    fetch('/analyze', {
      method: 'POST',
      body: file
    })
      .then((res) => res.json())
      .then((data) => {
        localStorage.setItem('localData', JSON.stringify(data));
        result.innerHTML = "";
        result.appendChild(jsonRenderResult(data));
      })
      .catch((err) => {
        resultStatus.innerHTML = `Error: ${err.detail}`;
      });
  }
});
