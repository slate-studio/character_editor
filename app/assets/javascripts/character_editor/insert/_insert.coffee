#= require_self

@CharacterEditor.Insert =
  init: (options, elem) ->
    @options = $.extend({}, @options, options)

    @$elem = $("<div id='character_editor_insert' class='character-editor-insert'><i class='chr-icon icon-plus-alt'></i></div>")
    $(@options.viewSelector).append(@$elem)

    @_build()

    @_bind()

    @

  options: {}

  _build: ->
    @_hide()

  _hide: ->
    @$elem.css({ visibility: 'hidden' })

  _show: ($editorElement, offsetY=0) ->
    offsetX  = -($(@options.viewSelector).offset().left - $editorElement.offset().left) - 20 - 10 # element width, offset
    offsetY += Math.floor($editorElement.offset().top + $(@options.viewSelector).scrollTop() - $(@options.viewSelector).offset().top)
    @$elem.css({ top: offsetY, 'margin-left': offsetX, visibility: 'visible' })

  _bind: ->
    $(document).on 'mousemove', '[data-editor-element]', (e) =>
      $editorElement = $(e.currentTarget)
      @currentEditor = $editorElement.data('editor')

      if @currentEditor.options.disableInsert
        return

      if e.currentTarget == e.target
        # cursor is in between blocks

        offsetY = 0
        paddingTop = parseInt($editorElement.css('padding-top'))

        if $editorElement.children().length > 0
          paddingTop += parseInt($editorElement.children().first().css('margin-top'))

        if e.offsetY <= paddingTop
          # beginning of the editor: do nothing
        else
          # find block above cursor
          prevBlockOffset = paddingTop
          $editorElement.children().each (i, el) ->
            $block = $(el)
            blockHeight = $block.outerHeight()

            if prevBlockOffset + blockHeight < e.offsetY
              offsetY = prevBlockOffset + blockHeight
              prevBlockOffset += blockHeight + parseInt($block.css('margin-bottom'))

        @_show($editorElement, offsetY)

      else
        @_hide()

    $(document).on 'mouseleave', '[data-editor-element]', =>
      @currentEditor = null
      @_hide()

  destroy: ->
    $(document).off 'mousemove, mouseleave', '[data-editor-element] > *'
    @$elem.remove()