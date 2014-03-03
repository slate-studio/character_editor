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
    @_bindHover()
    @_bindImage()

  _bindHover: ->
    @$elem.on 'mouseenter', (e) => @stayVisible = true
    @$elem.on 'mouseleave', (e) => @stayVisible = false ; @_hide()

    $(document).on 'mousemove', '.character-editor-insert-enabled', (e) =>
      $editorElement = $(e.currentTarget)
      currentEditor  = $editorElement.data('editor')
      if currentEditor.options.disableInsert
        return

      if e.currentTarget == e.target
        # cursor is in between blocks
        offsetY       = 0
        paddingTop    = parseInt($editorElement.css('padding-top'))

        if $editorElement.children().length > 0
          paddingTop += parseInt $editorElement.children().first().css('margin-top')

        if e.offsetY <= paddingTop + 10
          # beginning of the editor: do nothing
          if $editorElement.children().length > 0
            offsetY += parseInt $editorElement.children().first().css('margin-top')
        else
          # find block above cursor
          # TODO: we need too improve this, right now there is an issue when <block1 bMargin> != <block2 tMargin>
          y = parseInt $editorElement.css('padding-top')
          $editorElement.children().each (i, el) =>
            $block       = $(el)
            blockHeight  = $block.outerHeight(true) - parseInt($block.css('margin-bottom'))
            y           += blockHeight

            if y < e.offsetY
              @$insertAfterBlock = $block
              offsetY            = y

        @stayVisible  = true
        @_show($editorElement, offsetY)

      else
        @stayVisible = false
        @_hide()

    $(document).on 'mouseleave', '.character-editor-insert-enabled', =>
      @stayVisible = false
      @_hide()


  _bindImage: ->
    updateFigureImg = ($el, data) ->
      imageUrl = data.image.url
      $el.children('img').remove()
      $el.addClass('character-image').append("<img src='#{ imageUrl }' />")

    attachDropzone = ($el) ->
      $el.fileupload
        url: '/admin/Character-Image'
        paramName: 'character_image[image]'
        dataType:  'json'
        dropZone:  $el
        done: (e, data) ->
          updateFigureImg($el, data.result.image)

    $(document).on 'click', '[data-editor-image]', (e) ->
      $el = $(e.currentTarget)
      chr.execute 'showImages', true, (images) ->
        # TODO: add support for multiple images
        model = images[0]
        if model
          updateFigureImg($el, model.get('image'))

    $('#character_editor_insert_button').on 'click', (e) =>
      $el = $("""<figure class='character-image-upload' contenteditable='false' data-editor-image></figure>""")
      $el.insertAfter(@$insertAfterBlock)
      attachDropzone($el)

    $('[data-editor-image]').each (i, el) -> attachDropzone $(el)

    # TODO: delete uploader when removing image figure


  destroy: ->
    $(document).off 'mousemove, mouseleave', '.character-editor-insert-enabled'
    $('#character_editor_insert_button').off 'click'
    @$elem.off 'mouseenter, mouseleave'
    @$elem.remove()