class Dashing.Treemap extends Dashing.Widget
  @accessor 'value', Dashing.AnimatedValue

  treemap_data = null
  margin = {top: 40, right: 10, bottom: 10, left: 10}
  width = 1200 - margin.left - margin.right
  height = 600 - margin.top - margin.bottom
  color = d3.scale.quantize().domain([0, 1]).range(['#a50026','#d73027','#f46d43','#fdae61','#fee08b','#d9ef8b','#a6d96a','#66bd63','#1a9850','#006837'])

  ready: ->
    render()

  onData: (data) ->
    treemap_data = data
    render()

  render = ->
    treemap_div = document.getElementById("treemap_div")
    if treemap_div != null then treemap_div.parentNode.removeChild(treemap_div)

    div = d3.select(".treemap").append("div")
        .attr("id", "treemap_div")
        .style("position", "relative")
        .style("width", (width + margin.left + margin.right) + "px")
        .style("height", (height + margin.top + margin.bottom) + "px")
        .style("left", margin.left + "px")
        .style("top", margin.top + "px")

    treemap = d3.layout.treemap()
        .size([width, height])
        .sticky(true)
        .value((d) -> d.clicks)

    node = div.datum(treemap_data.value).selectAll(".node")
        .data(treemap.nodes)
      .enter().append("div")
        .attr("class", "node")
        .style("left", (d) -> d.x + "px")
        .style("top", (d) -> d.y + "px")
        .style("width", (d) -> Math.max(0, d.dx - 1) + "px")
        .style("height", (d) -> Math.max(0, d.dy - 1) + "px")
        .style("background", (d) -> if d.keyword == "tree" then "#fff" else color(d.ctr))
        .text((d) -> if d.children then null else d.keyword)
