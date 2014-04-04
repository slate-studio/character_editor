#= require_self

window.delay = (ms, fnc) -> setTimeout(fnc, ms)

@CharacterEditor.Insert =
  init: (options, elem) ->
    @options = $.extend({}, @options, options)

    @$elem = $("<div id=character_editor_insert_button class='character-editor-insert'><i class='chr-icon icon-plus-alt'></i></div>")
    $(@options.viewSelector).append(@$elem)

    @_build()
    @_bind()
    @

  options: {}

  _build: ->

  _hide: ->
    delay 50, => if not @stayVisible then @$elem.removeClass('visible')

  _show: ($editorElement, offsetY=0) ->
    # TODO: it looks like we don't need live recalculations, rather can have just a table of positions
    delay 50, =>
      if @stayVisible
        offsetX  = -($(@options.viewSelector).offset().left - $editorElement.offset().left) - 5 # '+' moves to the right
        offsetY += Math.floor($editorElement.offset().top + $(@options.viewSelector).scrollTop() - $(@options.viewSelector).offset().top)
        @$elem.css({ top: offsetY, 'margin-left': offsetX }).addClass('visible')

  _bind: ->
    @_bindOnHover()
    @_bindImage()

  _bindOnHover: ->
    @$elem.on 'mouseenter', (e) => @stayVisible = true
    @$elem.on 'mouseleave', (e) => @stayVisible = false ; @_hide()
    @_bindMousemove()
    #$(document).on 'mouseleave', '.character-editor-insert-enabled', => @stayVisible = false ; @_hide()

  _bindMousemove: ->
    $(document).on 'mousemove', '.character-editor-insert-enabled', (e) =>
      # TODO: block this while scrolling is not stopped
      $editorElement = $(e.currentTarget)
      currentEditor  = $editorElement.data('editor')

      if currentEditor.options.disableInsert
        return

      if e.currentTarget == e.target # no child block is hovered
        offsetY   = 0
        editorTop = $editorElement.offset().top

        if $editorElement.children().length > 0
          paddingTop = $editorElement.children().first().offset().top - editorTop
        else
          paddingTop = parseInt($editorElement.css('padding-top'))

        if e.offsetY <= paddingTop # beginning of the editor
          if $editorElement.children().length > 0
            offsetY = paddingTop - @$elem.height()

          @$insertAfterBlock = false
          @$activeEditor = $editorElement

        else # cursor in between blocks
          $editorElement.children().each (i, el) =>
            $block = $(el)
            y = $block.offset().top - editorTop + $block.height()

            if y < e.offsetY
              @$insertAfterBlock = $block
              offsetY = y

        @stayVisible  = true
        @_show($editorElement, offsetY)

      else
        @stayVisible = false
        @_hide()

  _bindImage: ->
    $('#character_editor_insert_button').on 'click', (e) =>
      chr.execute 'showImages', true, (images) =>
        _.each images.reverse(), (model) =>
          @_insertImage(model.get('image'))

  _insertImage: (data) ->
    imageUrl = data.image.regular.url
    $el = $("""<figure class='character-image' contenteditable='false'><img src='#{ imageUrl }'></figure>""")
    if @$insertAfterBlock then $el.insertAfter(@$insertAfterBlock) else $el.prependTo(@$activeEditor)

  destroy: ->
    $('#character_editor_insert_button').off 'click'
    $(document).off 'mousemove', '.character-editor-insert-enabled'
    @$elem.off 'mouseenter, mouseleave'
    @$elem.remove()