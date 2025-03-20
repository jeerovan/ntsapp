import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntsapp/page_signin.dart';
import 'package:ntsapp/service_logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PagePlanSubscribe extends StatefulWidget {
  const PagePlanSubscribe({super.key});

  @override
  State<PagePlanSubscribe> createState() => _PagePlanSubscribeState();
}

class _PagePlanSubscribeState extends State<PagePlanSubscribe> {
  AppLogger logger = AppLogger(prefixes: ["PagePlan"]);
  StoreProduct? annual;
  StoreProduct? monthly;
  bool processing = true;
  @override
  void initState() {
    super.initState();
    fetchOfferings();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> fetchOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        Package? annualPackage = offerings.current!.annual;
        Package? monthlyPackage = offerings.current!.monthly;
        if (annualPackage != null) {
          annual = annualPackage.storeProduct;
        }
        if (monthlyPackage != null) {
          monthly = monthlyPackage.storeProduct;
        }
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

  Future<void> makePurchase(StoreProduct productToBuy) async {
    try {
      CustomerInfo customerInfo =
          await Purchases.purchaseStoreProduct(productToBuy);
      Map<String, EntitlementInfo> entitlements = customerInfo.entitlements.all;
      if (entitlements.containsKey(productToBuy.identifier)) {
        EntitlementInfo entitlementInfo =
            entitlements[productToBuy.identifier]!;
        if (entitlementInfo.isActive) {
          logger.info("Purchased:${productToBuy.title}");
        }
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        logger.error("purchaseError", error: e);
      }
    }
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
          ? CircularProgressIndicator()
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureItem('End-to-end encryption'),
                      _buildFeatureItem('50 GB storage'),
                      _buildFeatureItem('Sync up to 3 devices'),
                      _buildFeatureItem('One more benefit'),
                    ],
                  ),
                  SizedBox(height: 20),
                  if (annual != null) _buildPlanOption(annual!, 'Yearly', true),
                  SizedBox(height: 20),
                  if (monthly != null)
                    _buildPlanOption(monthly!, 'Monthly', false),
                  SizedBox(height: 20),
                  /* ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Continue',
                      style: TextStyle(color: Colors.black),
                    ),
                  ), */
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Cancel anytime",
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      Text(
                        "Privacy • Terms",
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
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

  Widget _buildPlanOption(
      StoreProduct product, String title, bool isHighlighted) {
    return GestureDetector(
      onTap: () {
        makePurchase(product);
      },
      child: Container(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 15, vertical: 30),
        decoration: BoxDecoration(
          border: Border.all(color: isHighlighted ? Colors.blue : Colors.grey),
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
                      title,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (isHighlighted)
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
                /* Text(
                  '',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ), */
              ],
            ),
            Text(
              '${product.priceString}/${title.replaceAll("ly", "")}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
