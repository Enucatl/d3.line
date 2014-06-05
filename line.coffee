if not d3.chart?
    d3.chart = {}

d3.chart.line = ->
    margin = {top: 20, right: 20, bottom: 40, left: 70}
    width = 900
    height = 600
    legend_square_size = 18
    x_value = (d, i) -> d[0]
    y_value = (d, i) -> d[1]
    color_value = (d) -> d.name
    x_scale = d3.scale.linear()
    y_scale = d3.scale.linear()
    color_scale = d3.scale.category20()
    x_axis = d3.svg.axis()
        .scale x_scale 
        .orient "bottom"
    y_axis = d3.svg.axis()
        .scale y_scale 
        .orient "left"
    x_title = undefined
    y_title = undefined
    chart = (selection) ->
        selection.each (data) ->
                 
            #get unique color names
            color_names = (data.map color_value).filter (d, i, self) ->
                self.indexOf d == i

            color_scale.domain color_names

            #convert to standard format
            data = data.map (d, i) ->
                {
                    values: d.values.map (e, j) ->
                        {
                            color: color_value(d)
                            x: x_value.call(d.values, e, j),
                            y: y_value.call(d.values, e, j)
                        }
                }

            #flatten the structure
            data = (data.map (d) -> d.values).reduce (a, b) -> a.concat b

            #update scales
            x_scale
                .range [0, width - margin.left - margin.right]
            y_scale
                .range [height - margin.top - margin.bottom, 0]

            #select the svg if it exists
            svg = d3.select this
                .selectAll "svg"
                .data [data]

            #otherwise create the skeletal chart
            g_enter = svg.enter()
                .append "svg"
                .append "g"
            g_enter.append "g"
                .classed "x axis", true
                .append "text"
                .classed "label", true
                .attr "x", width - margin.right - margin.left
                .attr "y", margin.bottom - 6
                .attr "dy", ".21em"
                .style "text-anchor", "end"
                .text x_title
            g_enter.append "g"
                .classed "y axis", true
                .append "text"
                .classed "label", true
                .attr "y", -margin.left + 6
                .attr "transform", "rotate(-90)"
                .attr "dy", ".71em"
                .style "text-anchor", "end"
                .text y_title
            g_enter.append "g"
                .classed "paths", true
            g_enter.append "g"
                .classed "legends", true

            #update the dimensions
            svg
                .attr "width", width
                .attr "height", height

            #update position
            g = svg.select "g"
                .attr "transform", "translate(#{margin.left}, #{margin.top})"

            # if you want a legend update it
            if legend_square_size?

                #update legend
                legends = g.select "g.legends"
                    .selectAll "g.legend"
                    .data color_scale.domain()

                l_enter = legends
                    .enter()
                    .append "g"
                    .classed "legend", true

                legends
                    .each (d) ->
                        rects = d3.select this
                            .selectAll "rect"
                            .data [d]
                        rects.enter()
                            .append "rect"
                            .attr "x", width - margin.right - margin.left - legend_square_size
                            .attr "width", legend_square_size
                            .attr "height", legend_square_size
                        rects
                            .style "fill", color_scale
                        texts = d3.select this
                            .selectAll "text"
                            .data [d]
                        texts.enter()
                            .append "text"
                            .attr "x", width - margin.right - margin.left - legend_square_size - 2
                            .attr "y", 9
                            .attr "dy", ".35em"
                            .style "text-anchor", "end"
                        texts
                            .text (d) -> d

                legends
                    .attr "transform", (d, i) -> "translate(0, #{(legend_square_size + 2) * i})"

                legends
                    .exit()
                    .remove()

            #update axes
            g.select ".x.axis"
                .attr "transform", "translate(0, #{y_scale.range()[0]})"
                .call x_axis

            g.select ".y.axis"
                .transition()
                .call y_axis

            #update line after axes so that the line appears above the ticks
            lines = g.select ".paths"
                .selectAll ".path"
                .data (d) -> d

            lines
                .enter()
                .append "path"
                .classed "path", true

            lines
                .transition()
                .duration(500)
                .attr "stroke", (d) -> color_scale(d.color)
                .attr "d", (d) -> (d3.svg.line()
                    .x (d) -> x_scale(d.x)
                    .y (d) -> y_scale(d.y)
                    )(d)

            lines
                .exit()
                .remove()


    chart.width = (value) ->
        if not arguments.length
            return width
        width = value
        chart

    chart.height = (value) ->
        if not arguments.length
            return height
        height = value
        chart

    chart.margin = (value) ->
        if not arguments.length
            return margin
        margin = value
        chart

    chart.x_value = (value) ->
        if not arguments.length
            return x_value
        x_value = value
        chart

    chart.color_value = (value) ->
        if not arguments.length
            return color_value
        color_value = value
        chart

    chart.y_value = (value) ->
        if not arguments.length
            return y_value
        y_value = value
        chart

    chart.x_title = (value) ->
        if not arguments.length
            return x_title
        x_title = value
        chart

    chart.y_title = (value) ->
        if not arguments.length
            return y_title
        y_title = value
        chart

    chart.x_scale = (value) ->
        if not arguments.length
            return x_scale
        x_scale = value
        chart

    chart.legend_square_size = (value) ->
        if not arguments.length
            return legend_square_size
        legend_square_size = value
        chart

    chart.y_scale = (value) ->
        if not arguments.length
            return y_scale
        y_scale = value
        chart

    chart
