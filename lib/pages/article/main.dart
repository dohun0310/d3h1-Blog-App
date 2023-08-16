import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter_html/flutter_html.dart';
import 'dart:ui';

import 'package:d3h1blog/components/error.dart';
import 'package:d3h1blog/components/loading.dart';

class ArticlePage extends StatelessWidget {
  final String link;

  const ArticlePage({Key? key, required this.link}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: articleContent(context),
    );
  }

  Widget articleContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        articleAppBar(),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              FutureBuilder<String>(
                future: getArticleContent(link),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingIndicator();
                  } else if (snapshot.hasError) {
                    return const WidgetError();
                  } else {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(8.0),
                      child: Html(data: snapshot.data ?? ""),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  SliverAppBar articleAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      expandedHeight: kToolbarHeight,
      iconTheme: 
        const IconThemeData(
          color: Colors.black,
        ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              color: Colors.transparent,
            ),
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> getArticleContent(String link) async {
  final response = await http.get(Uri.parse(link));

  var document = parser.parse(response.body);
  dom.Element? contentElement = document.querySelector('main article');

  contentElement?.querySelectorAll('img').forEach((imgElement) {
    String? src = imgElement.attributes['src'];
    if (src != null && !src.startsWith('http')) {
      imgElement.attributes['src'] = 'https://blog.d3h1.com$src';
    }
  });

  return contentElement?.outerHtml ?? '';
}