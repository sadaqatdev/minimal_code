import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:universal_html/html.dart' as element;
import 'package:http/http.dart' as http;
import 'package:universal_html/parsing.dart';

var img =
    'https://cdn.shopify.com/s/files/1/1083/6796/products/product-image-187878776_400x.jpg?v=1569388351';
String url =
    'https://shop.lululemon.com/p/mens-jackets-and-outerwear/Expeditionist-Anorak/_/prod10370103?color=0001';

class HomeController extends GetxController {
  TextEditingController textEditingController;

  List<String> imageUrls = [];

  String title = '';

  String price = '';

  static String priceHtmlTag = '';

  bool enable = false;

  bool showProgress = false;

  var doubleRE = RegExp(r"-?(?:\d*\.)?\d+(?:[eE][+-]?\d+)?");

  @override
  void onInit() {
    textEditingController = TextEditingController();
    // textEditingController.text = url;
    super.onInit();
  }

  @override
  void onClose() {
    textEditingController.dispose();
    super.onClose();
  }

  void enableValue(bool val) {
    enable = val;

    update();
  }

  void showProgrss(val) {
    showProgress = val;
    update();
  }

  Future<void> fetch() async {
    enableValue(true);
    showProgrss(true);
    try {
      final response = await http.get(Uri.parse(textEditingController.text));

      if (response.statusCode == 200) {
        Map<String, dynamic> priceMap = {};
        this.refresh();

        title = getTitle(response.body)[0];
        sleep(Duration(seconds: 1));
        priceMap = getPrice(response.body);
        sleep(Duration(seconds: 1));
        imageUrls = getImage(response.body);

        price = "${priceMap['currency']} ${priceMap['amount']}";

        showProgrss(false);
      } else {
        snakBar(response.statusCode);
        enableValue(false);
        showProgrss(false);
      }
    } catch (e) {
      snakBar(e);
      enableValue(false);
      showProgrss(false);
      update();
      print('----Error-----');
      print(e.toString());
    }
  }

  void snakBar(s) {
    Get.showSnackbar(GetBar(
      message: s,
      duration: Duration(seconds: 3),
    ));
  }
}

const productAttributeMap = {
  "price": [
    ":price:amount",
    ":price:currency",
    "priceCurrency",
    "product-price",
    "price",
    "product-main ProductPriceBlock__Price",
    "priceblock_dealprice",
    "PriceBlock",
    "current-price",
    "product-price",
    "priceblock",
    "product-price",
    "ProductPrice",
    "PriceBlock",
    "dealprice",
    "__Price",
    "-price",
    "price--",
    "price__",
    "-price",
    "Price",
    "price",
  ],
  "title": [
//meta tag
    ":title",
    "title",
    "description",
    ":description",

/////item prop
    "name",
    "pdp_h1",

    //class
    "product-name",
    "product-description__name",
    "__name",
    "title",
    "Title"
        "item-name",
    "pdp-title",
    "product-name",
    "product_name",
    "produit_title",
    "product__title",
    "font-primary",
    "short-title",
    "page-title",
    "productName_title",
    "productName",
    "BrandTitle",
    "productBrandTitle",
    "pl-Heading",
    "pdp__heading",
    "title--",
    "page-title",
    "pl-Heading",
    "product-single__title",
    "page-title",
    "product-title",
    "product__title",
    "product-page__title",
    "__title",
    "productName_title",
    "product_title",
    "productName_title",
    "productHeading",
    "product-description",
    "pinfo__heading",
    "listing-page-title",
    "lblProductName",
    "lblProduct",
    "productTitle",
    "itemTitle",
    "title",
    "hero-info-title",
  ],
  "image": [
    //meta tag
    ":image:",
    "image_src",
    {"parent": ".ProductImagery", "child": "img"},
    {"parent": ".image", "child": "img"},
    {"parent": ".product-image", "child": "img"},
    {"parent": ".product-gallery", "child": "img"},
    "popup-img",
    "product-image",
    "item active",
    "imgTagWrapper",
    "__image",
    "b-product_images-main_image",
    "swiper-zoom-container",
    "-image",
    "ProductImages-imgLink",
    "pdp-slider",
    "product-image",
    "ProductImage-",
    "product__image"
        "product-image",
    "productImages-",
    "slick-slide",
    "zoomImgMask",
    " ls-is-cached lazyloaded",
    "product-image-zoom",
    "productpage-image",
    "productImageCarousel_image",
    "athenaProductImageCarousel_image",
    "productBrandTitle",
    "js-big-image",
    "product-gallery-image",
    "image-wrapper",
    "s7staticimage",
    "ProductImage",
    "sticker",
    "pl-FluidImage-image",
    "img-wrap",
    "zoomImg",
    "ShotView",
    "product-carousel-image",
    "main-image",
    "productImageCarousel_image",
    "image_item",
    "SGBOXU1_image",

    "slick-slide",
    "slick-slide slick-current slick-active",
    "pimages",
    //id
    "imgProduct",
    "FeaturedImage",
    "imgTagWrapperId",
    "amp-originalImage",
//data-test
    "image",
  ]
};

const filters = [
  "property",
  "class",
  "itemprop",
  "item-prop",
  "id",
  "data-test-element",
  "data-test-id"
];
List<String> dataSet = [];
setData(_data) {
  dataSet.add(_data);
}

Map<String, dynamic> getPrice(String domData) {
  final htmlDocument = parseHtmlDocument(domData);

  productAttributeMap['price'].forEach((attrValue) {
    filters.forEach((filter) {
      // print('[$filter*="$attrValue"]');

      var _data = htmlDocument.querySelectorAll('[$filter*="$attrValue"]');

      _data.forEach((element.Element element) {
        if (filter.contains("prop")) {
          if (element.attributes['content'] != null) {
            if (element.attributes['content'].trim().isNotEmpty) {
              HomeController.priceHtmlTag = '[$filter*="$attrValue"]';
              print(
                  '==Price==========${element.attributes['content'].replaceAll(" ", "")}');
              setData(element.attributes['content'].replaceAll(" ", ""));
            }
          }
        } else if (element.innerText != null) {
          if (element.innerText.trim().isNotEmpty) {
            HomeController.priceHtmlTag = '[$filter*="$attrValue"]';
            print('==Price==========${element.innerText.replaceAll(" ", "")}');
            setData(element.innerText.replaceAll(" ", ""));
          }
        }
      });
    });
  });
  print('=======price lenght===== ${titleSet.length}');
  var currentCurrency = "";
  var s = ["USD", "\$", "£", "PKR"];

  dataSet.forEach((sign) {
    s.forEach((currency) {
      if (currentCurrency.isEmpty) {
        if (sign.contains(currency)) {
          currentCurrency = currency;
        }
      }
    });
  });

  dataSet = dataSet.toSet().toList();
  var newDataSet = [];
  dataSet.forEach((e) {
    if (e != currentCurrency) {
      newDataSet.add(e);
    }
  });

  return {"currency": currentCurrency, "amount": newDataSet[0]};
}

List<String> titleSet = [];
setTitle(_data) {
  titleSet.add(_data);
}

List<String> getTitle(String domData) {
  final htmlDocument = parseHtmlDocument(domData);

  productAttributeMap['title'].forEach((attrValue) {
    filters.forEach((filter) {
      // print('[$filter*="$attrValue"]');

      var _data = htmlDocument.querySelectorAll('[$filter*="$attrValue"]');

      _data.forEach((element.Element element) {
        if (filter.contains("prop")) {
          if (element.attributes['content'] != null) {
            if (element.attributes['content'].trim().isNotEmpty) {
              print(
                  '------Title  data 2-------- ${element.attributes['content'].replaceAll(" ", "")}');
              setTitle(element.attributes['content'].replaceAll(" ", ""));
            }
          }
        } else if (element.innerText != null) {
          if (element.innerText.trim().isNotEmpty) {
            print(
                '------Title data 2-------- ${element.innerText.replaceAll(" ", "")}');
            setTitle(element.innerText.replaceAll(" ", ""));
          }
        }
      });
    });
  });
  print('=======Title lenght===== ${titleSet.length}');
  return titleSet.toSet().toList();
}

List<String> imageSet = [];
setImage(_data) {
  imageSet.add(_data);
}

List<String> getImage(String domData) {
  imageSet = [];
  final htmlDocument = parseHtmlDocument(domData);

  productAttributeMap['image'].forEach((dynamic attrValue) {
    filters.forEach((filter) {
      var _data;
      if (attrValue.runtimeType.toString().contains("Map")) {
        _data = htmlDocument
            .querySelectorAll("${attrValue['parent']} ${attrValue['child']}");
      } else {
        _data = htmlDocument.querySelectorAll('[$filter*="$attrValue"]');

        _data.forEach((element.Element element) {
          if (filter.contains("prop")) {
            if (element.attributes['content'] != null) {
              if (element.attributes['content'].trim().isNotEmpty) {
                String prop = element.attributes['content'].replaceAll(" ", "");

                if (prop.contains('http')) {
                  print('------image up date-------- $prop');
                  setImage(prop);
                }
              }
            }
          } else if (element.innerText != null) {
            if (element.innerText.trim().isNotEmpty) {
              String data = element.innerText.replaceAll(" ", "");

              if (data.contains('http')) {
                print('=======imge data======== $data');
                setImage(data);
              }
            }
          }
        });
      }
    });
  });
  print('=======image lenght===== ${imageSet.length}');

  return imageSet.toSet().toList();
}
