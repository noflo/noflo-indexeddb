module.exports = (function(){
  return window.overrideIndexedDB || window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB;
})();
