import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReceiptsPage extends StatefulWidget {
  const ReceiptsPage({super.key});

  @override
  State<ReceiptsPage> createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  String? useruid;
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> receipts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      setState(() => useruid = user.uid);
      await _fetchReceipts();
    }
  }

  String get _dateKey =>
      "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}";

  Future<void> _fetchReceipts() async {
    if (useruid == null) return;
    setState(() => isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("Receipt")
          .doc(useruid)
          .collection(_dateKey)
          .orderBy("Receipt id", descending: true)
          .get();

      if (mounted) {
        setState(() {
          receipts = snapshot.docs
              .map((doc) => doc.data())
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
      await _fetchReceipts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Receipt History",
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
            tooltip: "Pick date",
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchReceipts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date header
          Container(
            width: double.maxFinite,
            color: Colors.indigo[900],
            padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Date: $_dateKey",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  "${receipts.length} receipt(s)",
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : receipts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long_outlined,
                                size: 80, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              "No receipts for this date",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today),
                              label: const Text("Pick another date"),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: receipts.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final receipt = receipts[index];
                          return _ReceiptCard(receipt: receipt);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final Map<String, dynamic> receipt;
  const _ReceiptCard({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final List items = receipt["Items"] ?? [];
    final List quantities = receipt["Quantity"] ?? [];
    final List prices = receipt["Price"] ?? [];
    final dynamic total = receipt["Total"] ?? 0;
    final String mode = receipt["Mode of Payment"] ?? "-";
    final String time = receipt["Bill Time"] ?? "-";
    final int id = receipt["Receipt id"] ?? 0;

    return Card(
      elevation: 2,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.indigo[900],
          child: Text(
            "#$id",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          "Receipt #$id  •  ₹$total",
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          "$time  |  $mode",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(
                        child: Text("Item",
                            style:
                                TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(
                        width: 50,
                        child: Text("Qty",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center)),
                    SizedBox(
                        width: 60,
                        child: Text("Price",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.right)),
                  ],
                ),
                const Divider(),
                ...List.generate(items.length, (i) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(child: Text("${items[i]}")),
                        SizedBox(
                            width: 50,
                            child: Text(
                              "${i < quantities.length ? quantities[i] : '-'}",
                              textAlign: TextAlign.center,
                            )),
                        SizedBox(
                            width: 60,
                            child: Text(
                              "₹${i < prices.length ? prices[i] : '-'}",
                              textAlign: TextAlign.right,
                            )),
                      ],
                    ),
                  );
                }),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Total: ₹$total",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
