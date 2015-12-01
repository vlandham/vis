
exports.toRad = function toRad(degree) {
  return degree * (Math.PI / 180);
};

exports.removeBreaks = function removeBreaks(text) {
  return text.replace(/(\r\n|\n|\r)/gm,"");
};

exports.textToSentences = function textToSentences(text) {
  return exports.removeBreaks(text).replace(/([.?!])\s*(?=[A-Z])/g, "$1|").split("|");
};

exports.removePunctuation = function removePunctuation(string) {
  return string.replace(/['!"#$%&\\'()\*+,\-\.\/:;<=>?@\[\\\]\^_`{|}~']/g," ").replace(/\s{2,}/g," ");
};

exports.stringToWords = function stringToWords(string) {
  //http://blog.tompawlak.org/split-string-into-tokens-javascript
  return string.match(/\S+/g);
};
