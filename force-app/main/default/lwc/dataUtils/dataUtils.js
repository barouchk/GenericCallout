export const isEmpty = (data) => {
    const typeOfData = typeof data;
    if (typeOfData === "number" || typeOfData === "boolean") {
        return false;
    }
    if (typeOfData === "undefined" || data === null) {
        return true;
    }
    if (typeOfData !== "undefined") {
        if (typeOfData === "object") {
            return Object.keys(data).length === 0;
        }
        return data.length === 0;
    }

    let count = 0;
    for (let i in data) {
        if (data.hasOwnProperty(i)) {
            count++;
        }
    }

    return count === 0;
};

// Quick and dirty way of deep cloning an object. 
// Only work with Number and String and Object literal without function or Symbol properties. 
export const deepClone = ( obj ) => {
    return JSON.parse( JSON.stringify( obj ));
}

export const shallowClone = ( obj ) => {
    return Object.assign({}, obj);
}

/* example :
const obj = {
  selector: { to: { val: 'val to select' } },
  target: [1, 2, { a: 'test' }],
};
getValueByStringPath(obj, 'selector.to.val', 'target[0]', 'target[2].a');
// ['val to select', 1, 'test']*/

export const getValueByStringPath = (from, ...selectors) =>
  [...selectors].map(s =>
    s
      .replace(/\[([^\[\]]*)\]/g, '.$1.')
      .split('.')
      .filter(t => t !== '')
      .reduce((prev, cur) => prev && prev[cur], from)
  );