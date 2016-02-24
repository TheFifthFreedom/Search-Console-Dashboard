class Dashing.Pie extends Dashing.Widget
  @accessor 'value', Dashing.AnimatedValue

  pie_data = null
  width = 220
  height = 220
  radius = 110
  color = d3.scale.category20()

  ready: ->
    render()

  onData: (data) ->
    pie_data = data
    render()

  render = ->
    pie_svg = document.getElementById("pie_svg")
    pie_legend = document.getElementById("pie_legend")
    if pie_svg != null then pie_svg.parentNode.removeChild(pie_svg)
    if pie_legend != null then pie_legend.parentNode.removeChild(pie_legend)

    chart = d3.select('.pie_chart').append("svg:svg")
        .data([pie_data.value])
        .attr("id", "pie_svg")
        .attr("width", width)
        .attr("height", height)
        .append("svg:g")
        .attr("transform", "translate(#{radius} , #{radius})")

    arc = d3.svg.arc().innerRadius(radius * .5).outerRadius(radius)
    pie = d3.layout.pie().value((d) -> d.value)

    arcs = chart.selectAll("g.slice")
      .data(pie)
      .enter()
      .append("svg:g")
      .attr("class", "slice")

    arcs.append("svg:path")
      .attr("fill", (d, i) -> color(i))
      .attr("d", arc)

    legend = d3.select(".legend")
      .append("ul")
      .attr("id", "pie_legend")
    legend.selectAll("ul").data(pie_data.value)
      .enter()
      .append("li")
      .each((d, i) ->
        li = d3.select(this)
        li.append("span")
          .style("background-color",color(i))
        li.append("text")
          .text(d.label)
      )
