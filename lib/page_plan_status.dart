import 'package:flutter/material.dart';
import 'package:ntsapp/page_signin.dart';

class PagePlanStatus extends StatefulWidget {
  const PagePlanStatus({super.key});

  @override
  State<PagePlanStatus> createState() => _PagePlanStatusState();
}

class _PagePlanStatusState extends State<PagePlanStatus> {
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber, size: 40),
            SizedBox(height: 10),
            Text(
              'Sync all your notes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'across your devices',
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
            _buildPlanOption('Yearly', '\$11.99/year', 'just 0.99/month', true),
            SizedBox(height: 10),
            _buildPlanOption(
                'Monthly', '\$1.99/month', 'billed monthly', false),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                'Continue',
                style: TextStyle(color: Colors.black),
              ),
            ),
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
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOption(
      String title, String price, String description, bool isHighlighted) {
    return Container(
      padding: EdgeInsets.all(15),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (isHighlighted)
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              Text(
                price,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
