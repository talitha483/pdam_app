import 'package:flutter/material.dart';
import 'package:pdam/models/bill_models.dart';
import 'package:pdam/models/customer_models.dart';
import 'package:pdam/service/api_service.dart';
import 'package:pdam/service/app_collors.dart';
import 'customer_upload_bukti_page.dart';
import 'role_view.dart';

class CustomerDashboardView extends StatefulWidget {
  const CustomerDashboardView({super.key});

  @override
  State<CustomerDashboardView> createState() => _CustomerDashboardViewState();
}

class _CustomerDashboardViewState extends State<CustomerDashboardView> {
  int _currentIndex = 0;
  CustomerModel? _customer;
  List<BillModel> _bills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final profileRes = await ApiService.getMyProfile();
    final billsRes = await ApiService.getMyBills();
    
    if (mounted) {
      setState(() {
        if (profileRes['success'] == true) {
          final data = profileRes['data'] ?? profileRes;
          _customer = CustomerModel.fromJson(data);
        }
        if (billsRes['success'] == true) {
          final bData = billsRes['data'] as List?;
          _bills = bData?.map((e) => BillModel.fromJson(e)).toList() ?? [];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _CustomerBerandaTab(customer: _customer, bills: _bills, isLoading: _isLoading),
      _CustomerTagihanTab(bills: _bills, isLoading: _isLoading, onRefresh: _loadData),
      _CustomerBayarTab(bills: _bills, isLoading: _isLoading),
      _CustomerProfileTab(customer: _customer, isLoading: _isLoading),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Tagihan'),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card_outlined), activeIcon: Icon(Icons.credit_card), label: 'Bayar'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ---------------- TAB 1: BERANDA ----------------
class _CustomerBerandaTab extends StatelessWidget {
  final CustomerModel? customer;
  final List<BillModel> bills;
  final bool isLoading;

  const _CustomerBerandaTab({this.customer, required this.bills, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    final latestBill = bills.isNotEmpty ? bills.first : null;
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Halo', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(customer?.name ?? 'Nama customer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                      Text('No. Pelanggan: ${customer?.customerNumber ?? '-'}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Customer', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                CircleAvatar(backgroundColor: AppColors.primary, radius: 18, child: const Icon(Icons.notifications, color: Colors.white, size: 20)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Tagihan Terbaru Card
            if (latestBill != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F8FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tagihan terbaru', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('${latestBill.monthName} ${latestBill.year}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(latestBill.totalFormatted, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.danger)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(12)),
                          child: Text(latestBill.statusLabel, style: const TextStyle(color: AppColors.danger, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.water_drop_outlined, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pemakaian', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text('${latestBill.usageValue} m³', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(width: 24),
                        const Icon(Icons.speed, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Meter', style: TextStyle(fontSize: 10, color: Colors.grey)),
                            Text('#${latestBill.measurementNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('Bayar sekarang ', style: TextStyle(color: Colors.white)), Icon(Icons.arrow_forward, color: Colors.white, size: 16)]),
                    )
                  ],
                ),
              ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Riwayat Tagihan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Riwayat Tagihan >', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            ...bills.take(3).map((b) => _HistoryCard(bill: b)),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final BillModel bill;
  const _HistoryCard({required this.bill});
  
  @override
  Widget build(BuildContext context) {
    final isPaid = bill.isPaid;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF6F8FD), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.receipt_long, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${bill.monthName} ${bill.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Pemakaian: ${bill.usageValue} m³', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: isPaid ? AppColors.successLight : AppColors.dangerLight, borderRadius: BorderRadius.circular(12)),
                child: Text(isPaid ? 'Lunas' : 'Belum bayar', style: TextStyle(color: isPaid ? AppColors.success : AppColors.danger, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Text(bill.totalFormatted, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

// ---------------- TAB 2: TAGIHAN ----------------
class _CustomerTagihanTab extends StatelessWidget {
  final List<BillModel> bills;
  final bool isLoading;
  final VoidCallback onRefresh;

  const _CustomerTagihanTab({required this.bills, required this.isLoading, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    final unpaid = bills.where((b) => b.isUnpaid || b.isPending).toList();
    double totalUnpaid = unpaid.fold(0, (sum, item) => sum + item.effectiveTotal);
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tagihan Saya', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Kelola dan bayar tagihan air bulanan anda', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total belum dibayar', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text('Rp ${totalUnpaid.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger, fontSize: 14)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const Icon(Icons.water_drop_outlined, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Rata-rata pemakaian', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              const Text('41,7 m³ / bulan', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            ...bills.map((b) => _BillCardDetailed(bill: b)),
          ],
        ),
      ),
    );
  }
}

class _BillCardDetailed extends StatelessWidget {
  final BillModel bill;
  const _BillCardDetailed({required this.bill});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bill.isUnpaid ? AppColors.danger : Colors.grey[200]!),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${bill.monthName} ${bill.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('No. Meteran: ${bill.measurementNumber}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: bill.isPaid ? AppColors.successLight : AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(bill.statusLabel, style: TextStyle(color: bill.isPaid ? AppColors.success : AppColors.danger, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    Text(bill.totalFormatted, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: bill.isPaid ? Colors.black : AppColors.danger)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.water_drop_outlined, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text('Pemakaian: ${bill.usageValue} m³', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                if (bill.isUnpaid)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerUploadBuktiPage(bill: bill)));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('Bayar sekarang ', style: TextStyle(color: Colors.white)), Icon(Icons.arrow_forward, color: Colors.white, size: 16)]),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.success), borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      children: [Text('Sudah bayar ', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)), Icon(Icons.check_circle_outline, color: AppColors.success, size: 16)],
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ---------------- TAB 3: BAYAR ----------------
class _CustomerBayarTab extends StatelessWidget {
  final List<BillModel> bills;
  final bool isLoading;

  const _CustomerBayarTab({required this.bills, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    final unpaidBills = bills.where((b) => b.isUnpaid).toList();
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bayar Tagihan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Pilih tagihan yang ingin anda bayar', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 20),
            
            if (unpaidBills.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Tidak ada tagihan yang belum dibayar.')))
            else
              ...unpaidBills.map((b) => _BillCardDetailed(bill: b)),
              
            const SizedBox(height: 30),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Riwayat Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Riwayat Tagihan >', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const Text('Rekam jejak pembayaran anda', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            ...bills.where((b) => b.isPaid || b.isPending).map((b) => _PaymentHistoryCard(bill: b)),
          ],
        ),
      ),
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  final BillModel bill;
  const _PaymentHistoryCard({required this.bill});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData iconData;
    String statusText;
    
    if (bill.isPending) {
      statusColor = AppColors.warning;
      iconData = Icons.access_time;
      statusText = 'Menunggu Verifikasi';
    } else if (bill.isPaid) {
      statusColor = AppColors.success;
      iconData = Icons.check;
      statusText = 'Lunas';
    } else {
      statusColor = AppColors.danger;
      iconData = Icons.close;
      statusText = 'Ditolak';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(iconData, color: statusColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${bill.monthName} ${bill.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(bill.totalFormatted, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Dikirim', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  Text(bill.dueDate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          )
        ],
      ),
    );
  }
}

// ---------------- TAB 4: PROFILE ----------------
class _CustomerProfileTab extends StatelessWidget {
  final CustomerModel? customer;
  final bool isLoading;

  const _CustomerProfileTab({this.customer, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: const Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(customer?.name ?? '-', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Pelanggan Alirin sejak Jan 2022', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(Icons.person_outline, color: AppColors.primary, size: 16), SizedBox(width: 8), Text('Customer', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))],
              ),
            ),
            const SizedBox(height: 30),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Informasi Customer', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(height: 30),
                  _infoRow(Icons.credit_card, 'No. Pelanggan (NIK)', customer?.customerNumber ?? '-'),
                  const SizedBox(height: 16),
                  _infoRow(Icons.phone, 'No. Telepon', customer?.phone ?? '-'),
                  const SizedBox(height: 16),
                  _infoRow(Icons.location_on_outlined, 'Alamat', customer?.address ?? '-'),
                  const SizedBox(height: 16),
                  _infoRow(Icons.person_outline, 'Username customer', customer?.username ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Informasi Layanan', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(height: 30),
                  _infoRowText('Jenis layanan', customer?.serviceName ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await ApiService.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const RoleView()),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Keluar', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))],
        )
      ],
    );
  }
  
  Widget _infoRowText(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title, style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
    );
  }
}
