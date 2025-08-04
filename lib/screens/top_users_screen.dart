import 'package:flutter/material.dart';
import '../models/leaderboard.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

class TopUsersScreen extends StatefulWidget {
  const TopUsersScreen({super.key});

  @override
  State<TopUsersScreen> createState() => _TopUsersScreenState();
}

class _TopUsersScreenState extends State<TopUsersScreen> {
  List<LeaderboardUser> _leaderboardUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get authentication token
      final token = await TokenService.getToken();
      
      // Fetch leaderboard data from API
      final leaderboardData = await ApiService.getLeaderboard(token: token);
      
      // Convert to LeaderboardUser objects
      final users = leaderboardData
          .map((userData) => LeaderboardUser.fromJson(userData))
          .toList();

      setState(() {
        _leaderboardUsers = users;
        _isLoading = false;
      });
      
    } catch (e) {
      print('Error fetching leaderboard: $e');
      setState(() {
        _errorMessage = 'Failed to load leaderboard. Please try again.';
        _isLoading = false;
        // Keep using mock data as fallback
        _leaderboardUsers = _createMockLeaderboardUsers();
      });
    }
  }

  // Fallback mock data in case API fails
  List<LeaderboardUser> _createMockLeaderboardUsers() {
    return [
      LeaderboardUser(userId: 1, id: 1, totalScore: '2850', firstName: 'Sarah', lastName: 'Johnson'),
      LeaderboardUser(userId: 2, id: 2, totalScore: '2720', firstName: 'Mike', lastName: 'Chen'),
      LeaderboardUser(userId: 3, id: 3, totalScore: '2650', firstName: 'Emma', lastName: 'Wilson'),
      LeaderboardUser(userId: 4, id: 4, totalScore: '2580', firstName: 'Alex', lastName: 'Rodriguez'),
      LeaderboardUser(userId: 5, id: 5, totalScore: '2420', firstName: 'Lisa', lastName: 'Thompson'),
      LeaderboardUser(userId: 6, id: 6, totalScore: '2350', firstName: 'David', lastName: 'Kim'),
      LeaderboardUser(userId: 7, id: 7, totalScore: '2280', firstName: 'Rachel', lastName: 'Green'),
      LeaderboardUser(userId: 8, id: 8, totalScore: '2150', firstName: 'John', lastName: 'Doe'),
      LeaderboardUser(userId: 9, id: 9, totalScore: '2080', firstName: 'Maria', lastName: 'Garcia'),
      LeaderboardUser(userId: 10, id: 10, totalScore: '1950', firstName: 'Tom', lastName: 'Anderson'),
    ];
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey.shade400; // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.emoji_events;
      case 3:
        return Icons.emoji_events;
      default:
        return Icons.person;
    }
  }

  String _getLeague(int score) {
    if (score >= 2500) return 'Diamond';
    if (score >= 2000) return 'Gold';
    if (score >= 1500) return 'Silver';
    return 'Bronze';
  }

  Color _getLeagueColor(String league) {
    switch (league.toLowerCase()) {
      case 'diamond':
        return Colors.cyan;
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey;
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Top Users', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchLeaderboard,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Column(
                children: [
                  const Icon(
                    Icons.leaderboard,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Leaderboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Top performers this month',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                  // Show error message if any
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade200, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Using demo data',
                            style: TextStyle(
                              color: Colors.orange.shade200,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_leaderboardUsers.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No leaderboard data available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else ...[
            // Top 3 Podium Section (only if we have at least 3 users)
            if (_leaderboardUsers.length >= 3)
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 2nd Place
                    _buildPodiumUser(_leaderboardUsers[1], 2),
                    // 1st Place
                    _buildPodiumUser(_leaderboardUsers[0], 1),
                    // 3rd Place
                    _buildPodiumUser(_leaderboardUsers[2], 3),
                  ],
                ),
              ),
            
            // Rest of the Users (4-10 or remaining users)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _leaderboardUsers.length > 3 ? _leaderboardUsers.length - 3 : 0,
                itemBuilder: (context, index) {
                  final user = _leaderboardUsers[index + 3]; // Skip first 3 users
                  final rank = index + 4; // Rank starts from 4 for the list
                  return _buildUserCard(user, rank);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPodiumUser(LeaderboardUser user, int position) {
    double avatarSize = position == 1 ? 35 : 30;
    double fontSize = position == 1 ? 16 : 14;
    double nameSize = position == 1 ? 14 : 12;
    final league = _getLeague(user.scoreAsInt);
    
    return Column(
      children: [
        // Trophy/Medal
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getRankColor(position).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: _getRankColor(position).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            _getRankIcon(position),
            color: _getRankColor(position),
            size: position == 1 ? 30 : 24,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Profile Picture (use default avatar)
        CircleAvatar(
          radius: avatarSize,
          backgroundColor: Colors.grey.shade300,
          child: Icon(
            Icons.person,
            size: avatarSize * 1.2,
            color: Colors.grey.shade600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Name
        SizedBox(
          width: 80,
          child: Text(
            user.displayName,
            style: TextStyle(
              fontSize: nameSize,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Score
        Text(
          user.totalScore,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: _getRankColor(position),
          ),
        ),
        
        // League Badge
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getLeagueColor(league).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getLeagueColor(league).withOpacity(0.3),
            ),
          ),
          child: Text(
            league,
            style: TextStyle(
              fontSize: 8,
              color: _getLeagueColor(league),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(LeaderboardUser user, int rank) {
    final league = _getLeague(user.scoreAsInt);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(rank).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getRankColor(rank).withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    color: _getRankColor(rank),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Profile Picture
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey.shade300,
              child: Icon(
                Icons.person,
                size: 30,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getLeagueColor(league).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getLeagueColor(league).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          league,
                          style: TextStyle(
                            fontSize: 10,
                            color: _getLeagueColor(league),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ID: ${user.userId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  user.totalScore,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  'total score',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
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
