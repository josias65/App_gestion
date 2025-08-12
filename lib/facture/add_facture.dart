import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddFACTUREScreen extends StatefulWidget {
  const AddFACTUREScreen({super.key});

  @override
  State<AddFACTUREScreen> createState() => _AddFACTUREScreenState();
}

class _AddFACTUREScreenState extends State<AddFACTUREScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _invoiceNumberController = TextEditingController(
    text:
        'FAC-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}',
  );
  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  String _paymentStatus = 'Pending';
  final List<InvoiceItem> _items = [];
  final _itemNameController = TextEditingController();
  final _itemQuantityController = TextEditingController(text: '1');
  final _itemPriceController = TextEditingController();
  double _subtotal = 0.0;
  final double _taxRate = 0.2;
  final double _discount = 0.0;

  @override
  void dispose() {
    _clientController.dispose();
    _invoiceNumberController.dispose();
    _itemNameController.dispose();
    _itemQuantityController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_itemNameController.text.isEmpty ||
        _itemQuantityController.text.isEmpty ||
        _itemPriceController.text.isEmpty) {
      return;
    }

    setState(() {
      _items.add(
        InvoiceItem(
          name: _itemNameController.text,
          quantity: int.parse(_itemQuantityController.text),
          unitPrice: double.parse(_itemPriceController.text),
        ),
      );
      _calculateTotal();
      _itemNameController.clear();
      _itemQuantityController.text = '1';
      _itemPriceController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    _subtotal = _items.fold(
      0.0,
      (sum, item) => sum + (item.quantity * item.unitPrice),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isInvoiceDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isInvoiceDate ? _invoiceDate : _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isInvoiceDate) {
          _invoiceDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _subtotal * (1 + _taxRate) - _discount;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nouvelle Facture',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF4F6DF5),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Save invoice logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Facture enregistrée avec succès'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client Information Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations Client',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _clientController,
                        decoration: InputDecoration(
                          labelText: 'Nom du client',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un nom de client';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _invoiceNumberController,
                        decoration: InputDecoration(
                          labelText: 'Numéro de facture',
                          prefixIcon: const Icon(Icons.numbers),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Dates and Status Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date de facture',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 5),
                                InkWell(
                                  onTap: () => _selectDate(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey[50],
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(_invoiceDate),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date d\'échéance',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 5),
                                InkWell(
                                  onTap: () => _selectDate(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey[50],
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(_dueDate),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _paymentStatus,
                        decoration: InputDecoration(
                          labelText: 'Statut de paiement',
                          prefixIcon: const Icon(Icons.payment),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: ['Pending', 'Paid', 'Overdue']
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _paymentStatus = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Items Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Articles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _itemNameController,
                              decoration: InputDecoration(
                                labelText: 'Nom de l\'article',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _itemQuantityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Qté',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _itemPriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Prix',
                                prefixText: '\$ ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Ajouter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F6DF5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          onPressed: _addItem,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_items.isNotEmpty) ...[
                        const Divider(),
                        const SizedBox(height: 10),
                        ..._items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Dismissible(
                            key: Key('$index'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) => _removeItem(index),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(flex: 3, child: Text(item.name)),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      item.quantity.toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '\$${item.unitPrice.toStringAsFixed(2)}',
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '\$${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Summary Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Récapitulatif',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildSummaryRow('Sous-total', _subtotal),
                      _buildSummaryRow(
                        'Taxe (${(_taxRate * 100).toInt()}%)',
                        _subtotal * _taxRate,
                      ),
                      _buildSummaryRow('Remise', -_discount),
                      const Divider(),
                      _buildSummaryRow('Total', total, isTotal: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal ? const Color(0xFF4F6DF5) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class InvoiceItem {
  final String name;
  final int quantity;
  final double unitPrice;

  InvoiceItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });
}
