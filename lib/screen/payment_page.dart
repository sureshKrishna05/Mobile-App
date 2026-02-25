import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  // This must be here to receive the data from the Cart!
  final double amountToPay; 

  const PaymentPage({super.key, required this.amountToPay});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedMethod = 'mastercard';
  bool saveDetails = true;

  // Design constants from your screenshot
  final double taxes = 0.30;
  final double deliveryFees = 1.50;

  @override
  Widget build(BuildContext context) {
    // We use widget.amountToPay to get the value passed from the Cart
    double totalValue = widget.amountToPay + taxes + deliveryFees;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order summary', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildRow('Order', '\$${widget.amountToPay.toStringAsFixed(2)}'),
                  _buildRow('Taxes', '\$${taxes.toStringAsFixed(2)}'),
                  _buildRow('Delivery fees', '\$${deliveryFees.toStringAsFixed(2)}'),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider()),
                  _buildRow('Total:', '\$${totalValue.toStringAsFixed(2)}', isBold: true),
                  const Text('Estimated delivery time: 15 - 30mins', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 40),
                  const Text('Payment methods', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _paymentCard('mastercard', 'Credit card', '5105 **** **** 0505', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png'),
                  const SizedBox(height: 12),
                  _paymentCard('visa', 'Debit card', '3566 **** **** 0505', 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/2560px-Visa_Inc._logo.svg.png'),
                ],
              ),
            ),
          ),
          _buildFooter(totalValue),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isBold ? 18 : 15, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.black : Colors.grey)),
          Text(value, style: TextStyle(fontSize: isBold ? 18 : 15, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _paymentCard(String id, String title, String subtitle, String logoUrl) {
    bool isSelected = selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE53935) : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              width: 45, height: 30,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
              child: Image.network(logoUrl, fit: BoxFit.contain),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
                Text(subtitle, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? Colors.white : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Total price', style: TextStyle(color: Colors.grey)),
              Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          ElevatedButton(
            onPressed: () {}, 
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Pay Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}