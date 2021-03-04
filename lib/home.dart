import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomePage extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final _homeController = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyText2;
    final lable = Theme.of(context).textTheme.headline1;
    return GetBuilder<HomeController>(builder: (homecontroller) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Title'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 12, right: 12, top: 12),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Form(
                          key: formKey,
                          child: Expanded(
                            flex: 5,
                            child: Container(
                              height: 44,
                              child: TextFormField(
                                controller:
                                    homecontroller.textEditingController,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Url is Empty';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter URL of Product',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(22)),
                          height: 40,
                          color: Colors.green,
                          child: Text('Go'),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            if (formKey.currentState.validate()) {
                              homecontroller.fetch();
                            }
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    productWidget(homecontroller, lable, context),
                    SizedBox(
                      height: 12,
                    ),
                  ],
                ),
                homecontroller.showProgress
                    ? Positioned(
                        top: 50,
                        left: Get.width / 2 - 50,
                        child: CircularProgressIndicator(),
                      )
                    : SizedBox()
              ],
            ),
          ),
        ),
      );
    });
  }

  Column productWidget(
      HomeController homecontroller, TextStyle lable, BuildContext context) {
    return Column(
      children: [
        Column(
          children: homecontroller.imageUrls
              .map(
                (image) => Image.network(image),
              )
              .toList(),
        ),
        SizedBox(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              homecontroller.price.toString(),
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Text(homecontroller.title ?? 'Non',
            style: lable.copyWith(
                height: 1.5, wordSpacing: 1, letterSpacing: 1, fontSize: 20)),
        SizedBox(
          height: 16,
        )
      ],
    );
  }
}
