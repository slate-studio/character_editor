
@CharacterEditor.Toolbar =
  init: (options, elem) ->
    # Mix in the passed-in options with the default options
    @options = $.extend({}, @options, options)

    # Save the element reference, both as a jQuery
    # reference and a normal reference
    @elem = elem
    @$elem = $(elem)

    # Build the DOM's initial structure
    @_build()

    @_bindSelect()
    @_bindWindowResize()
    @_bindButtons()
    @_bindAnchorForm()


    # return this so that we can chain and use the bridge with less code.
    @

  options:
    buttonLabels:
      bold:           '<i class="fa fa-bold"></i>'
      italic :        '<i class="fa fa-italic"></i>'
      underline:      '<i class="fa fa-underline"></i>'
      strikethrough:  '<i class="fa fa-strikethrough"></i>'
      superscript:    '<i class="fa fa-superscript"></i>'
      subscript:      '<i class="fa fa-subscript"></i>'
      anchor:         '<i class="fa fa-link"></i>'
      image:          '<i class="fa fa-picture-o"></i>'
      quote:          '<i class="fa fa-quote-right"></i>'
      orderedlist:    '<i class="fa fa-list-ol"></i>'
      unorderedlist:  '<i class="fa fa-list-ul"></i>'
      pre:            '<i class="fa fa-code fa-lg"></i>'
      header1:        '<b>H1</b>'
      header2:        '<b>H1</b>'

  _buttonTemplate: (key) ->
    l               = @options.buttonLabels
    classPrefix     = 'character-editor-action'
    templates =
      bold:           "<li><button class='#{classPrefix} #{classPrefix}-bold'
                                   data-action='bold' data-element='b'>#{ l.bold }</button></li>"

      italic:         "<li><button class='#{classPrefix} #{classPrefix}-italic'
                                   data-action='italic' data-element='i'>#{ l.italic }</button></li>"

      underline:      "<li><button class='#{classPrefix} #{classPrefix}-underline'
                                   data-action='underline' data-element='u'>#{ l.underline }</button></li>"

      strikethrough:  "<li><button class='#{classPrefix} #{classPrefix}-strikethrough'
                                   data-action='strikethrough' data-element='strike'>#{ l.strikethrough }</button></li>"

      superscript:    "<li><button class='#{classPrefix} #{classPrefix}-superscript'
                                   data-action='superscript' data-element='sup'>#{ l.superscript }</button></li>"

      subscript:      "<li><button class='#{classPrefix} #{classPrefix}-subscript'
                                   data-action='subscript' data-element='sub'>#{ l.subscript }</button></li>"

      anchor:         "<li><button class='#{classPrefix} #{classPrefix}-anchor'
                                   data-action='anchor' data-element='a'>#{ l.anchor }</button></li>"

      image:          "<li><button class='#{classPrefix} #{classPrefix}-image'
                                   data-action='image' data-element='img'>#{ l.image }</button></li>"

      quote:          "<li><button class='#{classPrefix} #{classPrefix}-quote'
                                   data-action='append-blockquote' data-element='blockquote'>#{ l.quote }</button></li>"

      orderedlist:    "<li><button class='#{classPrefix} #{classPrefix}-orderedlist'
                                   data-action='insertorderedlist' data-element='ol'>#{ l.orderedlist }</button></li>"

      unorderedlist:  "<li><button class='#{classPrefix} #{classPrefix}-unorderedlist'
                                   data-action='insertunorderedlist' data-element='ul'>#{ l.unorderedlist }</button></li>"

      pre:            "<li><button class='#{classPrefix} #{classPrefix}-pre'
                                   data-action='append-pre' data-element='pre'>#{ l.pre }</button></li>"

      header1:        "<li><button class='#{classPrefix} #{classPrefix}-header1'
                                   data-action='append-#{ @options.firstHeader }' data-element='#{ @options.firstHeader }'>#{ l.header1 }</button></li>"

      header2:        "<li><button class='#{classPrefix} #{classPrefix}-header2'
                                   data-action='append-#{ @options.secondHeader }' data-element='#{ @options.secondHeader }'>#{ l.header2 }</button></li>"
    return templates[key]

  _build: ->
    html = """<ul id='character_editor_toolbar_actions' class='character-editor-toolbar-actions'>"""

    $.each @options.buttons, (i, key) =>
      html += @_buttonTemplate(key)

    html += """</ul>
     <div class='character-editor-toolbar-form-anchor' id='character_editor_toolbar_form_anchor'>
       <input type='text' value='' placeholder='#{ @options.anchorInputPlaceholder }'>
       <a href='#'>&times;</a>
     </div>"""
    @$elem.html(html)

    @$anchorForm     = @$elem.find('#character_editor_toolbar_form_anchor')
    @$anchorInput    = @$anchorForm.children('input')
    @$toolbarActions = @$elem.find('#character_editor_toolbar_actions')

    @$anchorForm.hide()

  _hideActions: ->
    @$elem.removeClass('character-editor-toolbar-active')

  _showActions: ->
    timer    = ''

    @$anchorForm.hide()
    @$toolbarActions.show()

    clearTimeout(timer)

    timer = setTimeout ( =>
      if !@$elem.hasClass('character-editor-toolbar-active')
        @$elem.addClass('character-editor-toolbar-active')
    ), 100

  _setPosition: ->
    $contentView      = $(@options.viewSelector)

    contentLeftOffset = $contentView.offset().left
    contentTopOffset  = $contentView.offset().top
    contentScrollTop  = $contentView.scrollTop()
    contentInnerWidth = $contentView.innerWidth()

    buttonHeight    = 30
    selection       = window.getSelection()
    range           = selection.getRangeAt(0)
    boundary        = range.getBoundingClientRect()

    offsetWidth  = @$elem.get(0).offsetWidth
    offsetHeight = @$elem.get(0).offsetHeight

    defaultLeft       = (@options.diffLeft) - (offsetWidth / 2)
    middleBoundary    = (boundary.left + boundary.right) / 2 - contentLeftOffset
    halfOffsetWidth   = offsetWidth / 2


    if boundary.top < buttonHeight
      @$elem.addClass('character-toolbar-arrow-over')
      @$elem.removeClass('character-toolbar-arrow-under')
      @$elem.css 'top', buttonHeight + boundary.bottom - @options.diffTop + window.pageYOffset - offsetHeight + 'px'
    else
      @$elem.addClass('character-toolbar-arrow-under')
      @$elem.removeClass('character-toolbar-arrow-over')
      @$elem.css 'top', boundary.top + @options.diffTop - contentTopOffset + contentScrollTop - offsetHeight + 'px'

    edgeOffset = 5

    if middleBoundary < halfOffsetWidth
      @$elem.css 'left', defaultLeft + halfOffsetWidth + edgeOffset + 'px'
    else if (contentInnerWidth - middleBoundary) < halfOffsetWidth
      @$elem.css 'left', contentInnerWidth + defaultLeft - halfOffsetWidth - edgeOffset + 'px'
    else
      @$elem.css 'left', defaultLeft + middleBoundary + 'px'

    # TODO: update arrow layout to make it possible to move it on edge cases
    #
    #
    #
    #
    #
    #
    #

  _bindSelect: ->
    if !@options.disableToolbar
      timer = ''
      toolbar = @

      $(@options.viewSelector).on 'mouseup keyup blur', (e) =>
        clearTimeout(timer)
        timer = setTimeout ( -> toolbar._checkSelection() ), @options.delay

  _bindWindowResize: ->
    timer = ''
    $(window).on 'resize', =>
      clearTimeout(timer)
      timer = setTimeout ( => if @$elem.hasClass('character-editor-toolbar-active') then @_setPosition() ), 100

  _getActiveEditor: ->
    selection = window.getSelection()
    $editorElement = $(selection.getRangeAt(0).commonAncestorContainer).parents('[data-editor-element]')
    if $editorElement then $editorElement.data('editor') else false

  _checkSelection: ->
    newSelection  = window.getSelection()
    selectionHtml = getSelectionHtml()
    selectionHtml = selectionHtml.replace(/<[\S]+><\/[\S]+>/gim, '')

    # Check if selection is between multi paragraph <p>.
    hasMultiParagraphs = selectionHtml.match(/<(p|h[0-6]|blockquote)>([\s\S]*?)<\/(p|h[0-6]|blockquote)>/g)
    hasMultiParagraphs = if hasMultiParagraphs then hasMultiParagraphs.length else 0

    if newSelection.toString().trim() == '' or ( !@options.allowMultiParagraphSelection and hasMultiParagraphs)
      @_hideActions()
    else
      @selection   = newSelection
      activeEditor = @_getActiveEditor()

      if !activeEditor or activeEditor.options.disableToolbar
        @_hideActions()
      else
        @_setButtonStates()
        @_setPosition()
        @_showActions()

  _setButtonStates: ->
    $buttons = @$elem.find('button')
    $buttons.removeClass('character-editor-button-active')

    parentNode = @selection.anchorNode

    if !parentNode.tagName
      parentNode = @selection.anchorNode.parentNode

    while parentNode.tagName != undefined and @options.parentElements.indexOf(parentNode.tagName) == -1
      tag = parentNode.tagName.toLowerCase()
      @_activateButton(tag)
      parentNode = parentNode.parentNode

  _activateButton: (tag) ->
    $el = @$elem.find('[data-element="' + tag + '"]').first()
    if $el.length and !$el.hasClass('character-editor-button-active')
      $el.addClass('character-editor-button-active')

  _getSelectionData: (el) ->
    if el and el.tagName
      tagName = el.tagName.toLowerCase()

    while el and @options.parentElements.indexOf(tagName) == -1
      el = el.parentNode
      if el and el.tagName
        tagName = el.tagName.toLowerCase()

    return { el: el, tagName: tagName }

  _execFormatBlock: (el) ->
    selectionData = @_getSelectionData(@selection.anchorNode)

    # FF handles blockquote differently on formatBlock allowing nesting, we need to use outdent
    # https://developer.mozilla.org/en-US/docs/Rich-Text_Editing_in_Mozilla
    if el == 'blockquote' and selectionData.el and selectionData.el.parentNode.tagName.toLowerCase() == 'blockquote'
      return document.execCommand('outdent', false, null)

    if selectionData.tagName == el
      el = 'p'

    return document.execCommand('formatBlock', false, el)

  _execAction: (action, e) ->
    if action.indexOf('append-') > -1
     @_execFormatBlock(action.replace('append-', ''))
     @_setPosition()
     @_setButtonStates()

    else if action is 'anchor'
     @_triggerAnchorAction(e)

    else if action is 'image'
      document.execCommand('insertImage', false, window.getSelection())

    else
      document.execCommand(action, false, null)
      @_setPosition()

  _triggerAnchorAction: (e) ->
    if @selection.anchorNode.parentNode.tagName.toLowerCase() == 'a'
      document.execCommand('unlink', false, null)
    else
      if @$anchorForm.is(':visible') then @_showActions() else @_showAnchorForm()

  _showAnchorForm: ->
    @savedSelection = window.saveSelection()
    @$toolbarActions.hide()
    @$anchorForm.show()
    @$anchorInput.focus()
    @$anchorInput.val('')

  _bindButtons: ->
    toolbar  = @
    $buttons = @$elem.find('button')

    triggerAction = (e) ->
      e.preventDefault()
      e.stopPropagation()

      if not toolbar.selection
        toolbar._checkSelection()

      $button = $(e.currentTarget)
      $button.toggleClass('character-editor-button-active')

      action = $button.attr('data-action')
      toolbar._execAction(action, e)

    $buttons.on 'click', triggerAction

  setTargetBlank: ->
    el = window.getSelectionStart()

    if el.tagName.toLowerCase() == 'a'
      el.target = '_blank'
    else
      $(el).find('a').each (i, el) -> $(el).attr('target', '_blank')

  createLink: (input) ->
    window.restoreSelection(@savedSelection)
    document.execCommand('createLink', false, @$anchorInput.val())
    if @options.targetBlank
      @setTargetBlank()

    @showActions()
    @$anchorInput.val('')

  _bindAnchorForm: ->
    @$anchorForm.on 'click', (e) ->
      e.stopPropagation()

    @$anchorInput.on 'keyup', (e) =>
      if e.keyCode == 13
        e.preventDefault()
        @createLink()

    @$anchorInput.on 'blur', (e) =>
      @_checkSelection()

    @$anchorForm.find('a').on 'click', (e) =>
      e.preventDefault()
      @_showActions()
      window.restoreSelection(@savedSelection)

  destroy: ->
    $(@options.viewSelector).off 'mouseup keyup blur'
    $(window).off 'resize'
    @$anchorForm.off 'click'
    @$anchorForm.find('a').off 'click'
    @$anchorInput.on 'keyup blur'
    @$elem.find('button').off 'click'
    @$elem.remove()