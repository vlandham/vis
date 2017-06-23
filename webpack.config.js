var path = require('path');
var webpack = require('webpack');

var ExtractTextPlugin = require("extract-text-webpack-plugin");
var plugins = [];

plugins.push(new ExtractTextPlugin("build/app.css"));

var minimize = process.argv.indexOf('--minimize') === -1 ? false : true;

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
  devtool: 'source-map',
  // for modules
  resolve: {
    modules: [path.join(__dirname, 'node_modules')]
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        include: /src/,
        use: ['babel-loader'],
      },
      {
        test: /\.css$/,
        // use: ExtractTextPlugin.extract("style","css")
        use: ExtractTextPlugin.extract({ fallback: 'style-loader', use: 'css-loader' })
      },
      {
        test: /\.scss$/,
        use: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: [{
            loader: "css-loader",
            options: {
              sourceMap: true,
              modules: true,
              importLoaders: 2,
            }
          }, {
            loader: "sass-loader",
            options: {
              sourceMap: true,
            }
          }]
        })
      },
      {
        test: /\.(ttf|eot|svg|woff(2)?)(\?[a-z0-9]+)?$/,
        exclude: /(node_modules|bower_components)/,
        loader: "file-loader?name=build/[name].[ext]"
        // loader: 'file-loader'
      },
      {
        test: /\.html$/,
        loader: "file-loader?name=build/[name].[ext]"
      }
    ]
  },
  plugins: plugins
};
