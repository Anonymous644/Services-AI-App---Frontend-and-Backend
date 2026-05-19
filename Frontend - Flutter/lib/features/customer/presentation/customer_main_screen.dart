import 'package:flutter/material.dart';
import '../../bookings/presentation/bookings_view.dart';
import '../../chat/presentation/chat_view.dart';
import '../../profile/presentation/profile_view.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _views;

  @override
  void initState() {
    super.initState();
    _views = [
      _CustomerBookingsWrapper(onStartNewBooking: () {
        setState(() => _currentIndex = 1);
      }),
      const ChatView(),
      const ProfileView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _CustomerBookingsWrapper extends StatelessWidget {
  final VoidCallback onStartNewBooking;

  const _CustomerBookingsWrapper({required this.onStartNewBooking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const BookingsView(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onStartNewBooking,
        icon: const Icon(Icons.add),
        label: const Text('New Booking'),
      ),
    );
  }
}
