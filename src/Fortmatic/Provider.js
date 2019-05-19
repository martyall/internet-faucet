"use strict";

var Fortmatic = require('fortmatic');
var Web3 = require('web3');

exports.fortmaticProvider = function () {
    var fm = new Fortmatic('YOUR_API_KEY');
    var provider = new Web3(fm.getProvider());
    return provider;
};
