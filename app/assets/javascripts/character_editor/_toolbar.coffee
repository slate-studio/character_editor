
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
    html = """<ul id='character-editor-toolbar-actions' class='character_editor_toolbar_actions'>"""

    $.each @options.buttons, (i, key) =>
      html += @_buttonTemplate(key)

    html += """</ul>
     <div class='character-editor-toolbar-form-anchor' id='character_editor_toolbar_form_anchor'>
       <input type='text' value='' placeholder='#{ @options.anchorInputPlaceholder }'>
       <a href='#'>&times;</a>
     </div>"""
    @$elem.html(html)

    # this.keepToolbarAlive = false;
    @$anchorForm     = $('#character_editor_toolbar_form_anchor')
    @$anchorInput    = @$anchorForm.children('input')
    @$toolbarActions = $('#character_editor_toolbar_actions')

  hideActions: ->
    @$elem.removeClass('character-editor-toolbar-active')

  showActions: ->
    timer    = ''

    @$anchorForm.hide()
    @$toolbarActions.show()

    clearTimeout(timer)

    timer = setTimeout ( =>
      if !@$elem.hasClass('character-editor-toolbar-active')
        @$elem.addClass('character-editor-toolbar-active')
    ), 100

  setPosition: ->
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

  _bindSelect: ->
    if !@options.disableToolbar
      timer = ''
      toolbar = @

      $(@options.viewSelector).on 'mouseup keyup blur', (e) =>
        clearTimeout(timer)
        timer = setTimeout ( -> toolbar.checkSelection() ), @options.delay

  _bindWindowResize: ->
    timer = ''
    $(window).on 'resize', =>
      clearTimeout(timer)
      timer = setTimeout ( => if @$elem.hasClass('character-editor-toolbar-active') then @setPosition() ), 100

  checkSelection: ->
    newSelection  = window.getSelection()
    selectionHtml = getSelectionHtml()
    selectionHtml = selectionHtml.replace(/<[\S]+><\/[\S]+>/gim, '')

    # Check if selection is between multi paragraph <p>.
    hasMultiParagraphs = selectionHtml.match(/<(p|h[0-6]|blockquote)>([\s\S]*?)<\/(p|h[0-6]|blockquote)>/g)
    hasMultiParagraphs = if hasMultiParagraphs then hasMultiParagraphs.length else 0

    if newSelection.toString().trim() == '' or ( !@options.allowMultiParagraphSelection and hasMultiParagraphs)
      @hideActions()
    else
      $editorElement = $(newSelection.getRangeAt(0).commonAncestorContainer).parents('[data-editor-element]')

      @activeEditor = $editorElement.data('editor')

      if !@activeEditor or @activeEditor.options.disableToolbar
        @hideActions()
      else
        @setPosition()
        @showActions()

  destroy: ->
    $(@options.viewSelector).off 'mouseup keyup blur'
    $(window).off 'resize'
    @$elem.remove()