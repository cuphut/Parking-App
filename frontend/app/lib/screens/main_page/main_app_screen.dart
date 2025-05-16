import 'package:flutter/material.dart';
import 'detection_screen.dart';
import 'parking_screen.dart';
import 'vehicle_screen.dart';

class MainAppScreen extends StatefulWidget {
  final String username;
  final String role;

  const MainAppScreen({
    super.key,
    required this.username,
    required this.role,
  });

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _titles = ['Nhận diện', 'Bãi đỗ hiện tại', 'Phương tiện'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isSearchVisible = false;
      _searchController.clear();
      _searchQuery = '';
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const DetectionScreen(),
      ParkingScreen(searchQuery: _searchQuery),
      VehicleScreen(role: widget.role),
    ];

    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm theo biển số...',
                  border: InputBorder.none,
                ),
              )
            : Text(_titles[_selectedIndex]),
        actions: _selectedIndex == 1
            ? [
                IconButton(
                  icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearchVisible = !_isSearchVisible;
                      if (!_isSearchVisible) {
                        _searchController.clear();
                      }
                    });
                  },
                ),
              ]
            : null,
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                widget.username, // Use username from widget
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(
                widget.role, // Use role from widget
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700 ,
                  color: Colors.white70,
                ),
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              margin: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Nhận diện'),
          BottomNavigationBarItem(icon: Icon(Icons.local_parking), label: 'Bãi đỗ'),
          BottomNavigationBarItem(icon: Icon(Icons.two_wheeler), label: 'Phương tiện'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}