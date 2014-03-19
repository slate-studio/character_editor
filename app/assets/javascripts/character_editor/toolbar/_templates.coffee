
@CharacterEditor.Toolbar._toolbarTemplate = (options) -> """
  <div id='character_editor_toolbar' class='character-editor-toolbar'>
    <ul id='character_editor_toolbar_buttons'></ul>
    <div class='character-editor-toolbar-form-anchor' id='character_editor_toolbar_form_anchor'>
      <input type='text' value='' placeholder='#{ options.anchorInputPlaceholder }'><a href='#'>&times;</a>
    </div>
    <div class='character-editor-toolbar-arrow'></div>
  </div>"""

@CharacterEditor.Toolbar._generateButtonTemplates = (options) ->
  classPrefix = 'character-editor-action'

  l =
    bold:           '<i class="fa fa-bold"></i>'
    italic:         '<i class="fa fa-italic"></i>'
    underline:      '<i class="fa fa-underline"></i>'
    strikethrough:  '<i class="fa fa-strikethrough"></i>'
    anchor:         '<i class="fa fa-link"></i>'
    quote:          '<i class="fa fa-quote-right"></i>'
    orderedlist:    '<i class="fa fa-list-ol"></i>'
    unorderedlist:  '<i class="fa fa-list-ul"></i>'
    pre:            '<i class="fa fa-code fa-lg"></i>'
    header1:        "<b>#{ options.firstHeader.toUpperCase() }</b>"
    header2:        "<b>#{ options.secondHeader.toUpperCase() }</b>"
    #image:          '<i class="fa fa-picture-o"></i>'
    #superscript:    '<i class="fa fa-superscript"></i>'
    #subscript:      '<i class="fa fa-subscript"></i>'

  templates =
    bold:           "<li><button class='#{classPrefix} #{classPrefix}-bold'
                                 data-action='bold' data-element='b'>#{ l.bold }</button></li>"

    italic:         "<li><button class='#{classPrefix} #{classPrefix}-italic'
                                 data-action='italic' data-element='i'>#{ l.italic }</button></li>"

    underline:      "<li><button class='#{classPrefix} #{classPrefix}-underline'
                                 data-action='underline' data-element='u'>#{ l.underline }</button></li>"

    strikethrough:  "<li><button class='#{classPrefix} #{classPrefix}-strikethrough'
                                 data-action='strikethrough' data-element='strike'>#{ l.strikethrough }</button></li>"

    anchor:         "<li><button class='#{classPrefix} #{classPrefix}-anchor'
                                 data-action='anchor' data-element='a'>#{ l.anchor }</button></li>"

    quote:          "<li><button class='#{classPrefix} #{classPrefix}-quote'
                                 data-action='append-blockquote' data-element='blockquote'>#{ l.quote }</button></li>"

    orderedlist:    "<li><button class='#{classPrefix} #{classPrefix}-orderedlist'
                                 data-action='insertorderedlist' data-element='ol'>#{ l.orderedlist }</button></li>"

    unorderedlist:  "<li><button class='#{classPrefix} #{classPrefix}-unorderedlist'
                                 data-action='insertunorderedlist' data-element='ul'>#{ l.unorderedlist }</button></li>"

    pre:            "<li><button class='#{classPrefix} #{classPrefix}-pre'
                                 data-action='append-pre' data-element='pre'>#{ l.pre }</button></li>"

    header1:        "<li><button class='#{classPrefix} #{classPrefix}-header1'
                                 data-action='append-#{ options.firstHeader }' data-element='#{ options.firstHeader }'>#{ l.header1 }</button></li>"

    header2:        "<li><button class='#{classPrefix} #{classPrefix}-header2'
                                 data-action='append-#{ options.secondHeader }' data-element='#{ options.secondHeader }'>#{ l.header2 }</button></li>"

    # image:          "<li><button class='#{classPrefix} #{classPrefix}-image'
    #                              data-action='image' data-element='img'>#{ l.image }</button></li>"

    # superscript:    "<li><button class='#{classPrefix} #{classPrefix}-superscript'
    #                              data-action='superscript' data-element='sup'>#{ l.superscript }</button></li>"

    # subscript:      "<li><button class='#{classPrefix} #{classPrefix}-subscript'
    #                              data-action='subscript' data-element='sub'>#{ l.subscript }</button></li>"

  return templates