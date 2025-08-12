// Notebook Extension to allow pari-gp Mode on Jupyter

define([
  'base/js/namespace',
  './gp'
], function (Jupyter) {
  "use strict";

  return {
    load_ipython_extension: function () {
      console.log('Loading pari-gp Mode...');
    }
  };

});
