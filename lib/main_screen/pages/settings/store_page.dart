import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';

class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late Future<UserModel?> _myProfileFuture;

  @override
  void initState() {
    super.initState();
    // 위젯이 생성될 때 현재 사용자의 프로필 정보를 불러옵니다.
    final authService = Provider.of<AuthService>(context, listen: false);
    final myUserId = authService.getCurrentUser()?.uid;
    if (myUserId != null) {
      _myProfileFuture = authService.getUserProfile(myUserId);
    } else {
      // 로그인하지 않은 사용자에 대한 예외 처리
      _myProfileFuture = Future.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 결제 오류 안내 바텀 시트를 표시하는 함수
    void _showPaymentHelpSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return const PaymentHelpSheet();
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('알파 충전하기'),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      // FutureBuilder를 사용하여 DB에서 프로필 정보를 비동기적으로 로드합니다.
      body: FutureBuilder<UserModel?>(
        future: _myProfileFuture,
        builder: (context, snapshot) {
          // 로딩 중일 때 로딩 인디케이터 표시
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 에러가 발생했거나 데이터가 없는 경우
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
          }

          // 데이터 로드 성공 시
          final myProfile = snapshot.data!;
          final currentBalance = myProfile.cubes ?? 0; // UserModel의 cubes 필드 사용

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMyBalanceCard(context, currentBalance), // DB에서 가져온 재화 수량 전달
                const SizedBox(height: 32),
                _buildProductSection(
                  context,
                  title: '묶음 상품',
                  subtitle: '합리적인 가격으로 이용할 수 있는 상품',
                  products: [
                    {'bonus': 65, 'total': 500, 'price': 169000, 'isHot': true},
                    {'bonus': 150, 'total': 1000, 'price': 299000, 'isHot': false},
                    {'bonus': 105, 'total': 750, 'price': 249000, 'isHot': false},
                    {'bonus': 31, 'total': 250, 'price': 89000, 'isHot': false},
                    {'bonus': 12, 'total': 100, 'price': 37900, 'isHot': false},
                    {'bonus': 5, 'total': 50, 'price': 20000, 'isHot': false},
                  ],
                  isBundle: true,
                ),
                const SizedBox(height: 32),
                _buildProductSection(
                  context,
                  title: '기본 상품',
                  subtitle: '커피 한 잔 가격으로 이성 친구 만나기',
                  products: [
                    {'total': 5, 'price': 3000},
                    {'total': 10, 'price': 6000},
                    {'total': 20, 'price': 12000},
                  ],
                  isBundle: false,
                ),
                const SizedBox(height: 24),
                _buildPaymentInfoBox(context),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: _showPaymentHelpSheet,
                    child: Text(
                      '결제에 어려움이 있거나 오류가 발생했나요?',
                      style: TextStyle(
                        color: Colors.grey[600],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // 보유 재화 카드 위젯 (재화 수량을 인자로 받도록 수정)
  Widget _buildMyBalanceCard(BuildContext context, int currentBalance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.pinkAccent, Colors.orangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.diamond, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('내 보유 알파', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 4),
              // DB에서 가져온 값으로 텍스트 표시
              Text('$currentBalance 알파', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('이용내역', style: TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  // 상품 섹션 위젯
  Widget _buildProductSection(BuildContext context, {
    required String title,
    required String subtitle,
    required List<Map<String, dynamic>> products,
    required bool isBundle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductTile(
              context,
              total: product['total'],
              price: product['price'],
              bonus: product['bonus'],
              isHot: product['isHot'] ?? false,
              isBundle: isBundle,
            );
          },
        ),
      ],
    );
  }

  // 상품 리스트 아이템 위젯
  Widget _buildProductTile(BuildContext context, {
    required int total,
    required int price,
    int? bonus,
    bool isHot = false,
    required bool isBundle,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () { /* 결제 로직 연결 */ },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              if (isHot)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('HOT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              if (isHot) const SizedBox(width: 12),
              const Icon(Icons.diamond, color: Colors.pinkAccent, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isBundle && bonus != null)
                      Text('기본 ${total - bonus} + 추가 $bonus', style: TextStyle(color: Colors.grey[600])),
                    Text('$total 알파', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text('₩ ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // 결제 안내 박스 위젯
  Widget _buildPaymentInfoBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('결제 안내', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '재화(알파)는 서비스 내 유료 서비스 이용을 위해 사용하는 가상의 화폐입니다. 구매 후 7일 이내에 사용하지 않을 경우 청약철회가 가능합니다.',
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// 결제 오류 안내 바텀 시트 위젯
class PaymentHelpSheet extends StatefulWidget {
  const PaymentHelpSheet({Key? key}) : super(key: key);

  @override
  State<PaymentHelpSheet> createState() => _PaymentHelpSheetState();
}

class _PaymentHelpSheetState extends State<PaymentHelpSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 핸들 및 헤더
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text('알파 충전하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 탭바
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: const [
              Tab(text: '안드로이드'),
              Tab(text: '아이폰'),
            ],
          ),
          // 탭바 뷰
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAndroidHelpTab(),
                _buildIosHelpTab(), // 아이폰 탭은 현재 플레이스홀더
              ],
            ),
          ),
          // 하단 CTA 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('고객센터 연락하기', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // 안드로이드 도움말 탭
  Widget _buildAndroidHelpTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelpStep(
            '1. 구글 플레이스토어에 접속합니다.',
            'https://placehold.co/600x150/e2e8f0/333333?text=PlayStore_Main',
          ),
          _buildHelpStep(
            '2. 우측 상단 프로필을 클릭합니다.',
            'https://placehold.co/600x200/e2e8f0/333333?text=PlayStore_Profile_Menu',
          ),
          _buildHelpStep(
            '3. Google 계정 관리',
            'https://placehold.co/600x150/e2e8f0/333333?text=Google_Account_Highlight',
          ),
          _buildHelpStep(
            '4. 결제 및 구독',
            'https://placehold.co/600x250/e2e8f0/333333?text=Payment_And_Subscription',
          ),
        ],
      ),
    );
  }

  // 아이폰 도움말 탭 (플레이스홀더)
  Widget _buildIosHelpTab() {
    return const Center(
      child: Text('아이폰 결제 오류 안내 준비 중입니다.'),
    );
  }

  // 도움말 단계 위젯
  Widget _buildHelpStep(String title, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Center(child: Text('이미지를 불러올 수 없습니다.')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
