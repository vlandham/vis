
function removePunctuation(string) {
  return string.replace(/['!"#$%&\\'()\*+,\-\.\/:;<=>?@\[\\\]\^_`{|}~']/g," ").replace(/\s{2,}/g," ");
}

function stringToWords(string) {
  //http://blog.tompawlak.org/split-string-into-tokens-javascript
  return string.match(/\S+/g);
}

var concordancePlot = function() {
  var width = 500;
  var height = 200;
  var margin = {top: 20, right: 20, bottom: 20, left: 20};
  var g = null;
  var drop = null;
  var sentence = null;
  var data = [];
  var wordScale = d3.scale.linear();

  var chart = function(selection) {
    selection.each(function(rawData) {


      var svg = d3.select(this).append("svg");
      var gEnter = svg.append("g");

      svg.attr("width", width + margin.left + margin.right );
      svg.attr("height", height + margin.top + margin.bottom );
      g = svg.select("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      g.append("rect")
        .attr("class", "background")
        .attr("width", width)
        .attr("height", height);

      drop = d3.select(this).append("div");

      drop.attr("class", "drop")
        .attr("draggable", true)
        .style("margin-top", margin.top + "px")
        .style("margin-left", margin.left + "px")
        .style("width", 300 + "px");

      drop.append("p").attr("class", 'info')
        .text("Drop a text (.txt) file here");

      drop.on("dragover", function() {
        d3.event.preventDefault();
        d3.event.dataTransfer.dropEffect = 'copy';
        d3.select(this).style("background-color", "#ddd");
        d3.event.dataTransfer.dropEffect = 'copy';
        return false;
      });
      drop.on("dragenter", function() {
        d3.event.preventDefault();
        d3.event.dataTransfer.dropEffect = 'copy';
        return false;
      });
      drop.on("dragleave", function() {
        d3.select(this).style("background-color", "white");
      });
      drop.on("drop", function() {
        var e = d3.event;
        e.preventDefault();
        d3.select(this).style("background-color", "white");

        var fileList = e.dataTransfer.files;

        if (fileList.length > 0) {
          readTextFile(fileList[0]);
        }

        return false;
      });
    });
  };

  function update(searchTerm) {
    wordScale.domain([0, data.length]).range([0, width]);
    selectedWords = data.filter(function(d) { return d.w == searchTerm; });
    var words = g.selectAll('.word')
      .data(selectedWords, function(d) { return d.i;});
    words.exit().remove();
    words.enter()
      .append('line')
      .attr("class", "word")
      .attr("x1", function(d) { return wordScale(d.i); })
      .attr("x2", function(d) { return wordScale(d.i); })
      .attr("y1", 0)
      .attr("y2", height)
      .attr("stroke", "black")
      .attr("stroke-width", 1)
      .on("mouseover", showSentence);
  }

  function showSentence(d) {
    console.log(d);
  }

  function processData(rawData) {
    data = stringToWords(removePunctuation(rawData.toLowerCase()));
    data = data.map(function(d,i) { return {w:d, i:i}; });
  }

  function loadText(file, text) {
    processData(text);
    console.log(file.name);
    drop.select(".info").text(file.name);
    update('');
  }

  // Read the contents of a file.
  //http://demos.mattwest.io/drag-and-drop/
  function readTextFile(file) {
    var reader = new FileReader();

    reader.onloadend = function(e) {
      if (e.target.readyState == FileReader.DONE) {
        var content = reader.result;
        loadText(file, content);
      }
    };

    reader.readAsBinaryString(file);
  }

  chart.height = function(_) {
    if(!arguments.length) {
      return height;
    }
    height = _;
    return chart;
  };


  chart.search = function(word) {
    update(word);
    return chart;
  };


return chart;
};

function plotData(selector, data, plot) {
  d3.select(selector)
    .datum(data)
    .call(plot);
}

var plots = [];

$(document).ready(function() {
  var plot = concordancePlot();
  plots.push(concordancePlot());
  plots.push(concordancePlot());

  plots.forEach(function(plot) {
    plotData("#vis", " ", plot);
  });

  function display(error, data) {
    // plots[0].text(data);
  }

  queue()
    .defer(d3.text, "data/alice.txt")
    .await(display);

  d3.select("#search").on('input', function() {
    var word = this.value.toLowerCase();
    plots.forEach(function(plot) {

      plot.search(word);
    })
  });
});
