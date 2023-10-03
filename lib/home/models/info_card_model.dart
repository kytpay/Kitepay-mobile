class InfoCardModel {
  int? backgroundColor;
  String? backgroundImage;
  String? caption;
  String? url;

  InfoCardModel(
      this.backgroundColor, this.backgroundImage, this.caption, this.url);
}

List<InfoCardModel> cards = cardData
    .map(
      (item) => InfoCardModel(
        item['backgroundColor'] as int?,
        item['backgroundImage'] as String?,
        item['caption'] as String?,
        item['url'] as String?,
      ),
    )
    .toList();

var cardData = [
  {
    "backgroundColor": 0xFF1E1E99,
    "backgroundImage": "assets/png/kitepay.png",
    //  "caption": "Decentralized payments made easy",
    "url": "https://kitepay.org"
  },
  {
    "backgroundColor": 0xFFFF70A3,
    "backgroundImage": "assets/png/solanapay1.png",
    // "caption": "Learn about Solana pay",
    "url": "https://solana.com/news/solana-pay-announcement"
  },
  {
    "backgroundColor": 0xFF1E1E99,
    "backgroundImage": "assets/png/solana-payments.png",
    //  "caption": "Payments on Solana",
    "url": "https://youtu.be/1AnBma9huJY"
  },
  {
    "backgroundColor": 0xFF1E1E99,
    "backgroundImage": "assets/png/circle.png",
    "caption": "Circle's take on Solana pay",
    "url": "https://solana.com/news/solana-pay-announcement"
  },
  {
    "backgroundColor": 0xFF1E1E99,
    "backgroundImage": "assets/png/twt-kytpay.png",
    // "caption": "Tweet to us",
    "url": "https://twitter.com/intent/tweet?text=Hey%20@kytpay"
  },
];
