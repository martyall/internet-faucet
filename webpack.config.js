"use strict";

var fs = require("fs");
var path = require("path");
var webpack = require("webpack");
var HtmlWebpackPlugin = require("html-webpack-plugin");
var UglifyJSPlugin = require("uglifyjs-webpack-plugin");
var MiniCssExtractPlugin = require("mini-css-extract-plugin");


var IS_PROD = process.env.NODE_ENV === "production";
console.log(IS_PROD ? "Making PRODUCTION build" : "Making DEVELOPMENT build");

var checkDeps = function () {
  var deps = [
    { path: "./bower_components", cmd: "bower i" },
    { path: "./output", cmd: "make build-purs" },
  ];
  var commands = [];
  for (var i = 0; i < deps.length; i++) {
    if (!fs.existsSync(deps[i].path)) {
      commands.push(deps[i].cmd);
    }
  }
  if (commands.length > 0) {
    console.error("Looks like you need to run `" + commands.join(" && ") + " ` first");
    process.exit(1);
    return;
  }
};

var nodeEnvPlugin = new webpack.DefinePlugin({
  "process.env.NODE_ENV": JSON.stringify(process.env.NODE_ENV),
});

var minifyJSPlugin = new UglifyJSPlugin({
  sourceMap: false,
  uglifyOptions: {
    parallel: true,
    sourceMap: false,
    compress: {
      warnings: false,
      comparisons: false, // don"t optimize comparisons https://github.com/mapbox/mapbox-gl-js/issues/4359
    },
    ecma: 6,
  }
});

var commonPlugins = [nodeEnvPlugin].concat(IS_PROD ? [ minifyJSPlugin ] : []);

module.exports = function(/*env*/) {
  checkDeps();
  return {
    mode: IS_PROD ? "production" : "development",
    entry: {
      "styles": "./frontend/styles/index.scss",
      "index": "./frontend/index.js",
    },
    output: {
      path: path.join(__dirname, "frontend/dist"),
      filename: IS_PROD ? "[name].[hash].js": "[name].js",
    },
    devtool: IS_PROD ? false : "eval",
    devServer: {
      contentBase: path.join(__dirname, "frontend/dist"),
      disableHostCheck: true,
      // noInfo: true, // only errors & warns on hot reload
    },
    watch: false,
    module: {
      rules: [
        {
          test: /\.(css|sass|scss)$/,
          use: [
            IS_PROD ? MiniCssExtractPlugin.loader : "style-loader",
            "css-loader",
            {
              loader: "postcss-loader",
              options: {
                plugins: function () { return IS_PROD ? [require("autoprefixer"), require("cssnano")] : []; }
              }
            },
            "sass-loader"
          ],
        }
      ]
    },
    plugins: commonPlugins.concat([
      new HtmlWebpackPlugin({
        inject: true,
        title: "App",
        chunks: ["index"],
        template: "./frontend/index.ejs",
        classes: "u-backgroundColor-blackish",
        filename: "index.html",
      }),
      new webpack.DefinePlugin({
        "process.env.API_BASE_URL": JSON.stringify(process.env.API_BASE_URL),
      }),
      new MiniCssExtractPlugin({
        filename: IS_PROD ? "[name].[hash].css": "[name].css",
        chunkFilename: IS_PROD ? "[id].[hash].css": "[id].css",
      })
    ])
  };

};

