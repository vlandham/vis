# An increasingly complicated way to get started with data visualizations using D3

Originally this repo used coffeescript and no build systems.

Now it uses webpack and es6 via Babel to generate the project. This might be overkill.

## Usage

### First Clone the Repository

```
git clone git@github.com:vlandham/vis.git
cd vis
```

### You might consider creating a new branch for your Vis

```
git checkout -b interesting_new_bar_chart
```

### Install requirements

use `npm` to get things installed

```
npm install
```

### Build and Serve

Use `webpack` to get things built

```
webpack
```

You can also use `npm run` to run `webpack` commands:

`npm run watch`

`npm run build`

Now visit http://localhost:8080 and open the console to see some output.

### Start Coding

The main vis code is in `src/vis.js` and the data loading is in `src/main.js`.

I am using the webpack babel loader so you can use es6 syntax as you like!
