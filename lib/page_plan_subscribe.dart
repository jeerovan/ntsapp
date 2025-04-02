import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntsapp/page_signin.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:ntsapp/utils_sync.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'enums.dart';
import 'page_user_task.dart';
import 'storage_hive.dart';

class PagePlanSubscribe extends StatefulWidget {
  const PagePlanSubscribe({super.key});

  @override
  State<PagePlanSubscribe> createState() => _PagePlanSubscribeState();
}

class _PagePlanSubscribeState extends State<PagePlanSubscribe> {
  AppLogger logger = AppLogger(prefixes: ["PagePlan"]);
  List<Package> _packages = [];
  bool processing = true;
  bool revenueCatSupported =
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  @override
  void initState() {
    super.initState();
    processing = revenueCatSupported;
    if (revenueCatSupported) {
      fetchOfferings();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> fetchOfferings() async {
    try {
      Offerings? offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        setState(() {
          _packages = offerings.current!.availablePackages;
        });
      }
    } on PlatformException catch (e) {
      logger.error("fetchOfferings", error: e);
    }
    if (mounted) {
      setState(() {
        processing = false;
      });
    }
  }

  Future<void> makePurchase(Package package) async {
    setState(() {
      processing = true;
    });
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      if (customerInfo.entitlements.active.isNotEmpty) {
        logger.info("Purchased:${package.storeProduct.title}");
        //if signed in, associate
        String? userId = SyncUtils.getSignedInUserId();
        if (userId != null) {
          LogInResult result = await Purchases.logIn(userId);
          logger.info(result.toString());
        }
        navigateToOnboardingChecks();
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        logger.error("purchaseError", error: e);
      }
    }
    setState(() {
      processing = false;
    });
  }

  Future<void> navigateToOnboardingChecks() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PageUserTask(
          task: AppTask.checkCloudSync,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (StorageHive()
                  .get(AppString.deviceId.string, defaultValue: null) ==
              null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => PageSignin(),
                  ),
                );
              },
              child: Text(
                'Login',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
        ],
      ),
      body: processing
          ? Center(child: CircularProgressIndicator()) // Centering the loader
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.amber, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'Sync all your notes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'across your devices',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 20),

                  /// Features List
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureItem('End-to-end encryption'),
                      _buildFeatureItem('Sync up to 3 devices'),
                      _buildFeatureItem('Upgrade/Cancel anytime'),
                    ],
                  ),

                  SizedBox(height: 20),

                  /// ListView inside Expanded to prevent unbounded height issues
                  revenueCatSupported
                      ? _packages.isEmpty
                          ? Center(child: Text("No plans available"))
                          : Expanded(
                              child: ListView.builder(
                                shrinkWrap:
                                    true, // Ensures it works inside Column
                                physics:
                                    BouncingScrollPhysics(), // Smooth scrolling
                                itemCount: _packages.length,
                                itemBuilder: (context, index) {
                                  Package package = _packages[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: _buildPlanOption(package),
                                  );
                                },
                              ),
                            )
                      : Column(
                          children: [
                            Center(
                              child: Image.asset(
                                "assets/app_qr.png",
                                width: 200.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text("Download the app & subscribe"),
                          ],
                        ),

                  /// Privacy Terms
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      "Privacy • Terms",
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(Icons.check, color: Colors.blue, size: 20),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOption(Package package) {
    StoreProduct product = package.storeProduct;
    final productId = product.identifier;

    // Extract the part before the colon (if present)
    final idPart = productId.split(':').first;

    // Extract numbers and units using regex
    //final deviceMatch =RegExp(r'(\d+)devices?').firstMatch(idPart.toLowerCase());
    final storageMatch =
        RegExp(r'(\d+)(gb|tb)').firstMatch(idPart.toLowerCase());
    String planDuration = idPart.contains("year") ? "year" : "month";
    // Parse number of devices
    //final String numDevices = deviceMatch != null ? deviceMatch.group(1)! : "1";

    // Parse storage size (convert TB to GB if needed)
    String storageSize = "";
    if (storageMatch != null) {
      final String size = storageMatch.group(1)!;
      final String unit = storageMatch.group(2)!;
      storageSize = '$size ${unit.toUpperCase()}';
    }

    return GestureDetector(
      onTap: () {
        makePurchase(package);
      },
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 15, vertical: 30),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      storageSize,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if ("show_savings".isEmpty)
                      Container(
                        margin: EdgeInsets.only(left: 8),
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'Save 50%',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Text(
              '${product.priceString.replaceAll(".00", "")}/$planDuration',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
