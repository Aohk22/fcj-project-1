const elementResult = document.createElement('div')
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
  dataGeneric['general'] = data['general'];
  dataTypeSpecific['typed'] = data['typed'];

  walkObject(dataGeneric);

  walkObject(dataTypeSpecific);

  return elementResult;
}

function walkObject(obj, depth = 0) {
  for (const key in obj) {
    const tempObj = obj[key];
    if (Object.prototype.toString.call(tempObj) === '[object Object]') {
      // console.log(`object: ${key} - depth: ${depth}`);
      elementResult.appendChild(createHeader(depth + 1, key));
      walkObject(tempObj, depth + 1);
    }
    else if (Object.prototype.toString.call(tempObj) === '[object Array]') {
      // console.log(`object: ${key} - depth: ${depth}`);
      elementResult.appendChild(createHeader(depth + 1, key));
      walkArray(tempObj, depth);
    }
    else if (Object.prototype.toString.call(tempObj) === '[object String]') {
      // console.log(`object: ${key} - depth: ${depth}`);
      elementResult.appendChild(createHeader(depth + 1, key));
      elementResult.appendChild(renderString(tempObj));
    }
  }
}

function walkArray(arr, depth) {
  for (const obj of arr) {
    if (Object.prototype.toString.call(obj) === '[object Object]') {
      walkObject(obj, depth + 1);
    }
    else if (Object.prototype.toString.call(obj) === '[object Array]') {
      walkArray(obj, depth + 1);
    }
    // else if (Object.prototype.toString.call(obj) === '[object String]') {
    //   elementResult.appendChild(renderString(obj + '\n'));
    // }
  }
  // Assume that every other element is also a string.
  //
  if (Object.prototype.toString.call(arr[0]) === '[object String]') {
    const arrContainer = document.createElement('div');
    if (arr.length > 30) {
      arrContainer.setAttribute('class', 'long-arr');
    }
    for (const str of arr) {
      arrContainer.appendChild(renderString(str + '\n'));
    }
    elementResult.appendChild(arrContainer);
  }
}

function renderString(str) {
  const container = document.createElement('span');
  const text = document.createTextNode(str.replace(/\\n/, '\n'));
  if (str.length > 100) {
    container.setAttribute('class', 'long-string');
  }
  container.appendChild(text);
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

