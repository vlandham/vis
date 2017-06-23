var path = require("path");
var webpack = require('webpack');

var minimize = process.argv.indexOf('--minimize') === -1 ? false : true;

var ExtractTextPlugin = require("extract-text-webpack-plugin");
var plugins = [];

plugins.push(new ExtractTextPlugin("build/app.css"));

if(minimize) {
  plugins.push(new webpack.optimize.UglifyJsPlugin());
}

module.exports = {
  entry: {
    javascript: './src/main.js'
  },
  output: {
    filename: 'build/app.js'
  },
  debug: true,
  devtool: 'source-map',
  // for modules
  resolve: {
    fallback: [path.join(__dirname, 'node_modules')]
  },
  // same issue, for loaders like babel
  resolveLoader: {
    fallback: [path.join(__dirname, 'node_modules')]
  },
  module: {
    loaders: [
      {
        test: /\.js$/,
        include: /src/,
        loaders: ['babel-loader']
      },
      { test: /\.css$/, loader: 'style-loader!css-loader' },
      {
        test: /\.(ttf|eot|svg|woff(2)?)(\?[a-z0-9]+)?$/,
        exclude: /(node_modules|bower_components)/,
        loader: "file?name=build/[name].[ext]"
        // loader: 'file-loader'
      },
      {
        test: /\.html$/,
        loader: "file?name=build/[name].[ext]"
      },
      {
        test: /\.scss$/,
        loader: ExtractTextPlugin.extract("style","css!sass")
      }
    ]
  },
  plugins: plugins
};
