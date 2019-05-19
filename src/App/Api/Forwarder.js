"use strict";

var BigNumber = require('0x.js').BigNumber;
var ContractWrappers = require('0x.js').ContractWrappers;
var MetamaskSubprovider = require('@0x/subproviders').MetamaskSubprovider;
var FEE_RECIPIENT = 0x0000000000000000000000000000000000000000;
var FEE_PERCENTAGE = 0;

exports.buyItem_ = function (order) {
  return function(onSuccess, onerror) {
    var provider = new MetamaskSubprovider(window.web3.eth.currentProvider); //replace with fortmatic
    window.web3.eth.net.getId().then(function (networkId) {
      return window.web3.eth.getAccounts().then(function(accs) {
        var taker = accs[0];
        var formattedOrder = {
          exchangeAddress: order.exchangeAddress,
          expirationTimeSeconds: new BigNumber(order.expirationTimeSeconds),
          feeRecipientAddress: order.feeRecipientAddress,
          makerAddress: order.makerAddress,
          makerAssetAmount: new BigNumber(order.makerAssetAmount),
          makerAssetData: order.makerAssetData,
          makerFee: new BigNumber(order.makerFee),
          salt: new BigNumber(order.salt),
          senderAddress: order.senderAddress,
          signature: order.signature,
          takerAddress: order.takerAddress,
          takerAssetAmount: new BigNumber(order.takerAssetAmount),
          takerAssetData: order.takerAssetData,
          takerFee: new BigNumber(order.takerFee),
        };
        var forwarder = new ContractWrappers(provider, { networkId: networkId }).forwarder;
        return forwarder.marketBuyOrdersWithEthAsync(
          [formattedOrder],
          formattedOrder.makerAssetAmount,
          taker,
          formattedOrder.takerAssetAmount.plus(
            formattedOrder.takerAssetAmount.multipliedBy(FEE_PERCENTAGE)
          ),
          [],
          FEE_PERCENTAGE,
          FEE_RECIPIENT
        );
      });
    })
    .then(function(txHash) {
      onSuccess(txHash)
    }, function(err) {
      onerror(err);
    })
    return function(cancelError, onCancelFail, onCancelSuccess){
      onCancelSuccess();
    };
  };
};
