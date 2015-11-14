module.exports = {
  entry: './src/main.js',
  output: {
    filename: 'bundle.js'
  },
  module: {
    loaders: [
      {
        test: /\.\/src\/\.js?$/,
        exclude: /(node_modules|bower_components)/,
        loader: 'babel'
      }
      // { test: /\.\/src\/css\/\.css$/, loader: 'style-loader!css-loader' },
    ]
  }
};
