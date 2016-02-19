import 'package:markdown/markdown.dart' as md;
import 'package:flutter/material.dart';

class MarkdownStyle {
  MarkdownStyle({
    this.h1,
    this.h2,
    this.h3,
    this.h4,
    this.h5,
    this.h6,
    this.em,
    this.bold
  });

  MarkdownStyle.fromTheme(ThemeData theme) :
    h1 = theme.text.display3,
    h2 = theme.text.display2,
    h3 = theme.text.display1,
    h4 = theme.text.headline,
    h5 = theme.text.title,
    h6 = theme.text.subhead,
    em = new TextStyle(fontStyle: FontStyle.italic),
    bold = new TextStyle(fontWeight: FontWeight.bold);

  MarkdownStyle copyWith({
    TextStyle h1,
    TextStyle h2,
    TextStyle h3,
    TextStyle h4,
    TextStyle h5,
    TextStyle h6,
    TextStyle em,
    TextStyle bold
  }) {
    return new MarkdownStyle(
      h1: h1 != null ? h1 : this.h1,
      h2: h2 != null ? h2 : this.h2,
      h3: h3 != null ? h3 : this.h3,
      h4: h4 != null ? h4 : this.h4,
      h5: h5 != null ? h5 : this.h5,
      h6: h6 != null ? h6 : this.h6,
      em: em != null ? em : this.em,
      bold: bold != null ? bold : this.bold
    );
  }

  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle h4;
  final TextStyle h5;
  final TextStyle h6;
  final TextStyle em;
  final TextStyle bold;
}

class Markdown extends StatefulComponent {
  Markdown({
    this.data,
    this.style
  });

  final String data;
  final MarkdownStyle style;

  State<Markdown> createState() => new _MarkdownState();
}

class _MarkdownState extends State<Markdown> {

  void initState() {
    super.initState();
    _cachedStyle = textFromMarkdown(config.data);
  }

  Widget build(BuildContext context) {
    return new StyledText(elements: _cachedStyle);
  }

  List<dynamic> _cachedStyle;
}

List<dynamic> textFromMarkdown(String data) {
  var lines = data.replaceAll('\r\n', '\n').split('\n');
  md.Document document = new md.Document();

  _Renderer renderer = new _Renderer();
  return renderer.render(document.parseLines(lines));
}

class _Renderer implements md.NodeVisitor {
  List<dynamic> render(List<md.Node> nodes) {
    _stack = [];

    for (final md.Node node in nodes) {
      node.accept(this);
    }

    print("stack: $_stack");
    if (_stack.length > 0)
      return _stack.first;
    else
      return [""];
  }

  List<dynamic> _stack;

  void visitText(md.Text text) {
    print("visitText: ${text.text}");

    // Add text to topmost list on the stack
    List<dynamic> top = _stack.last;
    top.add(text.text);
  }

  bool visitElementBefore(md.Element element) {
    print("visitElementBefore: tag: ${element.tag}");
    // Add a new element, that contains the tag's style, to the stack
    List<dynamic> styleElement = <dynamic>[_objectForTag(element.tag)];
    _stack.add(styleElement);

    return true;
  }

  void visitElementAfter(md.Element element) {
    print("visitElementAfter: tag: ${element.tag}");

    if (_stack.length > 1) {
      List<dynamic> popped = _stack.last;
      _stack.removeLast();

      List<dynamic> top = _stack.last;
      top.add(popped);
    }
  }

  dynamic _objectForTag(String tag) {
    if (tag == 'p')
      return new TextStyle(color: Colors.black);
    else if (tag == 'em')
      return new TextStyle(fontStyle: FontStyle.italic);
    else if (tag == 'strong')
      return new TextStyle(fontWeight: FontWeight.bold);
    else
      return new TextStyle();
  }
}

class _BlockTag {
  _BlockTag(this.tag);
  final String tag;
}
