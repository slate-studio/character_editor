
@CharacterEditor.Toolbar._setPosition = ->
  $contentView  = $(@options.viewSelector)
  $arrow        = @$elem.children('.character-editor-toolbar-arrow')
  $toolbarWidth = @$elem.width()
  $toolbarLeft  = @$elem.position().left

  contentLeftOffset = $contentView.offset().left
  contentTopOffset  = $contentView.offset().top
  contentScrollTop  = $contentView.scrollTop()
  contentInnerWidth = $contentView.innerWidth()

  selection = window.getSelection()
  range     = selection.getRangeAt(0)
  boundary  = range.getBoundingClientRect()

  offsetWidth  = @$elem.get(0).offsetWidth
  offsetHeight = @$elem.get(0).offsetHeight

  defaultLeft     = (@options.diffLeft) - (offsetWidth / 2)
  middleBoundary  = (boundary.left + boundary.right) / 2 - contentLeftOffset
  halfOffsetWidth = offsetWidth / 2

  @$elem.css 'top', boundary.top + @options.diffTop - contentTopOffset + contentScrollTop - offsetHeight + 'px'

  edgeOffset = 5

  if middleBoundary < halfOffsetWidth
    @$elem.css { left: "#{edgeOffset}px", right: 'auto' }
    $arrow.css { 'margin-left': -($toolbarWidth/2 - middleBoundary + 10) } # arrow to left

  else if (contentInnerWidth - middleBoundary) < halfOffsetWidth
    @$elem.css { left: 'auto', right: "#{edgeOffset}px" }
    $arrow.css { 'margin-left': (middleBoundary - $toolbarLeft - $toolbarWidth/2 - 5) } # arrow to right

  else
    @$elem.css { left: defaultLeft + middleBoundary + 'px', right: 'auto' }
    $arrow.css { 'margin-left': '' } # center arrow