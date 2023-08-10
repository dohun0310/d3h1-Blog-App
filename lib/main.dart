import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

class ArticleList {
  final String img;
  final String category;
  final String title;
  final String description;
  final String link;

  ArticleList(this.img, this.category, this.title, this.description, this.link);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder<List<ArticleList>>(
          future: getArticleData(),
          builder: (context, snapshot) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: kToolbarHeight,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: Stack(
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
                            title: SvgPicture.asset(
                              "assets/logo.svg",
                              height: 32,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error),
                            SizedBox(height: 8),
                            Text(
                              "블로그를 불러오는데 오류가 발생했어요.",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "인터넷에 연결이 되어있지 않거나\n블로그 자체에 문제가 생긴 것일 수 있어요.\n",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "인터넷 연결에 문제가 없다면 개발자에게 문의해주세요.",
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    )
                  )
                else if (isTablet || isLandscape)
                  _tabletLayout(snapshot.data)
                else
                  _mobileLayout(snapshot.data),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverList _mobileLayout(List<ArticleList>? data) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "홈",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }
          var article = data[index - 1];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticlePage(link: article.link),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.network(article.img),
                  const SizedBox(height: 8),
                  Text(
                    article.category,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    article.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: data!.length + 1,
      ),
    );
  }

  SliverGrid _tabletLayout(List<ArticleList>? data) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          var article = data[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticlePage(link: article.link),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.network(article.img),
                  const SizedBox(height: 8),
                  Text(
                    article.category,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    article.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: data!.length,
      ),
    );
  }
}


class ArticlePage extends StatelessWidget {
  final String link;

  const ArticlePage({Key? key, required this.link}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
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
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                FutureBuilder<String>(
                  future: getArticleContent(link),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error),
                              SizedBox(height: 8),
                              Text(
                                "블로그를 불러오는데 오류가 발생했어요.",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "인터넷에 연결이 되어있지 않거나\n블로그 자체에 문제가 생긴 것일 수 있어요.\n",
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "인터넷 연결에 문제가 없다면 개발자에게 문의해주세요.",
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      );
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
      ),
    );
  }
}

Future<List<ArticleList>> getArticleData() async {
  final response = await http.get(Uri.parse('https://blog.d3h1.com'));
  var document = parser.parse(response.body);

  List<dom.Element> articleList = document.querySelectorAll('main article');
  return articleList.map((article) {
    var img = article.querySelector('img');
    var category = article.querySelector('.post-category');
    var title = article.querySelector('.post-title');
    var description = article.querySelector('.post-description');
    var link = article.querySelector('a')?.attributes['href'] ?? '';

    if (img != null) {
      String src = img.attributes['src']!;
      return ArticleList(
        'https://blog.d3h1.com$src',
        category?.text ?? '',
        title?.text ?? '',
        description?.text ?? '',
        'https://blog.d3h1.com$link',
      );
    } else {
      return ArticleList(
        '',
        category?.text ?? '',
        title?.text ?? '',
        description?.text ?? '',
        ''
      );
    }
  }).toList();
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
