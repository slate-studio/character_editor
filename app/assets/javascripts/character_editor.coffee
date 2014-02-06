#= require jquery

###!
* Character Editor
* Author: Alexander Kravets @ slatestudio.com
* Licensed under the MIT license
###

# Object - an object representing a concept that you want
# to model (e.g. a car)
CharacterEditor =
  options:
    allowMultiParagraphSelection: true
    anchorInputPlaceholder:       'Paste or type a link'
    buttons:                      ['bold', 'italic', 'underline', 'anchor', 'header1', 'header2', 'quote']
    buttonLabels:                 false
    delay:                        0
    diffLeft:                     0
    diffTop:                      -10
    disableReturn:                false
    disableToolbar:               false
    forcePlainText:               true
    placeholder:                  'Type your text...'
    targetBlank:                  false
    firstHeader:                  'h3'
    secondHeader:                 'h4'

  data_options: ->
    result = {}
    dataOptions = @$elem.attr('data-options')
    if dataOptions
      opts = dataOptions.split(';')

      isNumber     = (n)   -> return !isNaN(parseFloat(n)) && isFinite(n)
      removeQuotes = (str) -> str.replace(/^['\\/"]+|(;\s?})+|['\\/"]+$/g, '')
      trim         = (val) -> if typeof val == 'string' then removeQuotes($.trim(val)) else val

      $.each opts, (i, opt) ->
        p = opt.split(':')

        if /true/i.test(p[1])
          p[1] = true
        else if /false/i.test(p[1])
          p[1] = false
        else if isNumber(p[1])
          p[1] = parseFloat(p[1])

        if p.length == 2 and p[0].length > 0
          result[ trim(p[0]) ] = trim(p[1])

    return result

  init: (options, elem) ->
    # Save the element reference, both as a jQuery
    # reference and a normal reference
    @elem = elem
    @$elem = $(elem)

    # Mix in the passed-in options with the default options
    @options = $.extend({}, @options, @data_options(), options)

    @isActive = true
    @parentElements = ['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'blockquote', 'pre']
    @id = '' # should be based on index

    # Build the DOM's initial structure
    @_build()

    # Bind events
    #@_bind()

    # return this so that we can chain and use the bridge with less code.
    @

  _build: ->
    @$elem.attr('contenteditable', true)

    # if (!this.options.disableToolbar && !this.elements[i].getAttribute('data-disable-toolbar')) {
    #     addToolbar = true;
    # }

    @_setPlaceholder()
    @_addToolbar()

  _addToolbar: ->
        # this.initToolbar()
        #     .bindButtons()
        #     .bindAnchorForm();

  _setPlaceholder: ->
    @$elem.attr('data-placeholder', @options.placeholder)

    activatePlaceholder = (el) ->
      if el.textContent.replace(/^\s+|\s+$/g, '') == ''
        $(el).addClass('character-editor-placeholder')

    activatePlaceholder(@elem)

    @$elem.on 'blur keypress', (e) ->
      $(@).removeClass('character-editor-placeholder')
      if e.type != 'keypress'
        activatePlaceholder(@)

  _bind: ->
    @bindSelect()
    @bindPaste()
    @bindWindowActions()

  serialize: ->
    @$elem.html().trim()

  destroy: ->
    @

# Object.create support test, and fallback for browsers without it
if typeof Object.create isnt "function"
  Object.create = (o) ->
    F = ->
    F:: = o
    new F()

# Create a plugin based on a defined object
$.plugin = (name, object) ->
  $.fn[name] = (options) ->
    @each ->
      $.data @, name, Object.create(object).init(options, @)  unless $.data(@, name)
  return


# Usage:
# With Object, we could now essentially do this:
$.plugin('editor', CharacterEditor)

# and at this point we could do the following
# $('#elem').editor({placeholder: 'title' })
# inst = $('#elem').data('editor');
# inst.serialize()