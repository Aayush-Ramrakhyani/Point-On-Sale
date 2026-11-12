import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pos/theme/app_theme.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class MyCartCheckout extends StatefulWidget {
  const MyCartCheckout({
    Key? key,
    required this.itemlist,
    required this.quantitylist,
    required this.pricelist,
    required this.kotitems,
    required this.kotquantity,
    required this.clearListCallback,
    required this.useruid,
  }) : super(key: key);

  final List<String> itemlist;
  final List kotitems;
  final List kotquantity;
  final List<dynamic> quantitylist;
  final List<dynamic> pricelist;
  final VoidCallback clearListCallback;
  final dynamic useruid;

  @override
  State<MyCartCheckout> createState() => _MyCartCheckoutState();
}

class _MyCartCheckoutState extends State<MyCartCheckout> {
  dynamic totalamount = 0;
  bool nodata = false;
  String modeofpayment = '';
  final DateTime now = DateTime.now();
  dynamic todaysdate = "";
  dynamic id = 0;

  @override
  void initState() {
    super.initState();
    calculateTotal();
    todaysdate = "${now.day}-${now.month}-${now.year}";
  }

  Future<void> generateBill() async {
    final snap = await FirebaseFirestore.instance
        .collection("Receipt")
        .doc(widget.useruid)
        .collection(todaysdate)
        .get();

    int maxId = 0;
    for (final doc in snap.docs) {
      final int currentId = doc.data()["Receipt id"] ?? 0;
      if (currentId > maxId) maxId = currentId;
    }

    id = maxId + 1;
    await billprint(id);

    await FirebaseFirestore.instance
        .collection("Receipt")
        .doc(widget.useruid)
        .collection(todaysdate)
        .doc("$id")
        .set({
      "Receipt id": id,
      "Items": widget.itemlist,
      "Quantity": widget.quantitylist,
      "Price": widget.pricelist,
      "Mode of Payment": modeofpayment,
      "Total": totalamount,
      "Bill Time":
          "${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}"
    });

    setState(() => modeofpayment = "");
  }

  void calculateTotal() {
    if (widget.itemlist.isEmpty) {
      setState(() => nodata = true);
      return;
    }
    int total = 0;
    for (int i = 0; i < widget.itemlist.length; i++) {
      total += (widget.quantitylist[i] as int) *
          int.parse(widget.pricelist[i].toString());
    }
    setState(() => totalamount = total);
  }

  Future<void> billprint(dynamic billid) async {
    try {
      final CapabilityProfile profile = await CapabilityProfile.load();
      final Generator generator = Generator(PaperSize.mm80, profile);

      List<int> bytes = [];
      bytes += generator.hr();
      bytes += generator.text("POINT OF SALE",
          styles: const PosStyles(
              bold: true, width: PosTextSize.size2, align: PosAlign.center));
      bytes += generator.hr();
      bytes += generator.text(
          "A FINAL YEAR PROJECT BY THE STUDENTS OF RC TECHNICAL INSTITUTE",
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(text: "Date: $todaysdate", width: 6),
        PosColumn(text: "", width: 3),
        PosColumn(text: "", width: 3),
      ]);
      bytes += generator.row([
        PosColumn(
            text:
                "Time: ${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
            width: 6),
        PosColumn(text: "", width: 3),
        PosColumn(text: "", width: 3),
      ]);
      bytes += generator.row([
        PosColumn(text: "MOD: $modeofpayment", width: 6),
        PosColumn(text: "", width: 3),
        PosColumn(text: "", width: 3),
      ]);
      bytes += generator.row([
        PosColumn(text: "ID: $billid", width: 6),
        PosColumn(text: "", width: 3),
        PosColumn(text: "", width: 3),
      ]);
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(text: "Item", width: 3, styles: const PosStyles(bold: true)),
        PosColumn(text: "Qty", width: 3, styles: const PosStyles(bold: true)),
        PosColumn(text: "Price", width: 3, styles: const PosStyles(bold: true)),
        PosColumn(text: "Total", width: 3, styles: const PosStyles(bold: true)),
      ]);
      bytes += generator.hr();

      for (int i = 0; i < widget.itemlist.length; i++) {
        final num qty = num.parse(widget.quantitylist[i].toString());
        final num unitPrice = num.parse(widget.pricelist[i].toString());
        bytes += generator.row([
          PosColumn(text: widget.itemlist[i], width: 3),
          PosColumn(text: qty.toString(), width: 3),
          PosColumn(text: unitPrice.toString(), width: 3),
          PosColumn(text: (qty * unitPrice).toString(), width: 3),
        ]);
      }

      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(text: "", width: 7),
        PosColumn(text: "Total: $totalamount", width: 5),
      ]);
      bytes += generator.hr();
      bytes += generator.text('\n\n\n');

      await PrintBluetoothThermal.writeBytes(bytes);

      widget.clearListCallback();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      Fluttertoast.showToast(msg: 'Print failed. Check printer connection.');
    }
  }

  Future<void> kotprint() async {
    try {
      final CapabilityProfile profile = await CapabilityProfile.load();
      final Generator generator = Generator(PaperSize.mm80, profile);

      List<int> bytes = [];
      bytes += generator.hr();
      bytes += generator.text("KOT - POINT OF SALE",
          styles: const PosStyles(
              bold: true, width: PosTextSize.size2, align: PosAlign.center));
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(text: "Date: $todaysdate", width: 6),
        PosColumn(text: "", width: 3),
        PosColumn(text: "", width: 3),
      ]);
      bytes += generator.row([
        PosColumn(
            text:
                "Time: ${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
            width: 6),
        PosColumn(text: "", width: 3),
        PosColumn(text: "", width: 3),
      ]);
      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(text: "Item", width: 6, styles: const PosStyles(bold: true)),
        PosColumn(
            text: "Quantity", width: 6, styles: const PosStyles(bold: true)),
      ]);
      bytes += generator.hr();

      for (int i = 0; i < widget.kotitems.length; i++) {
        final num qty = num.parse(widget.kotquantity[i].toString());
        bytes += generator.row([
          PosColumn(text: "${widget.kotitems[i]}", width: 6),
          PosColumn(text: qty.toString(), width: 6),
        ]);
      }

      bytes += generator.hr();
      bytes += generator.text('\n\n\n');
      await PrintBluetoothThermal.writeBytes(bytes);
    } catch (_) {
      Fluttertoast.showToast(
          msg: 'KOT print failed. Check printer connection.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Bill Summary'),
        actions: [
          _paymentChip("Cash", Icons.payments_rounded),
          const SizedBox(width: 6),
          _paymentChip("Online", Icons.wifi_rounded),
          const SizedBox(width: 6),
          _paymentChip("Card", Icons.credit_card_rounded),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: nodata
                ? const Center(
                    child: Text("No items in cart",
                        style:
                            TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    itemCount: widget.itemlist.length,
                    itemBuilder: (context, index) =>
                        _buildCartItem(index),
                  ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final subtotal = (widget.quantitylist[index] as int) *
        int.parse(widget.pricelist[index].toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.itemlist[index],
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "₹${widget.pricelist[index]} each  ·  Subtotal: ₹$subtotal",
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            // Quantity controls
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _qtyButton(Icons.remove_rounded, () {
                    setState(() {
                      if (widget.quantitylist[index] > 1) {
                        widget.quantitylist[index]--;
                        if (index < widget.kotquantity.length) {
                          widget.kotquantity[index]--;
                        }
                      } else {
                        widget.itemlist.removeAt(index);
                        widget.quantitylist.removeAt(index);
                        widget.pricelist.removeAt(index);
                        if (index < widget.kotitems.length) {
                          widget.kotitems.removeAt(index);
                          widget.kotquantity.removeAt(index);
                        }
                      }
                      calculateTotal();
                    });
                  }),
                  SizedBox(
                    width: 32,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: Text(
                        "${widget.quantitylist[index]}",
                        key: ValueKey(widget.quantitylist[index]),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  _qtyButton(Icons.add_rounded, () {
                    setState(() {
                      widget.quantitylist[index]++;
                      if (index < widget.kotquantity.length) {
                        widget.kotquantity[index]++;
                      }
                      calculateTotal();
                    });
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 60).ms, duration: 350.ms)
        .slideX(
          begin: 0.15,
          end: 0,
          delay: (index * 60).ms,
          duration: 350.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }

  Widget _paymentChip(String label, IconData icon) {
    final selected = modeofpayment == label;
    return GestureDetector(
      onTap: () => setState(() => modeofpayment = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Amount",
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Text(
                    "₹$totalamount",
                    key: ValueKey(totalamount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: kotprint,
                    icon: const Icon(Icons.receipt_outlined, size: 18),
                    label: const Text("KOT",
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    text: "Print & Save",
                    icon: Icons.print_rounded,
                    onPressed: () {
                      if (widget.itemlist.isEmpty) {
                        Fluttertoast.showToast(msg: "Select items first");
                      } else if (modeofpayment.isEmpty) {
                        Fluttertoast.showToast(msg: "Select a payment method");
                      } else {
                        generateBill();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
