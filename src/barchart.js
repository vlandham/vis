
var d3 = require('d3');
var THREE = require('three.js');
var TWEEN = require('tween.js');

module.exports = function createBarChart() {
  var width = 20;
  var height = 20;
  var bar = null;
  var bars = [];

  var xScale = d3.scale.linear();
  var yScale = d3.scale.ordinal();


  var chart = function(scene,rdata) {
    yScale.rangeRoundBands([0, height], 0.2);
    xScale.range([0, width]);

    var material1 = new THREE.MeshPhongMaterial({color: '#4183c4'});

    yScale.domain(rdata.map((d) => d.x));
    xScale.domain([0, d3.max(rdata, (d) => d.y)]);

    rdata.forEach(function(d,i) {

      var w = xScale(d.y);
      var h = yScale.rangeBand();
      var box = new THREE.BoxGeometry(w, h, 5);
      bar = new THREE.Mesh(box, material1);
      scene.add(bar);
      bars.push(bar);

      var position = {x: xScale(d.y) / 2, y: yScale(d.x)};
      var target = {x: 0, y: 0};
      bar.position.set(position.x, position.y, 1);
      // var tween = new TWEEN.Tween(position).to(target, 2000);
      // tween.onUpdate(function(){
      //   console.log(this.x)
      //   var that = this;
      //   bars.forEach(function(bar){
      //     bar.position.set(that.x, that.y, 1);
      //   });
      // });
      // tween.start();



    });


    // var root = subunit.select(scene);
    // console.log(root);
    // root.node().position.x = -width / 2;
    //
    // root.selectAll("bar")
    //   .data(rdata).enter()
    //   .append("mesh")
    //   .attr("tags", "bar")
    //   .tagged("big", function (d) {
    //     return d.frequency > 0.07;
    //   })
    //   .attr("material", material1)
    //   .attr("geometry", function (d) {
    //     var w = xScale.rangeBand();
    //     var h = height - yScale(d.frequency);
    //     return new THREE.BoxGeometry(w, h, 5);
    //   })
    //   .each(function (d) {
    //     var x0 = xScale(d.x);
    //     var y0 = -yScale(d.y);
    //     this.position.set(x0, y0, 240);
    //   });


    console.log(rdata);

  };

  chart.animate = function(_) {
    TWEEN.update();
  };

  chart.width = function(_) {
    if (!arguments.length) {
      return width;
    }
    width = _;
    return chart;
  };

  chart.height = function(_) {
    if (!arguments.length) {
      return height;
    }
    width = _;
    return chart;
  };

  return chart;

};
