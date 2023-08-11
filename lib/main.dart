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
    return MaterialApp(
      home: Scaffold(
        body: homeContent(context),
      ),
    );
  }

  Widget homeContent(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return FutureBuilder<List<ArticleList>>(
      future: getArticleData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingIndicator();
        } else if (snapshot.hasError) {
          return errorWidget();
        } else {
          return CustomScrollView(
            slivers: [
              blurAppBar(),
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

  SliverAppBar blurAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: kToolbarHeight,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Stack(
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: SvgPicture.asset(
              "assets/logo.svg",
              height: 32,
            ),
          ),
        ],
      ),
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
    final article = data![index - 1];
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ArticlePage(link: article.link))),
      child: Container(
        padding: const EdgeInsets.all(8.0),
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
        padding: const EdgeInsets.all(8.0),
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
}

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
        blurAppBar(),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              FutureBuilder<String>(
                future: getArticleContent(link),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return loadingIndicator();
                  } else if (snapshot.hasError) {
                    return errorWidget();
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

  SliverAppBar blurAppBar() {
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

Widget loadingIndicator() {
  return const Center(child: CircularProgressIndicator());
}

Widget errorWidget() {
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
            "인터넷 연결에 문제가 있거나\n블로그에 문제가 있을 수 있어요.\n",
            style: TextStyle(
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "인터넷 연결에 문제가 없다면 개발자에게 문의해주세요",
            textAlign: TextAlign.center,
          )
        ],
      ),
    ),
  );
}

Future<List<ArticleList>> getArticleData() async {
  final response = await http.get(Uri.parse('https://blog.d3h1.com'));

  var document = parser.parse(response.body);
  List<dom.Element> articleList = document.querySelectorAll('main article');
  
  return articleList.map((article) {
    var img = article.querySelector('img')?.attributes['src'];
    var category = article.querySelector('.post-category')?.text;
    var title = article.querySelector('.post-title')?.text;
    var description = article.querySelector('.post-description')?.text;
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