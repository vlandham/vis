var path = require("path");
var webpack = require('webpack');

var minimize = process.argv.indexOf('--minimize') === -1 ? false : true;

var ExtractTextPlugin = require("extract-text-webpack-plugin");
var plugins = [];

plugins.push(new ExtractTextPlugin("app.css"));

if(minimize) {
  plugins.push(new webpack.optimize.UglifyJsPlugin());
}


module.exports = {
  entry: {
    javascript: './src/main.js',
    html: './src/index.html'
  },
  output: {
    filename: 'bundle.js'
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
        loaders: ['babel?presets[]=es2015&plugins[]=transform-runtime']
      },
      { test: /\.css$/, loader: 'style-loader!css-loader' },
      {
        test: /\.(ttf|eot|svg|woff(2)?)(\?[a-z0-9]+)?$/,
        exclude: /(node_modules|bower_components)/,
        loader: "file?name=[name].[ext]"
        // loader: 'file-loader'
      },
      {
        test: /\.html$/,
        loader: "file?name=[name].[ext]"
      },
      {
        test: /\.scss$/,
        loader: 'style!css!sass'
      }
    ]
  },
  plugins: plugins
};
