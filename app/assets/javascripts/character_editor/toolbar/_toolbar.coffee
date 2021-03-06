#= require_self
#= require ./_position
#= require ./_templates

@CharacterEditor.Toolbar =
  init: (options, elem) ->
    @options = $.extend({}, @options, options)

    @_buttonTemplates = @_generateButtonTemplates(@options)

    @$elem = $(@_toolbarTemplate(@options))
    $(@options.viewSelector).append(@$elem)

    # this helps to not hide toolbar on selection (while toolbar button click)
    @keepToolbarVisible = false

    @_build()

    @_bind()

    @

  options: {}

  _build: ->
    @$toolbarButtons = @$elem.find('#character_editor_toolbar_buttons')
    @$anchorForm     = @$elem.find('#character_editor_toolbar_form_anchor')
    @$anchorInput    = @$anchorForm.children('input')

    @$toolbarButtons.show()
    @$anchorForm.hide()

  _bind: ->
    @_bindWindowResize()
    @_bindButtons()
    @_bindAnchorForm()
    @_bindSelect()

  _hide: ->
    @keepToolbarVisible = false
    @$elem.removeClass('character-editor-toolbar-active')
    @$toolbarButtons.removeClass()

  _show: ->
    timer = ''

    @$anchorForm.hide()

    # TODO: this can be optimized to do not change DOM
    html = ''
    $.each @options.buttons.split(' '), (i, key) => html += @_buttonTemplates[key]
    @$toolbarButtons.html(html)

    @$toolbarButtons.show()

    @$anchorInput.css('width', @$elem.width() - 40) # TODO: remove build in themes values

    @keepToolbarVisible = false

    clearTimeout(timer)

    timer = setTimeout ( =>
      if !@$elem.hasClass('character-editor-toolbar-active')
        @$elem.addClass('character-editor-toolbar-active')
    ), 100

  _bindSelect: ->
    if !@options.disableToolbar
      timer = ''
      toolbar = @

      $(@options.viewSelector).on 'mouseup keyup blur', (e) =>
        clearTimeout(timer)
        timer = setTimeout (-> toolbar._checkSelection()), @options.delay

  _bindWindowResize: ->
    timer = ''
    $(window).on 'resize', =>
      clearTimeout(timer)
      timer = setTimeout ( => if @$elem.hasClass('character-editor-toolbar-active') then @_setPosition() ), 100

  _getActiveEditor: ->
    $editorElement = $(@selection.getRangeAt(0).commonAncestorContainer).parents('[data-editor-element]')
    if $editorElement then $editorElement.data('editor') else false

  _checkSelection: ->
    if not @keepToolbarVisible
      @selection  = window.getSelection()

      if @selection.toString().trim() == ''
        return @_hide()

      activeEditor = @_getActiveEditor()
      if !activeEditor or activeEditor.options.disableToolbar
        return @_hide()

      selectionHtml = getSelectionHtml()
      selectionHtml = selectionHtml.replace(/<[\S]+><\/[\S]+>/gim, '')

      hasMultiParagraphs = selectionHtml.match(/<(p|h[0-6]|blockquote)>([\s\S]*?)<\/(p|h[0-6]|blockquote)>/g)

      if !@options.allowMultiParagraphSelection and hasMultiParagraphs
        return @_hide()

      @_show()
      @_setPosition()
      @_setButtonStates()

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
      if @$anchorForm.is(':visible') then @_show() else @_showAnchorForm()

  _showAnchorForm: ->
    @keepToolbarVisible = true

    @savedSelection = window.saveSelection()

    @$anchorForm.show()
    @$toolbarButtons.hide()

    @$anchorInput.focus()
    @$anchorInput.val('')

  _bindButtons: ->
    toolbar  = @

    triggerAction = (e) ->
      e.preventDefault()
      e.stopPropagation()

      $button = $(e.currentTarget)
      $button.toggleClass('character-editor-button-active')

      action = $button.attr('data-action')
      toolbar._execAction(action, e)

    $(document).on 'click', '#character_editor_toolbar_buttons button', triggerAction

  _setTargetBlank: ->
    el = window.getSelectionStart()

    if el.tagName.toLowerCase() == 'a'
      el.target = '_blank'
    else
      $(el).find('a').each (i, el) -> $(el).attr('target', '_blank')

  _createLink: (input) ->
    window.restoreSelection(@savedSelection)
    document.execCommand('createLink', false, @$anchorInput.val())

    if @options.targetBlank
      @_setTargetBlank()

    @_show()
    @$anchorInput.val('')

  _bindAnchorForm: ->
    @$anchorForm.on 'click', (e) ->
      e.stopPropagation()

    @$anchorInput.on 'keyup', (e) =>
      if e.keyCode == 13
        e.preventDefault()
        @_createLink()

    @$anchorInput.on 'blur', (e) =>
      @keepToolbarVisible = false

    @$anchorForm.find('a').on 'click', (e) =>
      e.preventDefault()
      window.restoreSelection(@savedSelection)

  destroy: ->
    $(@options.viewSelector).off 'mouseup keyup blur'
    $(window).off 'resize'
    @$anchorForm.off 'click'
    @$anchorForm.find('a').off 'click'
    @$anchorInput.on 'keyup blur'
    $(document).off 'click', '#character_editor_toolbar_buttons button'
    @$elem.remove()