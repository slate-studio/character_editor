
@CharacterEditor.Toolbar._setPosition = ->
  $contentView      = $(@options.viewSelector)

  contentLeftOffset = $contentView.offset().left
  contentTopOffset  = $contentView.offset().top
  contentScrollTop  = $contentView.scrollTop()
  contentInnerWidth = $contentView.innerWidth()

  selection       = window.getSelection()
  range           = selection.getRangeAt(0)
  boundary        = range.getBoundingClientRect()

  offsetWidth  = @$elem.get(0).offsetWidth
  offsetHeight = @$elem.get(0).offsetHeight

  defaultLeft       = (@options.diffLeft) - (offsetWidth / 2)
  middleBoundary    = (boundary.left + boundary.right) / 2 - contentLeftOffset
  halfOffsetWidth   = offsetWidth / 2



  #buttonHeight = 30
  # if boundary.top < buttonHeight
    # @$elem.addClass('character-toolbar-arrow-over')
    # @$elem.removeClass('character-toolbar-arrow-under')
    # @$elem.css 'top', buttonHeight + boundary.bottom - @options.diffTop + window.pageYOffset - offsetHeight + 'px'
  # else
  @$elem.addClass('character-toolbar-arrow-under')
  @$elem.removeClass('character-toolbar-arrow-over')
  @$elem.css 'top', boundary.top + @options.diffTop - contentTopOffset + contentScrollTop - offsetHeight + 'px'


  edgeOffset = 5
  if middleBoundary < halfOffsetWidth
    @$elem.css { left: "#{edgeOffset}px", right: 'auto' }
    # arrow to left
  else if (contentInnerWidth - middleBoundary) < halfOffsetWidth
    @$elem.css { left: 'auto', right: "#{edgeOffset}px" }
    # arrow to right
  else
    @$elem.css { left: defaultLeft + middleBoundary + 'px', right: 'auto' }
    # center arrow