import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';


class Webview extends StatefulWidget {
  @override
  _WebviewState createState() => _WebviewState();
}

class _WebviewState extends State<Webview> {
  Completer<WebViewController> _controller = Completer<WebViewController>();
  //final Set<String> _favorites = Set<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wikipedia Explorer'),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        // actions: <Widget>[
        //   NavigationControls(_controller.future),
        //   Menu(_controller.future, () => _favorites),
        // ],
      ),
      body: WebView(
        initialUrl: 'https://en.wikipedia.org/wiki/Kraken',
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      ),
      //floatingActionButton: _bookmarkButton(),
    );
  }
}

//   _bookmarkButton() {
//     return FutureBuilder<WebViewController>(
//       future: _controller.future,
//       builder:
//           (BuildContext context, AsyncSnapshot<WebViewController> controller) {
//         if (controller.hasData) {
//           return FloatingActionButton(
//             onPressed: () async {
//               var url = await controller.data.currentUrl();
//               _favorites.add(url);
//               Scaffold.of(context).showSnackBar(
//                 SnackBar(content: Text('Saved $url for later reading.')),
//               );
//             },
//             child: Icon(Icons.favorite),
//           );
//         }
//         return Container();
//       },
//     );
//   }
// }