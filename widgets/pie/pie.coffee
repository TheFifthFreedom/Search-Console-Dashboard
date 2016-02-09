class Dashing.Pie extends Dashing.Widget
  @accessor 'value', Dashing.AnimatedValue

  onData: (data) ->
    width = 220
    height = 220
    radius = 110
    color = d3.scale.category20()

    $(@node).find('.pie_chart svg').remove();
    $(@node).find('.legend ul').remove();

    chart = d3.select('.pie_chart').append("svg:svg")
        .data([data.value])
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
    legend.selectAll("ul").data(data.value)
      .enter()
      .append("li")
      .each((d, i) ->
        li = d3.select(this)
        li.append("span")
          .style("background-color",color(i))
        li.append("text")
          .text(d.label)
      )
