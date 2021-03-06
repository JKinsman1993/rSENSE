###
  * Copyright (c) 2011, iSENSE Project. All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
  *
  * Redistributions of source code must retain the above copyright notice, this
  * list of conditions and the following disclaimer. Redistributions in binary
  * form must reproduce the above copyright notice, this list of conditions and
  * the following disclaimer in the documentation and/or other materials
  * provided with the distribution. Neither the name of the University of
  * Massachusetts Lowell nor the names of its contributors may be used to
  * endorse or promote products derived from this software without specific
  * prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  * ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR
  * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
  * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
###
$ ->
  if namespace.controller is "visualizations" and namespace.action in ["displayVis", "embedVis", "show"]

    window.globals ?= {}

    ###
    Makes a title with apropriate units for a field
    ###
    window.fieldTitle = (field, parens = true) ->
      if field.unitName isnt "" and field.unitName isnt null
        if parens is true
          "#{field.fieldName} (#{field.unitName})"
        else
          "#{field.fieldName} #{field.unitName}"
      else
        field.fieldName

    ###
    Returns the units for a field
    ###
    window.fieldUnit = (field, parens = true) ->
      if field.unitName isnt null
        if parens is true then "(#{field.unitName})" else "#{field.unitName}"

    ###
    Removes 'item' from the array 'arr'
    Returns the modified (or unmodified) arr.
    ###
    window.arrayRemove = (arr, item) ->
      index = arr.indexOf item
      if index isnt -1
        arr.splice index, 1
      arr

    ###
    Tests to see if a and b are within thresh%
    of the smaller value.
    ###
    window.fpEq = (a, b, thresh = 0.0001) ->
      diff = Math.abs (a - b)
      e = (Math.abs (Math.min a, b)) * thresh

      return diff < e

    ###
    Date formatter
    ###
    globals.dateFormatter = (dat) ->

      if dat is "null" or dat is null
        return ""

      if isNaN dat
        return "Invalid Date"

      if data.timeType is data.GEO_TIME
        return globals.geoDateFormatter(dat)

      dat = new Date(Number dat)

      monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul","Aug", "Sep", "Oct", "Nov", "Dec"]

      minDigits = (num, str) ->
        str = String str
        while str.length < num
          str = '0' + str
        str

      str = ""
      str += dat.getUTCDate()              + " "
      str += monthNames[dat.getUTCMonth()] + " "
      str += dat.getUTCFullYear()          + " "



      str += (minDigits 2, dat.getUTCHours())   + ":"
      str += (minDigits 2, dat.getUTCMinutes()) + ":"
      str += (minDigits 2, dat.getUTCSeconds()) + "."
      str += (minDigits 3, dat.getUTCMilliseconds()) + " GMT"

    ###
    Date formatter for geological scale dates
    ###
    globals.geoDateFormatter = (dat) ->
      if dat is 0
        "BCE / CE"
      else if dat > 0
        "#{dat} CE"
      else
        "#{Math.abs dat} BCE"

    ###
    Cross platform accessor/mutator for element inner text
    ###
    window.innerTextCompat = (self, value = null) ->
      if document.getElementsByTagName("body")[0].innerText?
        if value is null
          return self.innerText
        else
          self.innerText = value
      else
        if value is null
          return self.textContent
        else
          self.textContent = value

    ###
    This function adds a parameterizable radial marker to Highchart's list of
    marker styles.
    ###
    addRadialMarkerStyle = (name, points, phase, magnitudes = [1]) ->

      extension = {}

      extension[name] = (x, y, w, h) ->

        svg = Array()

        verticies = Array()

        offset = phase * 2 * Math.PI

        modpoints = points * magnitudes.length

        for i in [0..modpoints]

          tx = (Math.sin 2 * Math.PI * i / modpoints + offset) * magnitudes[i % magnitudes.length]
          ty = (Math.cos 2 * Math.PI * i / modpoints + offset) * magnitudes[i % magnitudes.length]

          tx = tx / 2 + 0.5
          ty = ty / 2 + 0.5

          verticies.push [tx * w + x, ty * h + y]

        svg.push "M"
        svg.push verticies[0][0]
        svg.push verticies[0][1]
        svg.push "L"

        for [vx, vy] in verticies

          svg.push vx
          svg.push vy

        svg.push "Z"

        svg

      Highcharts.extend Highcharts.Renderer.prototype.symbols, extension

    ###
    Colors taken from Google Charts defaults:
      http://there4development.com/blog/2012/05/02/google-chart-color-list/
    ###
    globals.colors =
      ['#3366CC','#DC3912','#FF9900','#109618','#990099',
       '#3B3EAC','#0099C6','#DD4477','#66AA00','#B82E2E',
       '#316395','#994499','#22AA99','#AAAA11','#6633CC',
       '#E67300','#8B0707','#329262','#5574A6','#3B3EAC']

    globals.configs ?= {}
    globals.configs.colors = globals.colors

    ###
    Generate a list of dashes
    ###
    globals.dashes = []

    globals.dashes.push 'Solid'
    globals.dashes.push 'ShortDot'
    globals.dashes.push 'ShortDash'
    globals.dashes.push 'Dot'

    globals.dashes.push 'ShortDashShortDot'
    globals.dashes.push 'DashDotDot'
    globals.dashes.push 'LongDashDotDotDot'

    globals.dashes.push 'LongDashDash'

    ###
    Generate a list of symbols and symbol rendering routines and then add them
    in an order that is clear and easy to read.
    ###

    fanMagList           = [1, 1, 15 / 16, 7 / 8, 3 / 4, 1 / 4, 1 / 4, 3 / 4, 7 / 8, 15 / 16, 1]
    pieMagList           = [1,1,1,1,1,1,1,1,1,1,1,1,1,0]
    halfmoonMagList      = [1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0]
    starMagList          = [Math.sqrt(2), 2 / 3]
    diamondMagList       = [Math.sqrt(2)]

    symbolList           = ['circle', 'square', 'up-tri', '5-star', 'diamond',  'down-tri', '4-fan',
      '6-star', 'left-tri', '3-fan', '2-pie', 'right-tri', '2-fan', 'up-halfmoon', 'down-halfmoon',
      'left-halfmoon', 'right-halfmoon', '3-pie', '4-pie', '5-pie']

    ###
    Add all the custom symbols for the symbolList.
    ###

    # Make the blank icon
    addRadialMarkerStyle "blank", 1, 0, [0]

    # Make default diamond as large as a square
    addRadialMarkerStyle "diamond", 4, 0, diamondMagList

    # Make the 5 and 6 pointed stars
    for i in [5,6]
      addRadialMarkerStyle "#{i}-star", i, 0.5, starMagList

    # Make the various 2, 3, and 4 pointed fans
    for i in [2,3,4]
      addRadialMarkerStyle "#{i}-fan", i, 0, fanMagList

    # Make the triangles of different orientation
    for [phase, direction] in [[0, "down"],[1 / 4, "right"],[2 / 4, "up"],[3 / 4, "left"]]
      addRadialMarkerStyle "#{direction}-tri", 3, phase, [Math.sqrt(2)]

    # Make the 2, 3, 4, and 5 sliced pies
    for i in [2,3,4,5]
      addRadialMarkerStyle "#{i}-pie", i, 0, pieMagList

    #Make the multi-direction halfmoons
    for [phase, direction] in[[0, "right"],[1 / 4, "up"],[2 / 4, "left"],[3 / 4, "down"]]
      addRadialMarkerStyle "#{direction}-halfmoon", 1, phase, halfmoonMagList

    ###
    Store the list
    ###
    globals.symbols = symbolList

    ###
    Generates an elapsed time field with given name from given
    time field.
    ###
    data.generateElapsedTime = (name, sourceField) ->
      timeMins = []

      for group in data.groups
        timeMins.push Number.MAX_VALUE

      for datapoint in data.dataPoints
        group = data.groups.indexOf (String datapoint[globals.configs.groupById]).toLowerCase()
        time = datapoint[sourceField].valueOf()
        timeMins[group] = Math.min timeMins[group], datapoint[sourceField]

      for datapoint in data.dataPoints
        group = data.groups.indexOf (String datapoint[globals.configs.groupById]).toLowerCase()
        curTime = datapoint[sourceField].valueOf()
        datapoint.push (curTime - timeMins[group]) / 1000.0

      data.fields.push
        fieldID: -1
        fieldName: name
        typeID: 2
        unitName: "s"

      data.numericFields.push (data.fields.length - 1)
      data.normalFields.push (data.fields.length - 1)

      if globals.scatter instanceof DisabledVis
        delete globals.scatter
        globals.scatter = new Scatter "scatter_canvas"
        ($ "#visTabList li[aria-controls='scatter_canvas'] a span").css "text-decoration", ""
        ($ "#visTabList li[aria-controls='scatter_canvas'] a img").attr('src',
          ($ "#visTabList li[aria-controls='scatter_canvas'] a img").data('enable-src'))

      globals.scatter.xAxis = data.normalFields[data.normalFields.length - 1]
      ($ "#visTabList li[aria-controls='scatter_canvas'] a").click()

    ###
    If there is only one time field, generates an appropriate
    elapsed time field. Otherwise it prompts using a dialog for
    which time field to use.
    ###
    globals.generateElapsedTimeDialog = ->

      if data.timeFields.length is 1
        name  = 'Elapsed Time [from '
        name += data.fields[data.timeFields[0]].fieldName + ']'
        data.generateElapsedTime name, data.timeFields[0]
        globals.curVis.end()
        globals.curVis.start()
        return

      formText = """
      <div id="dialog-form" title="Generate Elapsed Time">

        <form>
        <fieldset>
      """

      formText += '<select id="timeSelector" class="form-control">'

      for fieldIndex, index in data.timeFields
        sel = if index is 0 then 'selected' else ''
        formText += "<option value='#{Number fieldIndex}' #{sel}>#{data.fields[fieldIndex].fieldName}</option>"

      formText += """
        </fieldset>
        </form>
      </div>
      """

      selectedTime = data.timeFields[0]

      ($ '#groupSelector').change (e) ->
        element = e.target or e.srcElement
        selectedTime = (Number element.value)

      ($ "#container").append(formText)

      ($ "#dialog-form" ).dialog
        resizable: false
        draggable: false
        autoOpen: true
        height: 'auto'
        width: 'auto'
        modal: true
        buttons:
          Generate: ->
            name  = 'Elapsed Time [from '
            name += data.fields[selectedTime].fieldName + ']'
            data.generateElapsedTime name, selectedTime
            globals.curVis.end()
            globals.curVis.start()
            ($ "#dialog-form").dialog 'close'
        close: ->
          ($ "#dialog-form").remove()

    globals.identity = (i) -> i

###
Override default highcarts zoom behavior (because it sucks when allowing zoom out)
###
Highcharts.Axis.prototype.zoom = (newMin, newMax) ->

  this.displayBtn = newMin != undefined || newMax != undefined

  this.setExtremes newMin, newMax, true, undefined, {trigger: 'zoom'}

  true
