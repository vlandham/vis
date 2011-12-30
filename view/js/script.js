$(document).ready(function() {
  $("#generate").click(writeDownloadLink);
});

function writeDownloadLink(){
    var html = d3.select("svg")
        .attr("title", "test2")
        .attr("version", 1.1)
        .attr("xmlns", "http://www.w3.org/2000/svg")
        .node().parentNode.innerHTML;

    d3.select("#preview").append("div")
        .attr("id", "download")
        .style("top", event.clientY+20+"px")
        .style("left", event.clientX+"px")
        .html("Right-click on this preview and choose Save as<br />Left-Click to dismiss<br />")
        .append("img")
        .attr("src", "data:image/svg+xml;base64,"+ btoa(html));

    d3.select("#download")
        .on("click", function(){
            if(event.button == 0){
                d3.select(this).transition()
                    .style("opacity", 0)
                    .remove();
            }
        })
        .transition()
        .duration(500)
        .style("opacity", 1);
};























