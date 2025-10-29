import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  double _dragDistance = 0.0;
  double _rotationAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetCard() {
    _animation = Tween<Offset>(
      begin: Offset(_dragDistance / 200, 0),
      end: Offset.zero,
    ).animate(_controller);
    _controller.forward(from: 0);
    _dragDistance = 0.0;
    _rotationAngle = 0.0;
  }

  void _swipeCard(bool right) async {
    final width = MediaQuery.of(context).size.width;
    final direction = right ? 1 : -1;
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(direction * width, 0),
    ).animate(_controller);
    await _controller.forward(from: 0);

    if (mounted) {
      Provider.of<ProfileService>(context, listen: false).removeProfile();
      _controller.reset();
      _dragDistance = 0.0;
      _rotationAngle = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileService = Provider.of<ProfileService>(context);
    final profiles = profileService.profiles;

    if (profiles.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tinder Cards')), // Added AppBar
        body: const Center(child: Text('No more profiles!')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tinder Cards')), // Added AppBar
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: profiles.map((profile) {
            final index = profiles.indexOf(profile);
            final isFrontCard = index == profiles.length - 1;

            return _buildCard(profile, isFrontCard);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCard(Profile profile, bool isFrontCard) {
    return GestureDetector(
      onHorizontalDragStart: (details) {},
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragDistance += details.delta.dx;
          _rotationAngle = _dragDistance / 200;
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragDistance.abs() > 100) {
          _swipeCard(_dragDistance > 0);
        } else {
          _resetCard();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _rotationAngle * (1 - _controller.value); // Apply remaining rotation
          final offset = _animation.value;

          return Transform.translate(
            offset: Offset(offset.dx + _dragDistance, offset.dy),
            child: Transform.rotate(
              angle: angle,
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(profile.bio),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}