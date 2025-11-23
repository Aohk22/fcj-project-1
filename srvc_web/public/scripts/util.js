const elementResult = document.createElement('section')
elementResult.setAttribute('class', 'parsed-json');

export function renderResult(data) {
  const dataOrdered = Object.keys(data).sort().reduce(
    (obj, key) => {
      obj[key] = data[key];
      return obj;
    },
    {}
  );

  const dataGeneric = new Object();
  const dataTypeSpecific = new Object();

  dataGeneric['general'] = new Object();
  for (const key of ['hashes', 'fileType', 'strings', 'decomp']) {
    dataGeneric['general'][key] = data['general'][key];
  }
  dataTypeSpecific['typed'] = data['typed'];

  walkObject(dataGeneric);

  walkObject(dataTypeSpecific);

  return elementResult;
}

function walkObject(obj, depth = 0) {
  for (const key in obj) {
    const tempObj = obj[key];
    const typeObj = Object.prototype.toString.call(tempObj);
    if (typeObj === '[object Object]') {
      // console.log(`object: ${key} - depth: ${depth}`);
      elementResult.appendChild(createHeader(depth + 1, key));
      walkObject(tempObj, depth + 1);
    }
    else if (typeObj === '[object Array]') {
      // console.log(`object: ${key} - depth: ${depth}`);
      elementResult.appendChild(createHeader(depth + 1, key));
      walkArray(tempObj, depth);
    }
    else if (typeObj === '[object String]' || typeObj === '[object Number]') {
      // console.log(`object: ${key} - depth: ${depth}`);
      elementResult.appendChild(createHeader(depth + 1, key));
      elementResult.appendChild(renderString(tempObj));
    }
  }
}

function walkArray(arr, depth) {
  for (const obj of arr) {
    const typeObj = Object.prototype.toString.call(obj);
    if (typeObj === '[object Array]') {
      walkArray(obj, depth + 1);
    }
    // else if (typeObj === '[object Object]') {
    //   walkObject(obj, depth + 1);
    // }
    // else if (typeObj === '[object String]') {
    //   elementResult.appendChild(renderString(obj + '\n'));
    // }
  }

  // Assume that every other element is also the same - fair assumption.
  const firstObjType = Object.prototype.toString.call(arr[0]);
  if (firstObjType === '[object String]' || firstObjType === '[object Number]') {
    const arrContainer = document.createElement('span');
    arrContainer.setAttribute('class', 'array-string');
    for (const str of arr) {
      arrContainer.appendChild(renderString(str));
    }
    elementResult.appendChild(arrContainer);
  }
  // Arrays of objects should be parsed differently otherwise the page gets very long.
  else if (firstObjType === '[object Object]') {
    const arrContainer = document.createElement('span');
    arrContainer.setAttribute('class', 'array-object');
    for (const obj of arr) {
      arrContainer.appendChild(renderObject(obj));
    }
    elementResult.appendChild(arrContainer);
  }
}

function renderString(str) {
  if (Object.prototype.toString.call(str) === '[object Number]') {
    str = str.toString(16);
  }
  const container = document.createElement('span');
  const text = document.createTextNode(str.replace(/\\n/g, '\n').trim());
  container.setAttribute('class', 'string');
  if (str.length > 100) container.setAttribute('class', 'string-long');
  container.appendChild(text);
  return container;
}

// Assume object values are either string or number.
function renderObject(obj) {
  const container = document.createElement('span');
  container.setAttribute('class', 'object');
  for (const key in obj) {
    container.appendChild(renderString(`${key}:\t${obj[key]}`));
  }
  return container;
}

function createHeader(depth, key) {
  const header = document.createElement(`h${depth+1}`);
  const text = document.createTextNode(headerize(key));
  header.appendChild(text);
  return header;
}

function headerize(text) {
  var splitText = text.split(/(?=[A-Z])/);
  splitText[0] = capitalizeFirstLetter(splitText[0]);
  return splitText.join(" ");
}

function capitalizeFirstLetter(val) {
    return String(val).charAt(0).toUpperCase() + String(val).slice(1);
}

