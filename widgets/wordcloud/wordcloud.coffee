class Dashing.Wordcloud extends Dashing.Widget
  @accessor 'value', Dashing.AnimatedValue

  wordcloud_data = null
  font = d3.scale.linear()
    .domain([0, 1000000])
    .range([10, 100])
    .clamp(true)
  color = d3.scale.linear()
    .domain([0,1,2,3,4,5,6,10,15,20,100])
    .range(["#ddd", "#ccc", "#bbb", "#aaa", "#999", "#888", "#777", "#666", "#555", "#444", "#333", "#222"])

  ready: ->
    render()

  onData: (data) ->
    wordcloud_data = data
    render()

  render = ->
    wordcloud_svg = document.getElementById("wordcloud_svg")
    if wordcloud_svg != null then wordcloud_svg.parentNode.removeChild(wordcloud_svg)

    d3.layout.cloud().size([800, 300])
      .words(wordcloud_data.value)
      .rotate(0)
      .fontSize((d) -> font(d.size))
      .on("end", (words) ->
          d3.select(".wordcloud").append("svg")
            .attr("id", "wordcloud_svg")
            .attr("width", 850)
            .attr("height", 350)
            .append("g")
            .attr("transform", "translate(320,200)")
            .selectAll("text")
            .data(words)
            .enter().append("text")
            .style("font-size", (d) -> font(d.size) + "px")
            .style("fill", (d, i) -> color(i))
            .attr("transform", (d) -> "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")")
            .text((d) -> d.text)
        )
      .start()
