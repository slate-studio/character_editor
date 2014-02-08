###!
* Character Editor
* Author: Alexander Kravets @ slatestudio.com
* Licensed under the MIT license

  Usage:
  $('#editor').editor({placeholder: 'Title' })
  inst = $('#editor').data('editor')
  inst.serialize()

###

#= require_self
#= require character_editor/_selection
#= require character_editor/_toolbar

# Object - an object representing a concept that you want
# to model (e.g. a car)
@CharacterEditor =
  options:
    allowMultiParagraphSelection: true
    anchorInputPlaceholder:       'Paste or type a link'
    buttons:                      'bold, italic, underline, anchor, header1, header2, quote'
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
    tabSpaces:                    '    '
    viewSelector:                 'body'
    parentElements:               ['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'blockquote', 'pre']

  _dataOptions: ->
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
    @elem = elem
    @$elem = $(elem)

    @options = $.extend({}, @options, @_dataOptions(), options)

    @_build()

    @_bind()

    @

  _build: ->
    @$elem.attr('contenteditable', true)
    @$elem.attr('data-editor-element', true)

    @_setPlaceholder()

    if not @options.disableToolbar
      @_addToolbar()

  _addToolbar: -> # create only one toolbar for now
    @toolbar = window.characterEditorToolbar

    if not @toolbar
      $toolbarElement = $("<div id='character_editor_toolbar' class='character-editor-toolbar' />")
      $(@options.viewSelector).append($toolbarElement)

      @toolbar = Object.create(CharacterEditor.Toolbar).init(@options, $toolbarElement)

      window.characterEditorToolbar = @toolbar

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
    @_bindNewParagraph()
    @_bindReturn()
    @_bindTab()
    @_bindPaste()

  _bindNewParagraph: ->
    @$elem.on 'keyup', (e) =>
      node = getSelectionStart()

      if node and node.getAttribute('data-editor-element') and node.children.length == 0 and !@options.disableReturn
        document.execCommand('formatBlock', false, 'p')

      if e.which == 13 and !e.shiftKey
        node    = getSelectionStart()
        tagName = node.tagName.toLowerCase()

        if !@options.disableReturn and tagName != 'li' and !isListItemChild(node)
          document.execCommand('formatBlock', false, 'p')
          if tagName == 'a'
            document.execCommand('unlink', false, null)

  _bindReturn: ->
    @$elem.on 'keypress', (e) =>
      if e.which == 13 and @options.disableReturn
        e.preventDefault()

  _bindTab: ->
    @$elem.on 'keydown', (e) =>
      if e.which == 9
        tag = getSelectionStart().tagName.toLowerCase()
        if tag == "pre"
          e.preventDefault()
          document.execCommand('insertHtml', null, @options.tabSpaces)

  _bindPaste: ->
    return if !@options.forcePlainText

    @$elem.on 'paste', (e) =>
      html = ''

      $(@).removeClass('character-editor-placeholder')

      if e.clipboardData and e.clipboardData.getData
        e.preventDefault()

        if !@options.disableReturn
          paragraphs = e.clipboardData.getData('text/plain').split(/[\r\n]/g)
          $.each paragraphs, (i, p) -> if p != '' then html += "<p>#{p}</p>"

          document.execCommand('insertHTML', false, html)
        else
          document.execCommand('insertHTML', false, e.clipboardData.getData('text/plain'))

  serialize: ->
    @$elem.html().trim()

  destroy: ->
    @$elem.removeAttr('contenteditable')
    @$elem.removeAttr('data-editor-element')
    @$elem.removeAttr('data-placeholder')
    @$elem.removeClass('character-editor-placeholder')

    @$elem.off 'blur keypress keyup keydown paste'

    if @toolbar
      @toolbar.destroy()
      delete @toolbar
      delete window.characterEditorToolbar

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

$.plugin('editor', CharacterEditor)