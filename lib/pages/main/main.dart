import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

import 'package:d3h1blog/components/error.dart';
import 'package:d3h1blog/components/loading.dart';
import 'package:d3h1blog/components/appbar.dart';
import 'package:d3h1blog/pages/article/main.dart';

Widget homeContent(BuildContext context) {
  final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
  final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

  return FutureBuilder<List<ArticleList>>(
    future: getArticleData(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const LoadingIndicator();
      } else if (snapshot.hasError) {
        return const WidgetError();
      } else {
        return CustomScrollView(
          slivers: [
            const CustomAppBar(),
            if (isTablet || isLandscape) 
              ...tabletLayout(snapshot.data!)
            else 
              mobileLayout(snapshot.data!)
          ],
        );
      }
    },
  );
}

SliverList mobileLayout(List<ArticleList>? data) {
  return SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) => mobileListItem(context, data, index),
      childCount: (data?.length ?? 0) + 1,
    ),
  );
}

Widget mobileListItem(BuildContext context, List<ArticleList>? data, int index) {
  if (index == 0) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "홈",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  final article = data![index - 1];
  return InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ArticlePage(link: article.link))),
    child: Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.network(article.img),
          const SizedBox(height: 8),
          Text(article.category, style: const TextStyle(fontSize: 12)),
          Text(article.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(article.description, style: const TextStyle(fontSize: 14, color: Colors.grey))
        ],
      ),
    ),
  );
}

List<Widget> tabletLayout(List<ArticleList>? data) {
  return [
    const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "홈",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
    SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return tabletListItem(data![index], context);
        },
        childCount: data?.length ?? 0,
      ),
    )
  ];
}
  
Widget tabletListItem(ArticleList article, BuildContext context) {
  return InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ArticlePage(link: article.link))),
    child: Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.network(article.img),
          const SizedBox(height: 8),
          Text(article.category, style: const TextStyle(fontSize: 12)),
          Text(article.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(article.description, style: const TextStyle(fontSize: 14, color: Colors.grey))
        ],
      ),
    ),
  );
}

class ArticleList {
  final String img;
  final String category;
  final String title;
  final String description;
  final String link;

  ArticleList(this.img, this.category, this.title, this.description, this.link);
}

Future<List<ArticleList>> getArticleData() async {
  final response = await http.get(Uri.parse('https://blog.d3h1.com'));

  var document = parser.parse(response.body);
  List<dom.Element> articleList = document.querySelectorAll('main article');
  
  return articleList.map((article) {
    var img = article.querySelector('img')?.attributes['src'];
    var category = article.querySelector('p[class^="postlist_category"]')?.text;
    var title = article.querySelector('h1[class^="postlist_title"]')?.text;
    var description = article.querySelector('p[class^="postlist_description"]')?.text;
    var link = article.querySelector('a')?.attributes['href'];

    return ArticleList(
      img == null ? '' : 'https://blog.d3h1.com$img',
      category ?? '',
      title ?? '',
      description ?? '',
      link == null ? '' : 'https://blog.d3h1.com$link',
    );
  }).toList();
}