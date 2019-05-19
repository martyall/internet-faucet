"use strict";

var Fortmatic = require('fortmatic');
var Web3 = require('web3');

exports.fortmaticProvider = function () {
    var fm = new Fortmatic('pk_test_416204DFB20F8E69'); // our api key
    var provider = new Web3(fm.getProvider());
    return provider;
};
