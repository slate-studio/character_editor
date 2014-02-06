# http://stackoverflow.com/questions/4176923/html-of-selected-text
# by Tim Down
window.getSelectionHtml = ->
  html = ''

  if window.getSelection != undefined
    sel = window.getSelection()

    if sel.rangeCount
      container = document.createElement('div')

      for i in [0..sel.rangeCount-1]
        container.appendChild(sel.getRangeAt(i).cloneContents())

      html = container.innerHTML

  else if document.selection != undefined

    if document.selection.type == 'Text'
      html = document.selection.createRange().htmlText

  return html

# http://stackoverflow.com/questions/1197401/how-can-i-get-the-element-the-caret-is-in-with-javascript-when-using-contentedi
# by You
window.getSelectionStart = ->
  node = document.getSelection().anchorNode
  startNode = if node and node.nodeType == 3 then node.parentNode else node
  return startNode

window.isListItemChild = (node) -> $(node).parents('li').length > 0

# http://stackoverflow.com/questions/5605401/insert-link-in-contenteditable-element
# by Tim Down
window.saveSelection = ->
  sel = window.getSelection()

  if sel.getRangeAt and sel.rangeCount
    ranges = []
    for i in [0..sel.rangeCount-1]
      ranges.push(sel.getRangeAt(i))
    return ranges

  return false

window.restoreSelection = (savedSel) ->
  sel = window.getSelection()
  if savedSel
    sel.removeAllRanges()
    for i in [0..savedSel.length-1]
      sel.addRange(savedSel[i])